require_dependency 'markazuna/di_container'

class Admin::MagazinesController < ApplicationController
    include Markazuna::INJECT['magazine_service']

    # http://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html
    wrap_parameters :magazine, include: [:title, :content, :picture, :pict_detail, :highlight, :is_deleted, :share_link, :target_tags, :post_id, :slug, :custom_slug, :score, :sponsored_tags]

    def index
        query = query_params.reject{|_, v| v.blank? || v == 'null'}

        magazines, page_count = magazine_service.find_magazines(query)
        if (magazines.size > 0)
            respond_to do |format|
                format.json { render :json => { results: magazines, count: page_count }}
            end
        else
            render :json => { results: []}
        end
    end

    def delete
        status, page_count = magazine_service.delete_magazine(params[:id])
        if status
            respond_to do |format|
                format.json { render :json => { status: "200", count: page_count } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def create
        magazine_form = Admin::MagazineForm.new(magazine_form_params)
        if magazine_service.create_magazine(magazine_form)
            respond_to do |format|
                format.json { render :json => { status: "200", message: "Success" } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def edit
        id = params[:id]
        magazine = magazine_service.find_magazine(id)

        if magazine
            respond_to do |format|
                format.json { render :json => { status: "200", payload: magazine } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def update
        magazine_form = Admin::MagazineForm.new(magazine_form_params)
        if magazine_service.update_magazine(magazine_form)
            respond_to do |format|
                format.json { render :json => { status: "200", message: "Success" } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    private
    def query_params        
        params.permit(:title, :content, :picture, :pict_detail, :highlight, :is_deleted, :share_link, :target_tags, :post_id, :slug, :custom_slug, :score, :sponsored_tags, :page, :search).to_h
    end

    # Using strong parameters
    def magazine_form_params
        params.require(:magazine).permit(:title, :content, :picture, :pict_detail, :highlight, :is_deleted, :share_link, :target_tags, :post_id, :slug, :custom_slug, :score, :sponsored_tags)
        # params.require(:core_user).permit! # allow all
    end
end
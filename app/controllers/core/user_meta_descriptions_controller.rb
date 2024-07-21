require_dependency 'markazuna/di_container'

class Core::UserMetaDescriptionsController < ApplicationController
    include Markazuna::INJECT['user_meta_description_service']

    # http://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html
    wrap_parameters :user_meta_description, include: [:id, :text_value]

    def index
        query = query_params.reject{|_, v| v.blank? || v == 'null'}

        user_meta_descriptions, page_count = user_meta_description_service.find_user_meta_descriptions(query)
        if (user_meta_descriptions.size > 0)
            respond_to do |format|
                format.json { render :json => { results: user_meta_descriptions, count: page_count }}
            end
        else
            render :json => { results: []}
        end
    end

    def delete
        status, page_count = user_meta_description_service.delete_user_meta_description(params[:id])
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
        user_meta_description_form = Core::UserMetaDescriptionForm.new(user_meta_description_form_params)
        if user_meta_description_service.create_user_meta_description(user_meta_description_form)
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
        user_meta_description = user_meta_description_service.find_user_meta_description(id)

        if user_meta_description
            respond_to do |format|
                format.json { render :json => { status: "200", payload: user_meta_description } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def update
        user_meta_description_form = Core::UserMetaDescriptionForm.new(user_meta_description_form_params)
        if user_meta_description_service.update_user_meta_description(user_meta_description_form)
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
        params.permit(:user_meta_description).permit(:text_value, :page, :search).to_h
    end

    # Using strong parameters
    def user_meta_description_form_params
        params.require(:user_meta_description).permit(:id, :text_value)
        # params.require(:core_user).permit! # allow all
    end
end
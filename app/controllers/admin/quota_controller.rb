require_dependency 'markazuna/di_container'

class Insurances::QuotaController < ApplicationController
    include Markazuna::INJECT['quota_service']

    # http://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html
    wrap_parameters :quota, include: [:type, :start_date, :end_date, :total_quota, :remaining_quota, :is_unlimited, :is_freeze]

    def index
        query = query_params.reject{|_, v| v.blank? || v == 'null'}

        quota, page_count = quota_service.find_quota(query)
        if (quota.size > 0)
            respond_to do |format|
                format.json { render :json => { results: quota, count: page_count }}
            end
        else
            render :json => { results: []}
        end
    end

    def delete
        status, page_count = quota_service.delete_quota(params[:id])
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
        quota_form = Insurances::QuotaForm.new(quota_form_params)
        if quota_service.create_quota(quota_form)
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
        quota = quota_service.find_quota(id)

        if quota
            respond_to do |format|
                format.json { render :json => { status: "200", payload: quota } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def update
        quota_form = Insurances::QuotaForm.new(quota_form_params)
        if quota_service.update_quota(quota_form)
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
        params.permit(:quota).permit(:type, :start_date, :end_date, :total_quota, :remaining_quota, :is_unlimited, :is_freeze, :page, :search).to_h
    end

    # Using strong parameters
    def quota_form_params
        params.require(:quota).permit(:type, :start_date, :end_date, :total_quota, :remaining_quota, :is_unlimited, :is_freeze)
        # params.require(:core_user).permit! # allow all
    end
end
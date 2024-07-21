require_dependency 'markazuna/di_container'

class Insurances::ContactTimesController < ApplicationController
    include Markazuna::INJECT['contact_time_service']

    # http://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html
    wrap_parameters :contact_time, include: [:start_time, :end_time, :is_active, :is_deleted]

    def index
        query = query_params.reject{|_, v| v.blank? || v == 'null'}

        contact_times, page_count = contact_time_service.find_contact_times(query)
        if (contact_times.size > 0)
            respond_to do |format|
                format.json { render :json => { results: contact_times, count: page_count }}
            end
        else
            render :json => { results: []}
        end
    end

    def delete
        status, page_count = contact_time_service.delete_contact_time(params[:id])
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
        contact_time_form = Insurances::ContactTimeForm.new(contact_time_form_params)
        if contact_time_service.create_contact_time(contact_time_form)
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
        contact_time = contact_time_service.find_contact_time(id)

        if contact_time
            respond_to do |format|
                format.json { render :json => { status: "200", payload: contact_time } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def update
        contact_time_form = Insurances::ContactTimeForm.new(contact_time_form_params)
        if contact_time_service.update_contact_time(contact_time_form)
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
        params.permit(:start_time, :end_time, :is_active, :is_deleted, :page, :search).to_h
    end

    # Using strong parameters
    def contact_time_form_params
        params.require(:contact_time).permit(:start_time, :end_time, :is_active, :is_deleted)
        # params.require(:core_user).permit! # allow all
    end
end
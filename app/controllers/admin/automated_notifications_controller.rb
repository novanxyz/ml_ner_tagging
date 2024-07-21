require_dependency 'markazuna/di_container'

class Admin::AutomatedNotificationsController < ApplicationController
    include Markazuna::INJECT['automated_notification_service']

    # http://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html
    wrap_parameters :automated_notification, include: [:number_of_time, :unit_of_time, :event, :message, :is_repeat]

    def index
        query = query_params.reject{|_, v| v.blank? || v == 'null'}

        automated_notifications, page_count = automated_notification_service.find_automated_notifications(query)
        if (automated_notifications.size > 0)
            respond_to do |format|
                format.json { render :json => { results: automated_notifications, count: page_count }}
            end
        else
            render :json => { results: []}
        end
    end

    def delete
        status, page_count = automated_notification_service.delete_automated_notification(params[:id])
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
        automated_notification_form = Admin::AutomatedNotificationForm.new(automated_notification_form_params)
        if automated_notification_service.create_automated_notification(automated_notification_form)
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
        automated_notification = automated_notification_service.find_automated_notification(id)

        if automated_notification
            respond_to do |format|
                format.json { render :json => { status: "200", payload: automated_notification } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def update
        automated_notification_form = Admin::AutomatedNotificationForm.new(automated_notification_form_params)
        if automated_notification_service.update_automated_notification(automated_notification_form)
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
        params.permit(:automated_notification).permit(:number_of_time, :unit_of_time, :event, :message, :is_repeat, :page, :search).to_h
    end

    # Using strong parameters
    def automated_notification_form_params
        params.require(:automated_notification).permit(:number_of_time, :unit_of_time, :event, :message, :is_repeat)
        # params.require(:core_user).permit! # allow all
    end
end
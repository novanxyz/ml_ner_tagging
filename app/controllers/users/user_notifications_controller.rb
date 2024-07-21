require_dependency 'markazuna/di_container'

class Users::UserNotificationsController < ApplicationController
    include Markazuna::INJECT['notification_service']

    # http://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html
    wrap_parameters :user_notification, include: [:id, :firstname, :lastname]

    def index
        query = query_params.reject{|_, v| v.blank? || v == 'null'}

        user_notifications, page_count = notification_service.find_notifications(query)
        if (user_notifications.size > 0)
            respond_to do |format|
                format.json { render :json => { results: user_notifications, count: page_count }}
            end
        else
            render :json => { results: []}
        end
    end

    def delete
        status, page_count = notification_service.delete_notification(params[:id])
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
        res = notification_service.send_notification(params)        
        if res == true
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
        user_notification = notification_service.find_user_notification(id)

        if user_notification
            respond_to do |format|
                format.json { render :json => { status: "200", payload: user_notification } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def upload
        puts params
        title = params[:user_notification_id]
        image_url = Upload.magazine_upload_to_cloudinary_with_params(params[:notification][:image], "user_notifications/#{title.downcase.gsub(' ', '_') + "_" + Time.now.to_i.to_s}", ['user_notification'])
        image_url = image_url['url']
    end

    def update
        user_notification_form = Users::UserNotificationForm.new(user_notification_form_params)
        if notification_service.update_user_notification(user_notification_form)
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
        params.permit(:id, :firstname, :lastname, :page, :search).to_h
    end

    # Using strong parameters
    def user_notification_form_params
        params.require(:user_notification).permit(:id, :firstname, :lastname)
        # params.require(:core_user).permit! # allow all
    end
end
class Users::NotificationService
    def create_notification(notification_form)
        notification_form.save
    end

    def update_notification(notification_form)
        notification_form.update
    end

    def delete_notification(id)
        notification = find_notification(id)
        return notification.delete, Users::Notification.page(1).total_pages
    end

    def find_notification(id)
        Users::Notification.find(id)
    end

    def find_notifications(query)
        page = query.delete(:page).to_i        
        query = {}  ## Configure the search first
        res = Users::Notification.where(query).order_by({:send_time => -1})
        total_pages = ( res.count().to_f / Users::Notification.default_per_page ).ceil  #res.total_pages    
        return res.page(page) , total_pages        
    end

    def send_notification(params )
        if params[:notif_type] == 'deeplink'
            bundle = deeplink_bundle(params)
        else
            bundle = message_bundle (params)
        end

        SendUserNotificationJob.perform_later(bundle, params[:option], params[:article_id], params[:interest_ids], params[:user_ids] )
        
    end

    def deeplink_bundle(article_id)
        {
            category: 'notif_backoffice',
            data: {
                title: params[:notification][:title_notif_all_user],
                message: params[:notification][:message_all_user],
                image_url: new_image,
                metadata: "",
                type: params[:notification][:select_type_all_user],
                icon: icon_url
            }
        }
    end
    def message_bundle(params)

        {
            category: 'notif_backoffice',
            data: {
                title: params[:notification][:title_notif_all_user],
                message: params[:notification][:message_all_user],
                image_url: new_image,
                metadata: "",
                type: params[:notification][:select_type_all_user],
                icon: icon_url
            }
        }
    end

    
end

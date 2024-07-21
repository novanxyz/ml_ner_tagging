class Admin::AutomatedNotificationService
    def create_automated_notification(automated_notification_form)
        automated_notification_form.save
    end

    def update_automated_notification(automated_notification_form)
        automated_notification_form.update
    end

    def delete_automated_notification(id)
        automated_notification = find_automated_notification(id)
        return automated_notification.delete, Admin::AutomatedNotification.page(1).total_pages
    end

    def find_automated_notification(id)
        Admin::AutomatedNotification.find(id)
    end

    def find_automated_notifications(query)
        page = query.delete(:page).to_i        
        query = {}  ## Configure the search first
        res = Admin::AutomatedNotification.where(query)
        total_pages = ( res.count() / Admin::AutomatedNotification.default_per_page ).ceil  #res.total_pages    
        return res.page(page) , total_pages
        return Admin::AutomatedNotification.page(page), Admin::AutomatedNotification.page(1).total_pages
    end
end

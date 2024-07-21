class Admin::MagazineService
    def create_magazine(magazine_form)
        magazine_form.save
    end

    def update_magazine(magazine_form)
        magazine_form.update
    end

    def delete_magazine(id)
        magazine = find_magazine(id)
        return magazine.delete, Admin::Magazine.page(1).total_pages
    end

    def find_magazine(id)
        Admin::Magazine.find(id)
    end

    def find_magazines(query)
        page = query.delete(:page).to_i        
        query = {}  ## Configure the search first
        res = Admin::Magazine.where(query)
        total_pages = ( res.count().to_f / Admin::Magazine.default_per_page ).ceil  #res.total_pages    
        return res.page(page) , total_pages
    end

    def send_notification(title)
        role = Core::Role.find_by(name: 'member')
        registration_ids = role.users.where(is_active: true, :user_agent.ne => 'ios').pluck(:device_token)
        registration_ids_ios = role.users.where(is_active: true, user_agent: 'ios').pluck(:device_token)
        # send notification
        message = {message: "New Magazine: #{title}"}
        begin
            notification = {
                body: message,
                title: 'New Magazine',
                sound: "default"
            }
            # Gcm.send_notification(message, registration_ids, 'new_magazine') if !registration_ids.empty?
            Fcm.send_message(message, registration_ids, 'new_magazine') if !registration_ids.empty?
            Fcm.send_message_for_ios(message, registration_ids_ios, notification,'new_magazine') if !registration_ids_ios.empty?
        rescue
            Rails.logger.info "################ FCM OpenTimeout (send_notification) ################"
        end
    end
end

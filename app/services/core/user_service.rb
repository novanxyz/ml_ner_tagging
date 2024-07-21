class Core::UserService
    include Fcm

    def create_user(user_form)
        user_form.save
    end

    def update_user(user_form)
        user_form.update        
    end

    def delete_user(id)
        user = find_user(id)
        return user.delete, Core::User.page(1).total_pages
    end

    def find_user(id)
        Core::User.find(id)
    end

    def find_users(query)
        page = query.delete(:page).to_i        
        if query.key?"search"
            q = query.delete("search")            
            query[:$or] = [ {:firstname => /.*#{q}.*/i}, { :lastname => /.*#{q}.*/i }, { :email => /.*#{q}.*/i } ]
        end        
        res = Core::User.where(query)
        total_pages = ( res.count() / Core::User.default_per_page ).ceil  #res.total_pages    
        return res.page(page) , total_pages
    end


    def collect_device_token(log_user_notification, total_user, option, device_tokens, device_tokens_ios, skip, range_limit, limit, user_ids, bundle, total_success, total_failure, interest_ids)
        Rails.logger.info "SendUserNotificationJob => Call Method Send Fcm"
        if option == "user_selection"
            user_device_tokens = Core::User.where(:device_token.ne=>nil, _type: 'Core::User', :user_agent.ne => 'ios').in(id: user_ids).skip(skip).limit(limit).pluck(:device_token)
            user_device_tokens_ios = Core::User.where(:device_token.ne=>nil, _type: 'Core::User', user_agent: 'ios').in(id: user_ids).skip(skip).limit(limit).pluck(:device_token)
        elsif option == "user_interest"
            user_device_tokens = Core::User.where(:device_token.ne=> nil, _type: 'Core::User', :user_agent.ne => 'ios').in(interest_ids: Core::Interest.where(is_deleted: false).in(id: interest_ids).pluck(:id)).skip(skip).limit(limit).pluck(:device_token)
            user_device_tokens_ios = Core::User.where(:device_token.ne=> nil, _type: 'Core::User', user_agent:'ios').in(interest_ids: Core::Interest.where(is_deleted: false).in(id: interest_ids).pluck(:id)).skip(skip).limit(limit).pluck(:device_token)
        else
            user_device_tokens = Core::User.where(:device_token.ne=>nil, _type: 'Core::User', :user_agent.ne => 'ios').skip(skip).limit(limit).pluck(:device_token)
            user_device_tokens_ios = Core::User.where(:device_token.ne=>nil, _type: 'Core::User', user_agent: 'ios').skip(skip).limit(limit).pluck(:device_token)
        end

        skip += range_limit
        limit += range_limit
        device_tokens = device_tokens + user_device_tokens
        device_tokens_ios = device_tokens_ios + user_device_tokens_ios

        begin
            fcm = Fcm.send_message_notification(bundle, device_tokens, 'notif_backoffice')
            raw = JSON.parse(fcm[:body]) rescue nil
            if raw.present?
                log_user_notification.inc(total_success: raw["success"], total_failure: raw["failure"])
            else
                Rails.logger.info "SendUserNotificationJob => Send Fcm Time Out 1"
                p "SendUserNotificationJob => Send Fcm Time Out 1"
            end
        rescue
            Rails.logger.info "SendUserNotificationJob => Send Fcm Time Out 2"
            p "SendUserNotificationJob => Send Fcm Time Out 2"
        end

        begin
            notification = {
                body: bundle[:data][:message],
                title: bundle[:data][:title],
                sound: "default"
            }
            fcm_for_ios = Fcm.send_message_notification_for_ios(bundle, device_tokens_ios, notification, 'notif_backoffice')
            raw_ios = JSON.parse(fcm_for_ios[:body]) rescue nil
            if raw_ios.present?
                log_user_notification.inc(total_success: raw_ios["success"], total_failure: raw_ios["failure"])
            else
                Rails.logger.info "SendUserNotificationJob => Send Fcm Time Out 3"
                p "SendUserNotificationJob => Send Fcm Time Out 3"
            end
        rescue
            Rails.logger.info "SendUserNotificationJob => Send Fcm Time Out 4"
            p "SendUserNotificationJob => Send Fcm Time Out 4"
        end

        return self.collect_device_token(log_user_notification, total_user, option, device_tokens, device_tokens_ios, skip, range_limit, limit, user_ids, bundle, total_success, total_failure, interest_ids) if limit <= total_user

        "SendUserNotificationJob => Some Notification already sent"
    end
end

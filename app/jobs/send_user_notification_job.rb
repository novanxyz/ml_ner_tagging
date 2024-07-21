class SendUserNotificationJob < ActiveJob::Base
    #queue_as :alomobile

    def perform(bundle, option, article_id, interest_ids, user_ids)
        begin
            if article_id.present?
                data_article_id = article_id
                type_message = "article"
                message = bundle[:data][:title]
            else
                data_article_id = nil
                type_message = "text"
                message = bundle[:data][:message]
            end

            log_user_notification = Core::LogUserNotification.new(article_id: data_article_id, message: message, send_time: Time.now.utc, total_success: 0, total_failure: 0, total_click: 0,type_message: type_message)
            if log_user_notification.save
                if article_id.present?
                    metadatas = bundle[:data][:metadata].split('/')
                    bundle[:data][:metadata] = "#{metadatas[0]}/#{log_user_notification.id}/#{metadatas[1]}"
                end

                role = Core::Role.find_by(name: 'member')
                if !role.nil?
                    range_limit = Core::Setting.find_by(method: 'limit_user_blast_fcm').value.to_i rescue 500

                    current_timestamp = Time.now.to_i
                    begin
                        Rails.logger.info "SendUserNotificationJob => Current Timestamp #{current_timestamp.to_s}"
                        if option == "user_selection"
                            device_tokens = Core::User.only(:device_token).where(:id.in=>user_ids, :blast_timestamp.lt=> current_timestamp, is_fcm_registered: true, role: role, :device_token.nin=>[nil, ""]).hint({_id: 1, blast_timestamp: 1, is_fcm_registered: 1, role_id: 1, device_token: 1}).page(1).per(range_limit).pluck(:user_agent, :device_token)
                            Rails.logger.info "SendUserNotificationJob => User Selected => Range Limit #{range_limit.to_s} => Device Tokens => #{device_tokens}"
                        elsif option == "user_interest"
                            device_tokens = Core::User.only(:device_token).where(:interest_ids.in=> interest_ids, :blast_timestamp.lt=> current_timestamp, is_fcm_registered: true, role: role, :device_token.nin=>[nil, ""]).hint({interest_ids: 1, blast_timestamp: 1, is_fcm_registered: 1, role_id: 1, device_token: 1}).page(1).per(range_limit).pluck(:user_agent, :device_token)
                            Rails.logger.info "SendUserNotificationJob => Interest => Range Limit #{range_limit.to_s} => Device Tokens => #{device_tokens}"
                        else
                            device_tokens = Core::User.only(:device_token).where(:blast_timestamp.lt=> current_timestamp, is_fcm_registered: true, role: role, :device_token.nin=>[nil, ""]).hint({blast_timestamp: 1, is_fcm_registered: 1, role_id: 1, device_token: 1}).page(1).per(range_limit).pluck(:user_agent, :device_token)
                            Rails.logger.info "SendUserNotificationJob => All => Range Limit #{range_limit.to_s} => Device Tokens => #{device_tokens}"
                        end

                        time_sleep = Core::Setting.find_by(method: 'sleep_fcm').value.to_f rescue 0.5
                        counter = 1
                        ## just for controling loop
                        max_counter = Core::Setting.find_by(method: 'max_counter_user_blast').value.to_i rescue 0

                        while !device_tokens.empty? do

                            device_tokens.group_by{|x| x[0] }.each do |k, v|
                                group_device_tokens = v.map{|x| x[1] }
                                if k == 'ios'
                                    notification = {
                                        body: bundle[:data][:message],
                                        title: bundle[:data][:title],
                                        sound: "default"
                                    }
                                    fcm = Fcm.send_message_notification_for_ios(bundle, group_device_tokens, notification, 'notif_backoffice')
                                else
                                    fcm = Fcm.send_message_notification(bundle, group_device_tokens, 'notif_backoffice')
                                end

                                Rails.logger.info "SendUserNotificationJob => FCM RESPONSE #{fcm}"
                                raw = JSON.parse(fcm[:body]) rescue nil
                                if !raw.nil?
                                    log_user_notification.total_success += raw["success"]
                                    log_user_notification.total_failure += raw["failure"]
                                    if log_user_notification.save
                                        Rails.logger.info "SendUserNotificationJob => Save Log User Successfully"
                                    else
                                        Rails.logger.info "SendUserNotificationJob => Save Log User Failed"
                                    end
                                else
                                    Rails.logger.info "SendUserNotificationJob => Fcm Response Body Not Exists #{fcm}"
                                end

                                if !fcm[:not_registered_ids].empty?
                                    total_user_unregistered = Core::User.in(device_token: fcm[:not_registered_ids]).hint({device_token: 1}).page(1).per(range_limit).total_pages
                                    for i in 1..total_user_unregistered
                                        users = Core::User.in(device_token: fcm[:not_registered_ids]).hint({device_token: 1}).page(i).per(range_limit)
                                        if users.update_all(is_fcm_registered: false, blast_timestamp: current_timestamp)
                                            Rails.logger.info "SendUserNotificationJob => Update User Not Registered Successfully"
                                        else
                                            Rails.logger.info "SendUserNotificationJob => Update User Not Registered Failed"
                                        end

                                        sleep(time_sleep)
                                    end
                                else
                                    Rails.logger.info "SendUserNotificationJob => Fcm Response Not Registered Empty #{fcm}"
                                end

                                success_tokens = group_device_tokens - fcm[:not_registered_ids]


                                total_user_registered = Core::User.in(device_token: success_tokens).hint({device_token: 1}).page(1).per(range_limit).total_pages
                                for i in 1..total_user_registered
                                    users = Core::User.in(device_token: success_tokens).hint({device_token: 1}).page(i).per(range_limit)
                                    if users.update_all(blast_timestamp: current_timestamp)
                                        Rails.logger.info "SendUserNotificationJob => Update User Not Registered Successfully"
                                    else
                                        Rails.logger.info "SendUserNotificationJob => Update User Not Registered Failed"
                                    end

                                    sleep(time_sleep)
                                end

                                break if max_counter > 0 && counter == max_counter
                            end
                            sleep(time_sleep)

                            if option == "user_selection"
                                device_tokens = Core::User.only(:device_token).where(:id.in=>user_ids, :blast_timestamp.lt=> current_timestamp, is_fcm_registered: true, role: role, :device_token.nin=>[nil, ""]).hint({blast_timestamp: 1, is_fcm_registered: 1, role_id: 1, device_token: 1}).page(1).per(range_limit).pluck(:user_agent, :device_token)
                                Rails.logger.info "SendUserNotificationJob => User Selected => Range Limit #{range_limit.to_s} => Device Tokens => #{device_tokens}"
                            elsif option == "user_interest"
                                device_tokens = Core::User.only(:device_token).where(:interest_ids.in=> interest_ids, :blast_timestamp.lt=> current_timestamp, is_fcm_registered: true, role: role, :device_token.nin=>[nil, ""]).hint({interest_ids: 1, blast_timestamp: 1, is_fcm_registered: 1, role_id: 1, device_token: 1}).page(1).per(range_limit).pluck(:user_agent, :device_token)
                                Rails.logger.info "SendUserNotificationJob => Interest => Range Limit #{range_limit.to_s} => Device Tokens => #{device_tokens}"
                            else
                                device_tokens = Core::User.only(:device_token).where(:blast_timestamp.lt=> current_timestamp, is_fcm_registered: true, role: role, :device_token.nin=>[nil, ""]).hint({blast_timestamp: 1, is_fcm_registered: 1, role_id: 1, device_token: 1}).page(1).per(range_limit).pluck(:user_agent, :device_token)
                                Rails.logger.info "SendUserNotificationJob => All => Range Limit #{range_limit.to_s} => Device Tokens => #{device_tokens}"
                            end

                            counter += 1

                            device_tokens
                        end

                    rescue Exception => ex
                        if log_user_notification
                            Core::ErrorBucket.create(log_user_notification_id: log_user_notification.id.to_s, error_message: "Problem 2 : #{ex}")
                        end
                        Rails.logger.info "SendUserNotificationJob => Problem 2 => #{ex}"
                    end
                else
                    Rails.logger.info "SendUserNotificationJob => Role not found"
                end
            else
                Rails.logger.info "SendUserNotificationJob => Save First Log Notification Failed"
            end
        rescue Exception => ex
            Core::ErrorBucket.create(error_message: "Problem 1 : #{ex}")
            Rails.logger.info "SendUserNotificationJob => Problem 1 => #{ex}"
        end
    end
end
module Fcm
    require 'fcm'
    #GCM_API_KEY = 'AAAABuEmSS8:APA91bGGdELbS9ifxEqkposTcHN06kgX0F7W3ab2jvVDbobJ7s5xaDS2eivjkebKaUWAZ5KkumiDFuo0PvA--oM5DnxBDBKo8fZgRNRJAMeu6WdzYiecfeP7Fzvkr03RAOSdiQm9ajU6' # TODO make this key on environment variable
    FCM_API_KEY = ENV['FCM_API_KEY']
    FCM_API_KEY_FOR_IOS = ENV['FCM_API_KEY_FOR_IOS']

    # TODO need to rework on this to handle GCM response
    def self.send_message(message, registration_ids, collapse_key)
        fcm = FCM.new(FCM_API_KEY)
        options = { data: message, collapse_key: collapse_key }
        response = fcm.send(registration_ids, options)
        Rails.logger.info "##################################### FCM Response is #{registration_ids}"
        Rails.logger.info "##################################### FCM Response is #{options}"
        Rails.logger.info "##################################### FCM Response is #{response[:status_code]}"
        Rails.logger.info "##################################### FCM Response is #{response[:body]}"
    end

    def self.send_message_for_ios(message, registration_ids, notification, collapse_key)
        fcm = FCM.new(FCM_API_KEY_FOR_IOS)
        if message[:reply_object].present? && !message[:category].present?
            message[:category] = 'reply_object'
        end
        if !message[:data].present? && message[:reply_object].present?
            message[:data] = message[:reply_object]
            message.delete(:reply_object)
        end
        options = {id: registration_ids, data: message, notification: notification, collapse_key: collapse_key }
        response = fcm.send(registration_ids, options)
        Rails.logger.info "##################################### FCM Response ios #{registration_ids}"
        Rails.logger.info "##################################### FCM Response ios #{options}"
        Rails.logger.info "##################################### FCM Response ios #{response[:status_code]}"
        Rails.logger.info "##################################### FCM Response ios #{response[:body]}"
    end

    def self.send_message_notification(message, registration_ids, collapse_key)
        fcm = FCM.new(FCM_API_KEY)
        options = { data: message, collapse_key: collapse_key }
        response = fcm.send(registration_ids, options)
        Rails.logger.info "##################################### FCM Response is #{registration_ids}"
        Rails.logger.info "##################################### FCM Response is #{options}"
        Rails.logger.info "##################################### FCM Response is #{response[:status_code]}"
        Rails.logger.info "##################################### FCM Response is #{response[:body]}"
        response
    end

    def self.send_message_notification_for_ios(message, registration_ids, notification, collapse_key)
        fcm = FCM.new(FCM_API_KEY_FOR_IOS)
        if message[:reply_object].present? && !message[:category].present?
            message[:category] = 'reply_object'
        end
        if !message[:data].present? && message[:reply_object].present?
            message[:data] = message[:reply_object]
            message.delete(:reply_object)
        end
        options = {id: registration_ids, data: message, notification: notification, collapse_key: collapse_key }
        response = fcm.send(registration_ids, options)
        Rails.logger.info "##################################### FCM Response ios #{registration_ids}"
        Rails.logger.info "##################################### FCM Response ios #{options}"
        Rails.logger.info "##################################### FCM Response ios #{response[:status_code]}"
        Rails.logger.info "##################################### FCM Response ios #{response[:body]}"
        response
    end

    def self.send_message_bot(message, registration_ids, collapse_key)
        fcm = FCM.new(FCM_API_KEY)
        options = { data: message, collapse_key: collapse_key, priority: 'high' }
        response = fcm.send(registration_ids, options)
        Rails.logger.info "##################################### FCM Response is #{registration_ids}"
        Rails.logger.info "##################################### FCM Response is #{options}"
        Rails.logger.info "##################################### FCM Response is #{response[:status_code]}"
        Rails.logger.info "##################################### FCM Response is #{response[:body]}"
        response
    end

    def self.send_message_new(message, registration_ids, collapse_key, user, question)
        fcm = FCM.new(FCM_API_KEY)
        options = { data: message, collapse_key: collapse_key }
        response = fcm.send(registration_ids, options)
        Rails.logger.info "##################################### FCM Response is #{registration_ids}"
        Rails.logger.info "##################################### FCM Response is #{options}"
        Rails.logger.info "##################################### FCM Response is #{response[:status_code]} to #{user} on question #{question}"
        Rails.logger.info "##################################### FCM Response is #{response[:body]}"
    end

    def self.detail_info(token)
        response = HTTParty.get("https://iid.googleapis.com/iid/info/"+token+"?details=true", :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json', 'Authorization' => 'key=' + ENV['FCM_API_KEY']})
        puts "####################### DETAIL INFO ######################"
        Rails.logger.info "####################### DETAIL INFO ######################"
        puts response
        Rails.logger.info response
        response
    end

    def self.subscribe_to_topic(key, token)
        response = HTTParty.post("https://iid.googleapis.com/iid/v1:batchAdd", body: { :to => '/topics/' + key, :registration_tokens => token }.to_json, :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json', 'Authorization' => 'key=' + ENV['FCM_API_KEY']})
        puts "################### SUBSCRIBE STATUS ###################"
        Rails.logger.info "################### SUBSCRIBE STATUS ###################"
        puts response
        Rails.logger.info response
        puts "################### SUBSCRIBE STATUS ###################"
        Rails.logger.info "################### SUBSCRIBE STATUS ###################"
        response
    end

    def self.unsubscribe_to_topic(key, token)
        response = HTTParty.post("https://iid.googleapis.com/iid/v1:batchRemove", body: { :to => '/topics/' + key, :registration_tokens => token }.to_json, :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json', 'Authorization' => 'key=' + ENV['FCM_API_KEY']})
        puts "################### UNSUBSCRIBE STATUS ###################"
        Rails.logger.info "################### UNSUBSCRIBE STATUS ###################"
        puts response
        Rails.logger.info response
        puts "################### UNSUBSCRIBE STATUS ###################"
        Rails.logger.info "################### UNSUBSCRIBE STATUS ###################"
        response
    end

    def self.send_to_topic(data)
        ## example body : { data: {category: "doctor_notif_backoffice", data: {title: "test", message: "test", image_url: "http://....", metadata: "", type: "message"}}, "to": "/topics/jantung" }

        response = HTTParty.post("https://fcm.googleapis.com/fcm/send", body: data.to_json, :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json', 'Authorization' => 'key=' + ENV['FCM_API_KEY']})
        puts "===================== RESPONSE BY TOPIC ========================"
        Rails.logger.info "======================= RESPONSE BY TOPIC ======================"
        puts response
        Rails.logger.info response
        response
    end

    def self.send_to_mulltiple_topic(data)
        ## example body : { data: {category: "doctor_notif_backoffice", data: {title: "test", message: "test", image_url: "http://....", metadata: "", type: "message"}}, "condition": "'jantung' in topics && 'paru2' in topics" }

        response = HTTParty.post("https://fcm.googleapis.com/fcm/send", body: data.to_json, :headers => { 'Content-Type' => 'application/json', 'Accept' => 'application/json', 'Authorization' => 'key=' + ENV['FCM_API_KEY']})
        puts "===================== RESPONSE BY TOPIC ========================"
        Rails.logger.info "======================= RESPONSE BY TOPIC ======================"
        puts response
        Rails.logger.info response
        response
    end


    # new method for send fcm
    def self.new_send_message(send_to, message, collapse_key)
        fcm = FCM.new(FCM_API_KEY)
        #options = { data: message, collapse_key: collapse_key }
        options = { data: message }
        response = fcm.send_with_notification_key(send_to, options)

        # response = HTTParty.post("https://fcm.googleapis.com/fcm/send", body: { :to => send_to, :data => bundle }.to_json, :headers => { 'Content-Type' => 'application/json', 'Authorization' => "key=#{ENV['FCM_API_KEY']}"})
        Rails.logger.info "##################################### FCM Response is #{send_to}"
        Rails.logger.info "##################################### FCM Response is #{options}"
        Rails.logger.info "##################################### FCM Response is #{response[:status_code]}"
        Rails.logger.info "##################################### FCM Response is #{response[:body]}"
        response
    end

    # method for iOS
    def self.new_send_message_for_ios(send_to, message, notification, collapse_key)
        fcm = FCM.new(FCM_API_KEY_FOR_IOS)
        if message[:reply_object].present? && !message[:category].present?
            message[:category] = 'reply_object'
        end
        if !message[:data].present? && message[:reply_object].present?
            message[:data] = message[:reply_object]
            message.delete(:reply_object)
        end
        options = {id: send_to, data: message, notification: notification}
        response = fcm.send_with_notification_key(send_to, options)

        Rails.logger.info "##################################### FCM Response ios #{send_to}"
        Rails.logger.info "##################################### FCM Response ios #{options}"
        Rails.logger.info "##################################### FCM Response ios #{response[:status_code]}"
        Rails.logger.info "##################################### FCM Response ios #{response[:body]}"
        response
    end
end
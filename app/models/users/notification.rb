require 'markazuna/common_model'

class Users::Notification
	include Mongoid::Document
    include Markazuna::CommonModel
    store_in collection: 'log_user_notifications'

    # kaminari page setting
    paginates_per 20
	
    field :id, type: String, default: ''	
    field :article_id, type: String
    field :message, type: String
    field :send_time, type: DateTime
    field :total_success, type: Integer, default: 0
    field :total_failure, type: Integer, default: 0
    field :total_click, type: Integer, default: 0
    field :type_message, type: String

    default_scope { order(send_time: :desc) }

end
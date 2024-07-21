require 'markazuna/common_model'

class Admin::AutomatedNotification
	include Mongoid::Document
    include Markazuna::CommonModel
    store_in collection: 'automated_notifications'

    # kaminari page setting
    paginates_per 20
	
    field :number_of_time, type: Integer, default: ''	
    field :unit_of_time, type: Integer, default: ''	
    field :event, type: String, default: ''	
    field :message, type: String, default: ''	
    field :is_repeat, type: Boolean, default: ''	
end

require 'markazuna/common_model'

class Insurances::Provider
	include Mongoid::Document
    include Markazuna::CommonModel
    store_in collection: 'providers'

    # kaminari page setting
    paginates_per 20
	
    field :name, type: String, default: ''	
    field :description, type: String, default: ''	
    field :icon_url, type: String, default: ''	
    field :mobile_phone, type: String, default: ''	
    field :is_active, type: Boolean, default: ''	
end

require 'markazuna/common_model'

class Insurances::Quota
	include Mongoid::Document
    include Markazuna::CommonModel
    store_in collection: 'quotas'

    # kaminari page setting
    paginates_per 20
    
    field :type, type: String
    field :start_date, type: Date, default: ''	
    field :end_date, type: Date, default: ''	
    field :total_quota, type: Integer, default: ''	
    field :remaining_quota, type: Integer, default: ''	
    field :is_unlimited, type: Boolean, default: ''	
    field :is_freeze, type: Boolean, default: ''
    
    belongs_to :sourceable, polymorphic: true
end

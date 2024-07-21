require 'markazuna/common_model'

class Admin::Statistic
	include Mongoid::Document
    include Markazuna::CommonModel
    store_in collection: 'statistics'

    # kaminari page setting
    paginates_per 20
	
    field :name, type: String, default: ''	
    field :label, type: String, default: ''	
    field :value, type: Float, default: 0	
    field :delta, type: Float, default: 0	
    field :stat_time, type: DateTime, default: ''	

    field :view_type, type: String, default: ''	
end

require 'markazuna/common_model'

class Core::DivisionAction
	include Mongoid::Document
    include Markazuna::CommonModel
    store_in collection: 'division_actions'

    # kaminari page setting
    paginates_per 20
	
    field :name, type: String, default: ''	
    field :path, type: String, default: ''	
    field :is_deleted, type: Boolean, default: ''	

    belongs_to :area, class_name: 'Core::DivisionArea'

    scope :get_actions, -> { where(is_deleted: false) }
    
end

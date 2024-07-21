require 'markazuna/common_model'

class Core::Role
	include Mongoid::Document
    include Markazuna::CommonModel
    store_in collection: 'roles'

    # kaminari page setting
    paginates_per 20
    has_many :users, :class_name => 'Core::User'
    
    field :name, type: String, default: ''	
end

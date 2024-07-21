require 'markazuna/common_model'

class Core::Interest
	include Mongoid::Document
    include Markazuna::CommonModel
    store_in collection: 'interests'

    # kaminari page setting
    paginates_per 20
	
    field :name, type: String, default: ''	
    field :is_deleted, type: Boolean, default: ''	
end

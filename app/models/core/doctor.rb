require 'markazuna/common_model'

class Core::Doctor < Core::User
	include Mongoid::Document
    include Markazuna::CommonModel
    # kaminari page setting
    paginates_per 10
	
    field :uid, type: String, default: ''	
    field :rate, type: Integer, default: ''	
    field :price, type: Integer, default: ''	
    field :thanks, type: Integer, default: ''	
end

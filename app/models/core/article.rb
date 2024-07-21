require 'markazuna/common_model'

class Core::Article
	include Mongoid::Document
    include Markazuna::CommonModel
    store_in collection: 'articles'

    # kaminari page setting
    paginates_per 20
	
    field :title, type: String, default: ''
    field :content, type: String, default: ''
    field :slug, type: String, default: ''

    def to_param
        slug
    end
end

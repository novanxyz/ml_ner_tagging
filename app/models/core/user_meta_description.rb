require 'markazuna/common_model'

class Core::UserMetaDescription
	include Mongoid::Document
    include Markazuna::CommonModel
	store_in collection: 'meta_descriptions'

    # kaminari page setting
    paginates_per 20

    embedded_in :user, class_name: 'Core::User'
    belongs_to :meta_description, :class_name => 'Core::MetaDescription', index: true
    belongs_to :meta_description_value, :class_name => 'Core::MetaDescriptionValue', index: true

    field :text_value, type: String, default: ''	
end

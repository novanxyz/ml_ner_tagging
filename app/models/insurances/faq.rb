require 'markazuna/common_model'

class Insurances::Faq
	include Mongoid::Document
    include Markazuna::CommonModel
    store_in collection: 'insurance_faqs'

    # kaminari page setting
    paginates_per 20
	
    field :question, type: String, default: ''	
    field :answer, type: String, default: ''	
    field :position, type: String, default: ''	

    belongs_to :insurance_provider, class_name: 'Insurances::Provider'
end

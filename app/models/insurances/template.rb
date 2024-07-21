require 'markazuna/common_model'

class Insurances::Template
	include Mongoid::Document
    include Markazuna::CommonModel
    store_in collection: 'insurance_templates'

    # kaminari page setting
    paginates_per 20
	
    field :caption, type: String, default: ''	
    field :title_approval, type: String, default: ''	
    field :description_approval, type: String, default: ''	
    field :image_url_approval, type: String, default: ''	
    field :is_active, type: Boolean, default: true	

    # embeds_many :insurance_template_top_sliders, class_name: 'Insurances::TemplateTopSlider'
    # embeds_many :insurance_template_bottom_sliders, class_name: 'Insurances::TemplateBottomSlider'
    embeds_many :insurance_contact_times, class_name: 'Insurances::ContactTime'
  
    belongs_to :insurance_provider, :class_name => 'Insurances::Provider', index: true
  
    validates_presence_of :caption
    validates_presence_of :description_approval
end

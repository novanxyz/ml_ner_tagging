require 'markazuna/common_model'

class Core::Division
	include Mongoid::Document
    include Markazuna::CommonModel
    store_in collection: 'divisions'

    # kaminari page setting
    paginates_per 20
	
    field :name, type: String, default: ''	
    field :rule, type: String, default: ''	
    field :division_page, type: String, default: 'all'	
    field :is_deleted, type: Boolean, default: false

    attr_accessor :division_areas, :division_actions

#    has_and_belongs_to_many :actions, class_name: 'Core::DivisionAction', inverse_of: nil

    has_many :admins, class_name: 'Core::Admin'
    field :admin_cnt, type:Integer, default: 0

    validates_presence_of :name
    validates_uniqueness_of :name
    validates_presence_of :rule
    validates_presence_of :division_page
    validates_inclusion_of :rule, in: ['only', 'except']

    

    scope :get_divisions, -> { where(is_deleted: false) }

    def self.pagination(page = 0)
        self.page(page).per(20)
    end
    
    private
    def load_admins
        self.admins = Core::Admin.find({:division_id =>  self.id })
    end
    
end

require 'markazuna/common_model'

class Admin::City
	include Mongoid::Document
    include Markazuna::CommonModel
    store_in collection: 'cities'

    # kaminari page setting
    paginates_per 20
    
	field :name, type: String
    field :is_deleted, type: Boolean, default: ''
    field :coordinates, type: Array, default: []
    field :permalink, type: String, default: ''	
    field :uid, type: String, default: ''

    # attr_accessor :longitude, :latitude

    validates_presence_of :name
    # validates_presence_of :longitude
    # validates_presence_of :latitude
    validates_uniqueness_of :name
    # todo unique coordinates

    after_save :delete_cache_init_data
    after_update :delete_cache_init_data
    before_save :set_permalink
    before_create :set_uuid

    index({name: 1, is_deleted: 1})
    

    def latitude
        self.coordinates.first
    end

    def longitude
        self.coordinates.second
    end

    # def to_s
    #     self.name
    # end

    private

    def delete_cache_init_data
        #AloCache.delete_by_namespace('get_init_data_')
    end

    def set_permalink
        self.permalink = self.name.parameterize
    end

    def set_uuid
        self.uid = SecureRandom.uuid
    end

	
end

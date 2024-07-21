require 'markazuna/common_model'

class Insurances::ContactTime
	include Mongoid::Document
    include Markazuna::CommonModel
    store_in collection: 'insurance_contact_times'

    # kaminari page setting
    paginates_per 20
	
    field :start_time, type: Integer, default: ''	
    field :end_time, type: Integer, default: ''	
    field :is_active, type: Boolean, default: false	
    field :is_deleted, type: Boolean, default: false	

    embedded_in :insurance_template, class_name: 'Insurances::Template'


    def self.get_options
        where(is_active: true, is_deleted: false).map{|x| { id: x.id.to_s, time: x.contact_time }}
    end

    def contact_time
        "#{pretty_time(self.start_time)} - #{pretty_time(self.end_time)}"
    end

    def pretty_time(time)
        Time.at((time * 3600)).utc.strftime('%H:%M')
    end
end

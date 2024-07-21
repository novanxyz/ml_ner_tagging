class Admin::CityForm
    include ActiveModel::Model

    attr_accessor(:id, :name, :is_deleted, :coordinates, :permalink, :uid)

    # Validations
    
    validates :coordinates, presence: true    
    validates :permalink, presence: true    
    validates :uid, presence: true
    

    def save
        if valid?
            city = Admin::City.new(is_deleted: self.is_deleted, coordinates: self.coordinates, permalink: self.permalink, uid: self.uid)
            city.save
            true
        else
            false
        end
    end

    def update
        if valid?
            city = Admin::City.find(self.id)
            city.update_attributes!(is_deleted: self.is_deleted, coordinates: self.coordinates, permalink: self.permalink, uid: self.uid)
            true
        else
            false
        end
    end
end

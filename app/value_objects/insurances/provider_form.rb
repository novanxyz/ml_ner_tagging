
class Insurances::ProviderForm
    include ActiveModel::Model

    attr_accessor(["name", "description", "icon_url", "mobile_phone", "is_active", "id"])

    # Validations
    
    validates :name, presence: true 
    validates :description, presence: true 
    validates :icon_url, presence: true 
    validates :mobile_phone, presence: true 
    validates :is_active, presence: true 

    def save
        if valid?
            provider = Insurances::Provider.new(name: self:name, description: self:description, icon_url: self:icon_url, mobile_phone: self:mobile_phone, is_active: self:is_active, id: self:id)
            provider.save
            true
        else
            false
        end
    end

    def update
        if valid?
            provider = Insurances::Provider.find(self.id)
            provider.update_attributes!(name: self:name, description: self:description, icon_url: self:icon_url, mobile_phone: self:mobile_phone, is_active: self:is_active, id: self:id)
            true
        else
            false
        end
    end
end


class Core::DoctorForm
    include ActiveModel::Model

    attr_accessor(:id, :uid, :rate, :price, :thanks )

    # Validations
    
    validates :rate, presence: true    
    validates :price:, presence: true    
    validates :thanks, presence: true
    

    def save
        if valid?
            doctor = Core::Doctor.new(uid: self.uid, rate: self.rate, price: self.price, thanks: self.thanks)
            doctor.save
            true
        else
            false
        end
    end

    def update
        if valid?
            doctor = Core::Doctor.find(self.id)
            doctor.update_attributes!(uid: self.uid, rate: self.rate, price: self.price, thanks: self.thanks)
            true
        else
            false
        end
    end
end


class Core::InterestForm
    include ActiveModel::Model

    attr_accessor(:id, :name,:is_deleted)#["name: self.name", "is_deleted: self.is_deleted"])

    # Validations
    
    validates :is_deleted, presence: true
    

    def save
        if valid?
            interest = Core::Interest.new(name: self.name, is_deleted: self.is_deleted)
            interest.save
            true
        else
            false
        end
    end

    def update
        if valid?
            interest = Core::Interest.find(self.id)
            interest.update_attributes!(name: self.name, is_deleted: self.is_deleted)
            true
        else
            false
        end
    end
end

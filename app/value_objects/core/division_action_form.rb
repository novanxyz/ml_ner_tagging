
class Core::DivisionActionForm
    include ActiveModel::Model

    attr_accessor(:id, :name, :path, :is_deleted )

    # Validations
    
    validates :path, presence: true    
    validates :is_deleted, presence: true
    

    def save
        if valid?
            division_action = Core::DivisionAction.new(name: self.name, path: self.path, is_deleted: self.is_deleted )
            division_action.save
            true
        else
            false
        end
    end

    def update
        if valid?
            division_action = Core::DivisionAction.find(self.id)
            division_action.update_attributes!(name: self.name, path: self.path, is_deleted: self.is_deleted)
            true
        else
            false
        end
    end
end

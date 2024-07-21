
class Core::RoleForm
    include ActiveModel::Model

    attr_accessor(:id, :name )

    # Validations
    

    def save
        if valid?
            role = Core::Role.new(name: self.name)
            role.save
            true
        else
            false
        end
    end

    def update
        if valid?
            role = Core::Role.find(self.id)
            role.update_attributes!(name: self.name)
            true
        else
            false
        end
    end
end

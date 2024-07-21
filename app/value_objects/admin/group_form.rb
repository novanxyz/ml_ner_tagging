
class Admin::GroupForm
    include ActiveModel::Model

    attr_accessor(:id, :name, :description)

    # Validations
    validates :name, presence: true
    validates :description, presence: true

    def save
        if valid?
            group = Admin::Group.new(name: self.name, description: self.description)
            group.save
            true
        else
            false
        end
    end

    def update
        if valid?
            group = Admin::Group.find(self.id)
            group.update_attributes!(name: self.name, description: self.description)
            true
        else
            false
        end
    end
end

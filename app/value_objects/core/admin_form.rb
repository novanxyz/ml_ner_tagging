
class Core::AdminForm
    include ActiveModel::Model

    attr_accessor(:id, :email, :username, :firstname, :lastname, :password )

    # Validations
    
    validates :username, presence: true    
    validates :firstname, presence: true    
    validates :lastname, presence: true
    validates :password, presence: true
    

    def save
        if valid?
            admin = Core::Admin.new(email: self.email, username: self.username, firstname: self.firstname, lastname: self.lastname)
            admin.save
            true
        else
            false
        end
    end

    def update
        if valid?
            admin = Core::Admin.find(self.id)
            admin.update_attributes!(email: self.email, username: self.username, firstname: self.firstname, lastname: self.lastname)
            true
        else
            false
        end
    end
end

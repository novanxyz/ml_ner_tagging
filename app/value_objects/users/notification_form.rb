
class Users::NotificationForm
    include ActiveModel::Model

    attr_accessor(["id: self.id", "firstname: self.firstname", "lastname: self.lastname"])

    # Validations
    
    validates :firstname, presence: true
    
    validates :lastname, presence: true
    

    def save
        if valid?
            notification = Users::Notification.new(id: self.id, firstname: self.firstname, lastname: self.lastname)
            notification.save
            true
        else
            false
        end
    end

    def update
        if valid?
            notification = Users::Notification.find(self.id)
            notification.update_attributes!(id: self.id, firstname: self.firstname, lastname: self.lastname)
            true
        else
            false
        end
    end
end


class Users::UserNotificationForm
    include ActiveModel::Model

    attr_accessor(["id: self.id", "firstname: self.firstname", "lastname: self.lastname"])

    # Validations
    
    validates :firstname, presence: true
    
    validates :lastname, presence: true
    

    def save
        if valid?
            user_notification = Users::UserNotification.new(id: self.id, firstname: self.firstname, lastname: self.lastname)
            user_notification.save
            true
        else
            false
        end
    end

    def update
        if valid?
            user_notification = Users::UserNotification.find(self.id)
            user_notification.update_attributes!(id: self.id, firstname: self.firstname, lastname: self.lastname)
            true
        else
            false
        end
    end
end

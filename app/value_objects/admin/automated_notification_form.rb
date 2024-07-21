
class Admin::AutomatedNotificationForm
    include ActiveModel::Model

    attr_accessor(["number_of_time:Integer: self.number_of_time:Integer", "unit_of_time:Integer: self.unit_of_time:Integer", "event:String: self.event:String", "message:String: self.message:String", "is_repeat:Boolean: self.is_repeat:Boolean"])

    # Validations
    
    validates :unit_of_time:Integer, presence: true
    
    validates :event:String, presence: true
    
    validates :message:String, presence: true
    
    validates :is_repeat:Boolean, presence: true
    

    def save
        if valid?
            automated_notification = Admin::AutomatedNotification.new(number_of_time:Integer: self.number_of_time:Integer, unit_of_time:Integer: self.unit_of_time:Integer, event:String: self.event:String, message:String: self.message:String, is_repeat:Boolean: self.is_repeat:Boolean)
            automated_notification.save
            true
        else
            false
        end
    end

    def update
        if valid?
            automated_notification = Admin::AutomatedNotification.find(self.id)
            automated_notification.update_attributes!(number_of_time:Integer: self.number_of_time:Integer, unit_of_time:Integer: self.unit_of_time:Integer, event:String: self.event:String, message:String: self.message:String, is_repeat:Boolean: self.is_repeat:Boolean)
            true
        else
            false
        end
    end
end

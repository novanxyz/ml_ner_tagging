
class Insurances::ContactTimeForm
    include ActiveModel::Model

    attr_accessor(["start_time", "end_time", "is_active", "is_deleted", "id"])

    # Validations
    
    validates :start_time, presence: true 
    validates :end_time, presence: true 
    validates :is_active, presence: true 
    validates :is_deleted, presence: true 

    def save
        if valid?
            contact_time = Insurances::ContactTime.new(start_time: self:start_time, end_time: self:end_time, is_active: self:is_active, is_deleted: self:is_deleted, id: self:id)
            contact_time.save
            true
        else
            false
        end
    end

    def update
        if valid?
            contact_time = Insurances::ContactTime.find(self.id)
            contact_time.update_attributes!(start_time: self:start_time, end_time: self:end_time, is_active: self:is_active, is_deleted: self:is_deleted, id: self:id)
            true
        else
            false
        end
    end
end

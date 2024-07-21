
class Insurances::QuotaForm
    include ActiveModel::Model

    attr_accessor(["type: self.type", "start_date: self.start_date", "end_date: self.end_date", "total_quota: self.total_quota", "remaining_quota: self.remaining_quota", "is_unlimited: self.is_unlimited", "is_freeze: self.is_freeze"])

    # Validations
    
    validates :start_date, presence: true
    
    validates :end_date, presence: true
    
    validates :total_quota, presence: true
    
    validates :remaining_quota, presence: true
    
    validates :is_unlimited, presence: true
    
    validates :is_freeze, presence: true
    

    def save
        if valid?
            quota = Insurances::Quota.new(type: self.type, start_date: self.start_date, end_date: self.end_date, total_quota: self.total_quota, remaining_quota: self.remaining_quota, is_unlimited: self.is_unlimited, is_freeze: self.is_freeze)
            quota.save
            true
        else
            false
        end
    end

    def update
        if valid?
            quota = Insurances::Quota.find(self.id)
            quota.update_attributes!(type: self.type, start_date: self.start_date, end_date: self.end_date, total_quota: self.total_quota, remaining_quota: self.remaining_quota, is_unlimited: self.is_unlimited, is_freeze: self.is_freeze)
            true
        else
            false
        end
    end
end

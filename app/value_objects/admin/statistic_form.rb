
class Admin::StatisticForm
    include ActiveModel::Model

    attr_accessor(["name", "label", "value", "delta", "stat_time", "id"])

    # Validations
    
    validates :name, presence: true 
    validates :label, presence: true 
    validates :value, presence: true 
    validates :delta, presence: true 
    validates :stat_time, presence: true 

    def save
        if valid?
            statistic = Admin::Statistic.new(name: self:name, label: self:label, value: self:value, delta: self:delta, stat_time: self:stat_time, id: self:id)
            statistic.save
            true
        else
            false
        end
    end

    def update
        if valid?
            statistic = Admin::Statistic.find(self.id)
            statistic.update_attributes!(name: self:name, label: self:label, value: self:value, delta: self:delta, stat_time: self:stat_time, id: self:id)
            true
        else
            false
        end
    end
end

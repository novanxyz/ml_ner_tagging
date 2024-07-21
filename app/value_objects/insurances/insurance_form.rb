
class Insurances::InsuranceForm
    include ActiveModel::Model

    attr_accessor(["policy_number", "start_date", "end_date", "policy_holder", "status", "policy_type", "payment_end_date", "total_month_paid", "source", "fullname", "phone_number", "email", "file_policy", "file_policy_uploaded_at", "approved_date", "id"])

    # Validations
    
    validates :policy_number, presence: true 
    validates :start_date, presence: true 
    validates :end_date, presence: true 
    validates :policy_holder, presence: true 
    validates :status, presence: true 
    validates :policy_type, presence: true 
    validates :payment_end_date, presence: true 
    validates :total_month_paid, presence: true 
    validates :source, presence: true 
    validates :fullname, presence: true 
    validates :phone_number, presence: true 
    validates :email, presence: true 
    validates :file_policy, presence: true 
    validates :file_policy_uploaded_at, presence: true 
    validates :approved_date, presence: true 

    def save
        if valid?
            insurance = Insurances::Insurance.new(policy_number: self:policy_number, start_date: self:start_date, end_date: self:end_date, policy_holder: self:policy_holder, status: self:status, policy_type: self:policy_type, payment_end_date: self:payment_end_date, total_month_paid: self:total_month_paid, source: self:source, fullname: self:fullname, phone_number: self:phone_number, email: self:email, file_policy: self:file_policy, file_policy_uploaded_at: self:file_policy_uploaded_at, approved_date: self:approved_date, id: self:id)
            insurance.save
            true
        else
            false
        end
    end

    def update
        if valid?
            insurance = Insurances::Insurance.find(self.id)
            insurance.update_attributes!(policy_number: self:policy_number, start_date: self:start_date, end_date: self:end_date, policy_holder: self:policy_holder, status: self:status, policy_type: self:policy_type, payment_end_date: self:payment_end_date, total_month_paid: self:total_month_paid, source: self:source, fullname: self:fullname, phone_number: self:phone_number, email: self:email, file_policy: self:file_policy, file_policy_uploaded_at: self:file_policy_uploaded_at, approved_date: self:approved_date, id: self:id)
            true
        else
            false
        end
    end
end

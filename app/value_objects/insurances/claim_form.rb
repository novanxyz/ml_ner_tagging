
class Insurances::ClaimForm
    include ActiveModel::Model

    attr_accessor(["increment_claim:Integer: self.increment_claim:Integer", "clain_number:String: self.clain_number:String", "reject_time:DateTime: self.reject_time:DateTime", "accept_time:DateTime: self.accept_time:DateTime", "status:String: self.status:String", "reviewer_comment:String: self.reviewer_comment:String", "is_finish:Boolean: self.is_finish:Boolean"])

    # Validations
    
    validates :clain_number:String, presence: true
    
    validates :reject_time:DateTime, presence: true
    
    validates :accept_time:DateTime, presence: true
    
    validates :status:String, presence: true
    
    validates :reviewer_comment:String, presence: true
    
    validates :is_finish:Boolean, presence: true
    

    def save
        if valid?
            claim = Insurances::Claim.new(increment_claim:Integer: self.increment_claim:Integer, clain_number:String: self.clain_number:String, reject_time:DateTime: self.reject_time:DateTime, accept_time:DateTime: self.accept_time:DateTime, status:String: self.status:String, reviewer_comment:String: self.reviewer_comment:String, is_finish:Boolean: self.is_finish:Boolean)
            claim.save
            true
        else
            false
        end
    end

    def update
        if valid?
            claim = Insurances::Claim.find(self.id)
            claim.update_attributes!(increment_claim:Integer: self.increment_claim:Integer, clain_number:String: self.clain_number:String, reject_time:DateTime: self.reject_time:DateTime, accept_time:DateTime: self.accept_time:DateTime, status:String: self.status:String, reviewer_comment:String: self.reviewer_comment:String, is_finish:Boolean: self.is_finish:Boolean)
            true
        else
            false
        end
    end
end

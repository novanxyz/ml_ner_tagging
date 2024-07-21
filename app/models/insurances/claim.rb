require 'markazuna/common_model'

class Insurances::Claim
	include Mongoid::Document
    include Markazuna::CommonModel
    store_in collection: 'insurance_claims'

    # kaminari page setting
    paginates_per 20
	
    field :increment_claim, type: Integer, default: ''	
    field :claim_number, type: String, default: ''	
    field :reject_time, type: DateTime, default: ''	
    field :accept_time, type: DateTime, default: ''	
    field :status, type: String, default: ''	
    field :reviewer_comment, type: String, default: ''	
    field :is_finish, type: Boolean, default: ''	

    belongs_to :moderated_by, :class_name => 'Core::User', index: true
    belongs_to :insurance, :class_name => 'Insurances::Insurance', index: true
    #belongs_to :insurance_claim_reason, :class_name => 'Core::InsuranceClaimReason', index: true
    #has_many :insurance_claim_data, :class_name => 'Core::InsuranceClaimData'

    index({created_at: 1, status: 1, insurance_claim_reason_id: 1})

    def change_status_to_indonesia
        case status
        when 'APPROVED'
            'Disetujui'
        when 'REJECTED'
            'Ditolak'
        when 'IN REVIEW'
            'Proses Review'
        end
    end
end

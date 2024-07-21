require 'markazuna/common_model'

class Insurances::Insurance
	include Mongoid::Document
    include Markazuna::CommonModel
    store_in collection: 'insurances'

    # kaminari page setting
    paginates_per 10
	
    field :policy_number, type: String, default: ''	
    field :start_date, type: Date, default: ''	
    field :end_date, type: Date, default: ''	
    field :policy_holder, type: String, default: ''	
    field :status, type: String, default: 'IN REVIEW'	
    field :policy_type, type: String, default: ''	
    field :payment_end_date, type: Date, default: ''	
    field :total_month_paid, type: Integer, default: ''	
    field :source, type: String, default: ''	
    field :fullname, type: String, default: ''	
    field :phone_number, type: String, default: ''	
    field :email, type: String, default: ''	
    field :file_policy, type: String, default: ''	
    field :file_policy_uploaded_at, type: DateTime, default: ''	
    field :approved_date, type: Date, default: ''	

    #has_many :insurance_claims, :class_name => 'Insurances::InsuranceClaim'
    has_many :quotas, :class_name => 'Insurances::Quota', as: :sourceable
    #embeds_many :user_contact_times, :class_name => 'Core::UserContactTime'
    belongs_to :user, :class_name => 'Core::User', index: true
    belongs_to :moderated_by, :class_name => 'Core::Admin', index: true
    #belongs_to :insurance_provider, :class_name => 'Insurances::InsuranceProvider', index: true

    # validates_presence_of :user_id
    # validates_presence_of :insurance_provider_id
    validates_uniqueness_of :policy_number, :allow_blank => true, :allow_nil => true

    index({user_id: 1, status: 1})
    index({user_id: 1})

    def get_fullname
        if self.user.blank?
            self.fullname rescue ''
        else
            self.policy_holder.present? ? self.policy_holder : (self.user.fullname rescue '')
        end
    end

    def get_email
        if self.user.blank?
            self.email rescue ''
        else
            self.user.email rescue ''
        end
    end

    def get_phone_number
        if self.user.blank?
            self.phone_number rescue ''
        else
            self.user.phone rescue ''
        end
    end

    def self.get_status_insurance(user)
        where(user: user).order(created_at: 'desc').first.status_insurance_for_deeplink rescue 0
    end

    def status_insurance_for_deeplink
        case status
        when 'IN REVIEW'
            1
        when 'ACTIVE'
            2
        when 'EXPIRE'
            2
        when 'GRACE PERIOD'
            2
        end
    end

    def change_status_to_indonesia
        case status
        when 'IN REVIEW'
            'PROSES REVIEW'
        when 'ACTIVE'
            'AKTIF'
        when 'EXPIRE'
            'EXPIRED'
        when 'GRACE PERIOD'
            'MASA TENGGANG'
        end
    end

    def self.get_by_users(user_ids)
        self.in(user_id: user_ids).hint({user_id: 1})
    end
end

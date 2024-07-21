class Core::Admin < Core::User
    include Mongoid::Document
    include Markazuna::CommonModel
    include Elasticsearch::Model
    paginates_per 10

    
    field :division_id, type: Integer
    ## relationship
    belongs_to :division, class_name: "Core::Division"

    devise :database_authenticatable, :timeoutable,
           :recoverable, :rememberable, :trackable, :validatable #, :omniauthable #, :omniauth_providers => [:facebook]


    ## validation
    validates_presence_of :division_id
    ## issue in production mode
    ##validates_inclusion_of :division_id, in: Core::Division.get_divisions.map(&:_id)
    validate :inclusion_division

    ## callback
    before_validation :assign_role
    after_build :load_division

    index_name "alomobile"
    # document_type "user"

    ## public method
    def division_name
        self.division.name
    end

    ## instance method
    def self.get_admins(page = 0)
        self.where(:role_id.in => Core::Role.where(name: 'admin').pluck(:id)).page(page).per(12)
    end

    def self.update_to_admin(to_admin_params, in_admin_params)
        result = {}
        user = Core::User.where(_type: "Core::User", email: to_admin_params[:email]).first rescue nil
        if user.present?
            if user.update_attributes(_type: "Core::Admin", role: Core::Role.find_by(name: 'admin'), version: '')
                new_admin = self.find(user)
                if new_admin.update_attributes(in_admin_params)
                    result = {'status' => 0, 'message' => 'User was successfully updated.'}
                else
                    result = {'status' => 1, 'message' => (new_admin.errors[:division_id].any? ? new_admin.errors[:division_id][0] : '')}
                end
            else
                result = {'status' => 1, 'message' => 'Something wrong.'}
            end
        else
            result = {'status' => 1, 'message' => 'Email not found in member.'}
        end
        return result
    end

    ## private method

    private

    def assign_role
        self.role = Core::Role.find_by(name:'admin')
    end

    def inclusion_division
        unless Core::Division.find(self.division_id)
            errors.add(:division_id, "Division tidak ditemukan")
        end
    end

    def load_division
        self.division = Core::Division.find(self.division_id)
    end

end
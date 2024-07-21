class Core::UserForm
    include ActiveModel::Model
    include ActiveModel::Validations


    attr_accessor(:id, :email, :username, :firstname, :lastname,:gender, :birthday, :city, :phone, :interest,:password, :interests )
    
    # Validations    
    validates :email, presence: true
    validates :firstname, presence: true    
    validates :lastname, presence: true
    
    # validates_uniqueness_of :email
    # validates_uniqueness_of :username
    

    def save
        if valid?
            user = Core::User.new(email: self.email, 
                                username: self.username, 
                                firstname: self.firstname, 
                                lastname: self.lastname,
                                gender: self.gender,
                                birthday: self.birthday,
                                city: self.city,
                                phone: self.phone,
                                interest_ids: self.interests,                                
                            )
            user.save
            true
        else
            errors
        end
    end

    def update
        puts self.interests
        if valid?
            user = Core::User.find(self.id)
            user.update_attributes!(email: self.email, 
                                    username: self.username, 
                                    firstname: self.firstname, 
                                    lastname: self.lastname,
                                    gender: self.gender,
                                    birthday: self.birthday,
                                    city: self.city,
                                    phone: self.phone,
                                    interest_ids: self.interests
                                    )
            true
        else
            puts errors.messages
            errors
        end
    end
end

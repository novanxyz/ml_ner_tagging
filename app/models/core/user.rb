require 'elasticsearch/model'
require 'csv'
require 'matrix'

class Core::User
    include Mongoid::Document
    include Mongoid::Timestamps
    include Elasticsearch::Model
    store_in collection: 'users'
    paginates_per 10


    # Include default devise modules. Others available are:
    # :confirmable, :lockable, :timeoutable and :omniauthable
    # devise :database_authenticatable, :timeoutable,
    #        :recoverable, :rememberable, :trackable, :validatable #, :omniauthable #, :omniauth_providers => [:facebook]

    ## Database authenticatable
    field :email, type: String, default: ''
    field :encrypted_password, type: String, default: ''

    ## Recoverable
    field :reset_password_token, type: String
    field :reset_password_sent_at, type: Time

    ## Rememberable
    field :remember_created_at, type: Time

    ## Trackable
    field :sign_in_count, type: Integer, default: 0
    field :current_sign_in_at, type: Time
    field :last_sign_in_at, type: Time
    field :current_sign_in_ip, type: String
    field :last_sign_in_ip, type: String

    ## Confirmable
    # field :confirmation_token,   type: String
    # field :confirmed_at,         type: Time
    # field :confirmation_sent_at, type: Time
    # field :unconfirmed_email,    type: String # Only if using reconfirmable

    ## Lockable
    # field :failed_attempts, type: Integer, default: 0 # Only if lock strategy is :failed_attempts
    # field :unlock_token,    type: String # Only if unlock strategy is :email or :both
    # field :locked_at,       type: Time

    field :firstname, type: String
    field :lastname, type: String
    field :username, type: String
    field :age, type: Integer
    field :gender, type: String
    field :auth_token, type: String, default: ''
    field :user_picture, type: String, default: 'http://res.cloudinary.com/dk0z4ums3/image/upload/v1445323295/default_user_profile_ffktz1.png'
    field :is_active, type: Boolean, default: true
    field :device_token, type: String, default: '' # gcm token
    field :provider, type: String, default: ''
    field :fb_token, type: String, default: ''
    field :birthday, type: String, default: ''
    field :spam_counter, type: Integer, default: 0
    field :spam_block, type: Boolean, default: false
    field :version, type: String, default: ""
    field :phone, type: String, default: ""
    field :last_sync_data, type: Time
    field :current_form_id_without_tag, type: String
    field :campaign_location, type: String
    field :campaign_without_tag_finish, type: Boolean, default: false
    field :current_campaign_id_without_tag, type: String
    field :is_fcm_registered, type: Boolean, default: true
    field :blast_timestamp, type: Integer, default: Time.now.to_i
    field :user_agent, type: String
    field :friendly_token, type: String # for generate a jwt token unique
    # field :status_insurance, type: Integer, default: 0

    attr_accessor :from_backoffice, :login_api, :from_register, :picture, :format

    belongs_to :role, :class_name => 'Core::Role', index: true
    has_many :magazines, :class_name => 'Admin::Magazine'
    has_many :questions, :class_name => 'Core::Question', inverse_of: :user
    has_many :pre_questions, :class_name => 'Core::PreQuestion', inverse_of: :user
    has_many :meta_questions, :class_name => 'Core::MetaQuestion'
    has_many :directories, :class_name => 'Core::Directory'
    has_many :insurances, :class_name => 'Insurances::Insurance'

    has_and_belongs_to_many :interests, class_name: 'Core::Interest', inverse_of: nil
    embeds_many :meta_descriptions, class_name: 'Core::UserMetaDescription'
    belongs_to :city, :class_name => 'Admin::City'

    validates_presence_of :firstname, :message => 'harus diisi'
    validates_uniqueness_of :auth_token, :allow_blank => true, :allow_nil => true
    validates_presence_of :interests, :if => Proc.new { |user| user.role.name == 'member' && user.from_backoffice.present? && user._type == 'Core::User' }

    index_name "alomobile"
    # after_update {
    #     __elasticsearch__.index_document if self._type == 'Core::User'
    # }

#    after_create :elastic_create_indexing
#    after_update :elastic_update_indexing
#    after_destroy :elastic_destroy_indexing
    #after_build :load_relations

    # after_update { __elasticsearch__.index_document }
    settings index: { number_of_shards: 1 } do
        mappings dynamic: 'false' do
            indexes :email, type: 'string', analyzer: 'indonesian', index_options: 'offsets'
            indexes :firstname, type: 'string', analyzer: 'indonesian', index_options: 'offsets'
            indexes :lastname, type: 'string', analyzer: 'indonesian', index_options: 'offsets'
            indexes :username, type: 'string', analyzer: 'indonesian', index_options: 'offsets'
            indexes :age, type: 'integer', index: 'not_analyzed'
            indexes :gender, type: 'string', index: 'not_analyzed'
            indexes :is_active, type: 'boolean', index: 'not_analyzed'
            indexes :phone, type: 'string', index: 'not_analyzed'
            indexes :birthday, type: 'string', index: 'not_analyzed'
            indexes :version, type: 'string', index: 'not_analyzed'
            indexes :user_picture, type: 'string', index: 'not_analyzed'
        end
    end

    # elasticsearch imported field
    def as_indexed_json(options={})
        self.as_json({
                         only: [
                             :email,
                             :firstname,
                             :lastname,
                             :username,
                             :age,
                             :gender,
                             :is_active,
                             :phone,
                             :birthday,
                             :version,
                             :user_picture
                         ],
                         include: {
                             role: {
                                 only: [:_id, :name]
                             }
                         }
                     })
    end

    ## http://guides.rubyonrails.org/v4.2/active_record_validations.html#grouping-conditional-validations
    with_options :if =>  Proc.new{ |user| user.version.present? } do |user|
        user.validates :birthday, :presence => true
        #user.validate :minimum_age
    end

    ## http://guides.rubyonrails.org/v4.2/active_record_validations.html#grouping-conditional-validations
    with_options :if => :is_not_admin? do |user|
        user.validates :username, :presence => true
        user.validates :username, :uniqueness => true, :case_sensitive => false
        user.validates :gender, :presence => true
        user.validates :city, :presence => true
    end

    index({role_id: 1, email: 1})
    index({role_id: 1, is_active: 1, created_at: 1})
    index({interest_ids: 1, blast_timestamp: 1, is_fcm_registered: 1, role_id: 1, device_token: 1})
    index({blast_timestamp: 1, is_fcm_registered: 1, role_id: 1, device_token: 1})
    index({_id: 1, blast_timestamp: 1, is_fcm_registered: 1, role_id: 1, device_token: 1})
    index({device_token: 1})
    index({firstname: 1, lastname: 1, role_id: 1})
    index({role_id: 1, provider: 1, username: 1})

    # indexing text for query search $text https://docs.mongodb.com/manual/core/index-text/
    index({firstname: 'text', lastname: 'text', email: 'text'})

    before_create :generate_authentication_token!


    def as_json(*args)
        res = super
        res["id"] = res.delete("_id").to_s
        res["fullname"] = "#{res['firstname']} #{res['lastname']}"
        res
    end

    def generate_authentication_token!
        self.friendly_token = Devise.friendly_token.first(8)
        self.auth_token = generate_auth_token(self.friendly_token)
    end

    def generate_auth_token(friendly_token)
        AloJwt.encode({user_id: id.to_s, friendly_token: friendly_token})
    end

    def set_reset_password_token
        raw, enc = Devise.token_generator.generate(self.class, :reset_password_token)
        self.reset_password_token = enc
        self.reset_password_sent_at = Time.now.utc
        self.save(validate: false)
        raw
    end

    def with_reset_password_token(token)
        Devise.token_generator.digest(self, :reset_password_token, token)
    end

    def fullname
        "#{self.firstname} #{self.lastname}".strip
    end

    def is_not_admin?
        self.role.name == 'member' && self.role.name == 'doctor'
    end

    def update_user(user_update_params)
        url = "/backoffice/users/#{self.id}"
        filter_params = user_update_params.merge(from_backoffice: true)
        ['city', 'interests', 'birthday', 'phone'].each { |k| filter_params.delete k }
        filter_params.delete('password') if user_update_params[:password].empty?

        current_date = Date.today
        birthday_date = Date.parse(user_update_params[:birthday])
        if current_date < birthday_date
            # default birthday date if current date less than birthday date
            self.birthday = '1/1/1980'
            self.age = (current_date.year - Date.parse('1/1/1980').year).to_i
        else
            self.birthday = user_update_params[:birthday]
            self.age = (current_date.year - birthday_date.year).to_i
        end
        self.birthday = DateTime.parse(user_update_params[:birthday]).strftime('%d/%m/%Y')
        self.city = Core::City.find(user_update_params[:city])
        self.phone = "62#{user_update_params[:phone].to_i}"
        self.interests.clear
        self.interests << Core::Interest.find(user_update_params[:interests].reject { |c| c.empty? })
        if self.update_attributes(filter_params)
            unless user_update_params[:password].empty?
                self.set(auth_token: Devise.friendly_token)
            end
            meta_description = Core::MetaDescription.find_by(sequence: 2)
            meta_description_age = self.meta_descriptions.find_by(:meta_description => meta_description)
            if !meta_description_age.nil?
                meta_description_age.text_value = self.age.to_s
                meta_description_age.save
            end

            [url, self, "User was successfully updated.", 200]
        else
            [url, self, "User was failed updated.", 500]
        end
    end

    def self.is_user_exist?(user_id)
        role = Core::Role.find_by(name: 'member')
        find_by(id: user_id, role: role, is_active: true)
    end

    def self.from_omniauth(auth)
        role = Core::Role.find_by(name: 'member')
        where(auth.slice(:provider, :username), role: role).first
    end

    def self.find_fb_user(facebook_id)
        role = Core::Role.find_by(name: 'member')
        find_by(username: facebook_id, role: role)
    end

    def self.from_api_fb_login(email)
        where(email: email).first
    end

    def self.count_user
        role = Core::Role.find_by(name: 'member')
        where(role: role, is_active: true).count
    end

    def self.get_users(page = 0)
        # self.where(is_active: true, :role_id.in => Core::Role.where(name: 'member').pluck(:id)).page(page).per(12)
        self.where(is_active: true).in(role_id: Core::Role.find_by(name: 'member').id).order(created_at: 'asc').hint({role_id: 1, is_active: 1, created_at: 1}).page(page).per(12)
    end

    def self.find_by_auth_token(auth_token)
        self.find_by(auth_token: auth_token, :role_id.in => Core::Role.where(name: 'member').pluck(:id))
    end

    def self.find_active_user_by_email(email)
        self.find_by(email: email, is_active: true, :role_id.in => Core::Role.where(name: 'member').pluck(:id))
    end

    def self.find_member_by_email(email)
        self.find_by(email: email, :role_id.in => Core::Role.where(name: 'member').pluck(:id))
    end

    def self.find_by_facebook_id(facebook_id)
        self.where(role_id: Core::Role.find_by(name: 'member').id, provider: 'facebook', username: facebook_id).hint({role_id: 1, provider: 1, username: 1}).first
    end

    def self.find_active_user(user_id)
        self.find_by(id: user_id, is_active: true)
    end

    def self.get_users_block(page = 0)
        self.where(is_active: false, :role_id.in => Core::Role.where(name: 'member').pluck(:id)).page(page).per(12)
    end

    def self.search_all_users(word, page = 0)
        # self.where(role: Core::Role.find_by(name: 'member')).any_of({:firstname => /.*#{word}.*/i},{:lastname => /.*#{word}.*/i}).order_by(:firstname => 'asc').page(page).per(DEFAULT_PAGE_SIZE)
        # self.where({ :$text => { :$search => word} }).order_by(:firstname => 'asc').page(page).per(DEFAULT_PAGE_SIZE)

        self.__elasticsearch__.search(query: {multi_match: { query: word, type: 'cross_fields', fields: ['firstname', 'lastname', '_id', 'email'], operator: 'AND' }}).page(page).per(DEFAULT_PAGE_SIZE)
    end

    def self.get_user_notification
        self.where(is_active: true, :role_id.in => Core::Role.where(name: 'member').pluck(:id)).pluck(:id,:firstname,:lastname)
    end

    def self.get_user_notification_with_device_token
        users = self.where(is_active: true, :version.ne => "", :device_token.ne=>"", :role_id.in => Core::Role.where(name: 'member').pluck(:id)).pluck(:id,:firstname,:lastname)
        data = []
        users.each do |user|
            data << {
                'id' => user[0].to_s,
                'firstname' => user[1],
                'lastname' => user[2]
            }
        end

        [data, 200]
    end

    # generate csv user interests
    def self.generate_user_interests
        CSV.open("user_interests.csv", "wb") do |csv|
            users = self.where(is_active: true, role_id: Core::Role.find_by(name: 'member').id).order_by(:_id => 'asc')
            users.each do |user|
                total_score = []
                Core::Interest.all.order_by(:_id => 'asc').each_with_index do |interest, index|
                    if(user.interest_ids & [interest.id]).count > 0
                        total_score << index
                    end
                end

                csv << [user.id, total_score.join(',')]
            end
        end
    end

    # generate csv magazine tags
    def self.generate_magazine_tags
        CSV.open("magazine_tags.csv", "wb") do |csv|
            magazines = Core::Magazine.where(:magazine_relationships.ne=>nil).order_by(:_id => 'asc')
            magazines.each do |magazine|
                total_score = []
                magazine_term_ids = magazine.magazine_relationships.collect {|x|x.term_taxonomy.term_id if !x.term_taxonomy.nil? }
                Core::Term.all.order_by(:_id => 'asc').each_with_index do |term, index|
                    if(magazine_term_ids & [term.id]).count > 0
                          total_score << index
                    end
                end

                csv << [magazine.id, total_score.join(',')]
            end
        end
    end

    # generate score user magazine
    def self.generate_score_with_magazine
        magazine_term_ids = {}
        users = self.where(is_active: true, role_id: Core::Role.find_by(name: 'member').id).order_by(:_id => 'asc')

        CSV.open("magazine_ids.csv", "wb") do |csv|
            Core::Magazine.where(:magazine_relationships.ne=>nil).order_by(:_id => 'asc').each_with_index do |magazine, index|
                csv << [index, magazine.id]
                magazine_term_ids[index] = magazine.magazine_relationships.collect {|x|x.term_taxonomy.term_id if !x.term_taxonomy.nil? }
            end
        end

        CSV.open("scores.csv", "wb") do |csv|
            users.each do |user|
                total_score = []
                user_term_ids = Core::TermInterest.where(:interest_id.in=>user.interest_ids.flatten.uniq).order_by(:_id => 'asc').pluck(:term_id)
                (0..magazine_term_ids.count-1).each do |i|
                    if (user_term_ids & magazine_term_ids[i]).count > 0
                        total_score << "(#{i.to_s}##{(user_term_ids & magazine_term_ids[i]).count})"
                    end
                end

                csv << [user.id, total_score.join(', ')] if !total_score.empty?
            end
        end
    end

    ## method for v1.3.0
    def self.default_user_picture
        Core::Setting.where(method: "#{__method__}").first.value rescue 'http://res.cloudinary.com/dk0z4ums3/image/upload/v1445323295/default_user_profile_ffktz1.png'
    end

    def self.get_list_user_autocomplete(name, page)
        if name.present?
            names = name.split(' ')
            if names.size < 2
                firstname = names[0]
                lastname = names[0]

                users = Core::User.search({
                                              "query": {
                                                  "function_score": {
                                                      "query": {
                                                          "bool": {
                                                              "must": [
                                                                  {
                                                                      "bool": {
                                                                          "filter": [
                                                                              {
                                                                                  "term": {
                                                                                      "role.name": 'member'
                                                                                  }
                                                                              }
                                                                          ]
                                                                      }
                                                                  },
                                                                  {
                                                                  "dis_max": {
                                                                      "queries": [{
                                                                                      "match": {
                                                                                          "firstname": {
                                                                                              "query": "#{CGI.unescape(firstname)}",
                                                                                              "operator": 'or'
                                                                                          }
                                                                                      }
                                                                                  }, {
                                                                                      "match": {
                                                                                          "lastname": {
                                                                                              "query": "#{CGI.unescape(lastname)}",
                                                                                              "operator": 'or'
                                                                                          }
                                                                                      }
                                                                                  }],
                                                                      "tie_breaker": 0.3
                                                                  }
                                                                }
                                                              ]
                                                          }
                                                      }
                                                  }
                                              }
                                          }).to_a

            else
                firstname = names[0]
                lastname = (names - [firstname])[0..names.size - 1].join(' ')

                users = Core::User.search({
                                              "query"=> {
                                                  "bool"=> {
                                                      "must"=> [
                                                          {"term": {"role.name": 'member'}},
                                                          {"bool"=> {
                                                              "should"=> [
                                                                  {"term"=> {"firstname": firstname}},
                                                                  {"term"=> {"lastname": lastname}}
                                                              ]
                                                          }}
                                                      ]
                                                  }
                                              }
                                          }).to_a
            end


            
            users.map {|x| {label: (x.firstname.to_s + ' ' + x.lastname.to_s).strip, value: x.id.to_s} }
        else
            []
        end
    end

    def self.send_notif_by_interest(params)
        if params[:notification].present?
            if params[:notification][:interests].present?
                if params[:notification][:select_type] == 'message'
                    image_url = ""
                    if params[:notification].has_key?(:image_url)
                        begin
                            image_url = Upload.magazine_upload_to_cloudinary_with_params(params[:notification][:image_url], "user_notifications/#{params[:notification][:title_notif_by_interest].downcase.gsub(' ', '_') + "_" + Time.now.to_i.to_s}", ['user_notification'])
                            image_url = image_url['url']
                        rescue
                            return [{"message": 'Upload image failed, please try again'}, 500]
                        end
                    end

                    begin
                        image_resize = image_url.split('/upload/')
                        new_image = image_resize.first + '/upload/' + image_resize.last
                    rescue
                        new_image = ''
                    end

                    icon_url = Core::Setting.find_by_method('icon_user_notification') rescue "http://res.cloudinary.com/dk0z4ums3/image/upload/v1522293202/icon_user_notification.png"

                    bundle = {
                        category: 'notif_backoffice',
                        data: {
                            title: params[:notification][:title_notif_by_interest],
                            message: params[:notification][:message],
                            image_url: new_image,
                            metadata: "",
                            type: params[:notification][:select_type],
                            icon: icon_url
                        }
                    }

                    SendUserNotificationByInterestJob.perform_later(bundle, "user_interest", nil, params[:notification][:interests].split(','), nil)

                    [{"message": "Send notification success"}, 200]
                elsif params[:notification][:select_type] == 'deeplink'
                    if params[:notification][:article_id].present?
                        article = Core::Magazine.find(params[:notification][:article_id])

                        if article.present?
                            message = ''
                            Nokogiri::HTML.parse(article.content).text.split(' ').each do |text|
                                if message.length <= 96
                                    message = message + ' ' + text
                                end
                            end

                            begin
                                image_resize = params[:notification][:article_image_url].split('/upload/')
                                new_image = image_resize.first + '/upload/' + image_resize.last
                            rescue
                                new_image = ''
                            end

                            icon_url = Core::Setting.find_by_method('icon_user_notification') rescue "http://res.cloudinary.com/dk0z4ums3/image/upload/v1522293202/icon_user_notification.png"

                            bundle = {
                                category: 'notif_backoffice',
                                data: {
                                    title: params[:notification][:article],
                                    message: message.strip + ' ...',
                                    image_url: new_image,
                                    metadata: "majalah#user_notification/" + article.slug + "#''",
                                    type: params[:notification][:select_type],
                                    icon: icon_url
                                }
                            }

                            SendUserNotificationByInterestJob.perform_later(bundle, "user_interest", article.id.to_s, params[:notification][:interests].split(','), nil)

                            [{"message": "Send notification success"}, 200]
                        else
                            [{"message": 'Article not found.'}, 500]
                        end
                    else
                        [{"message": 'Something when wrong, please reload this page again.'}, 500]
                    end
                else
                    return [{"message": "Select type can't be blank."}, 500]
                end
            else
                [{'message': 'Something when wrong, please reload this page again.'}, 500]
            end
        else
            [{"message": 'Something when wrong, please reload this page again.'}, 500]
        end
    end

    def self.send_notif_by_user(params)
        if params[:notification].present?
            if params[:notification][:users].present?
                if params[:notification][:select_type_user] == 'message'
                    image_url = ""
                    if params[:notification].has_key?(:image_url_user)
                        begin
                            image_url = Upload.magazine_upload_to_cloudinary_with_params(params[:notification][:image_url_user], "user_notifications/#{params[:notification][:title_notif_by_user].downcase.gsub(' ', '_') + "_" + Time.now.to_i.to_s}", ['user_notification'])
                            image_url = image_url['url']
                        rescue
                            return [{"message": 'Upload image failed, please try again'}, 500]
                        end
                    end

                    begin
                        image_resize = image_url.split('/upload/')
                        new_image = image_resize.first + '/upload/' + image_resize.last
                    rescue
                        new_image = ''
                    end

                    icon_url = Core::Setting.find_by_method('icon_user_notification') rescue "http://res.cloudinary.com/dk0z4ums3/image/upload/v1522293202/icon_user_notification.png"

                    bundle = {
                        category: 'notif_backoffice',
                        data: {
                            title: params[:notification][:title_notif_by_user],
                            message: params[:notification][:message_user],
                            image_url: new_image,
                            metadata: "",
                            type: params[:notification][:select_type_user],
                            icon: icon_url
                        }
                    }

                    SendUserNotificationJob.perform_later(bundle, "user_selection", nil, nil, params[:notification][:users].split(','))

                    [{"message": "Send notification success"}, 200]
                elsif params[:notification][:select_type_user] == 'deeplink'
                    if params[:notification][:article_user_id].present?
                        article = Core::Magazine.find(params[:notification][:article_user_id])

                        if article.present?
                            message = ''
                            Nokogiri::HTML.parse(article.content).text.split(' ').each do |text|
                                if message.length <= 96
                                    message = message + ' ' + text
                                end
                            end

                            begin
                                image_resize = params[:notification][:article_image_user_url].split('/upload/')
                                new_image = image_resize.first + '/upload/' + image_resize.last
                            rescue
                                new_image = ''
                            end

                            icon_url = Core::Setting.find_by_method('icon_user_notification') rescue "http://res.cloudinary.com/dk0z4ums3/image/upload/v1522293202/icon_user_notification.png"

                            bundle = {
                                category: 'notif_backoffice',
                                data: {
                                    title: params[:notification][:article_user],
                                    message: message.strip + ' ...',
                                    image_url: new_image,
                                    metadata: "majalah#user_notification/" + article.slug + "#''",
                                    type: params[:notification][:select_type_user],
                                    icon: icon_url
                                }
                            }

                            SendUserNotificationJob.perform_later(bundle, "user_selection", article.id.to_s, nil, params[:notification][:users].split(','))

                            [{"message": "Send notification success"}, 200]
                        else
                            [{"message": 'Article not found.'}, 500]
                        end
                    else
                        [{"message": 'Something when wrong, please reload this page again.'}, 500]
                    end
                else
                    return [{"message": "Select type can't be blank."}, 500]
                end
            else
                [{'message': 'Something when wrong, please reload this page again.'}, 500]
            end
        else
            [{"message": 'Something when wrong, please reload this page again.'}, 500]
        end
    end

    def self.send_notif_by_all_user(params)
        if params[:notification].present?
            # if params[:notification][:users].present?
                if params[:notification][:select_type_all_user] == 'message'
                    image_url = ""
                    if params[:notification].has_key?(:image_url_all_user)
                        begin
                            image_url = Upload.magazine_upload_to_cloudinary_with_params(params[:notification][:image_url_all_user], "user_notifications/#{params[:notification][:title_notif_all_user].downcase.gsub(' ', '_') + "_" + Time.now.to_i.to_s}", ['user_notification'])
                            image_url = image_url['url']
                        rescue
                            return [{"message": 'Upload image failed, please try again'}, 500]
                        end
                    end

                    begin
                        image_resize = image_url.split('/upload/')
                        new_image = image_resize.first + '/upload/' + image_resize.last
                    rescue
                        new_image = ''
                    end

                    icon_url = Core::Setting.find_by_method('icon_user_notification') rescue "http://res.cloudinary.com/dk0z4ums3/image/upload/v1522293202/icon_user_notification.png"

                    bundle = {
                        category: 'notif_backoffice',
                        data: {
                            title: params[:notification][:title_notif_all_user],
                            message: params[:notification][:message_all_user],
                            image_url: new_image,
                            metadata: "",
                            type: params[:notification][:select_type_all_user],
                            icon: icon_url
                        }
                    }

                    SendUserNotificationJob.perform_later(bundle, 'user_all', nil, nil, nil)

                    [{"message": "Send notification success"}, 200]
                elsif params[:notification][:select_type_all_user] == 'deeplink'
                    if params[:notification][:article_all_user_id].present?
                        article = Core::Magazine.find(params[:notification][:article_all_user_id])

                        if article.present?
                            message = ''
                            Nokogiri::HTML.parse(article.content).text.split(' ').each do |text|
                                if message.length <= 96
                                    message = message + ' ' + text
                                end
                            end

                            begin
                                image_resize = params[:notification][:article_image_all_user_url].split('/upload/')
                                new_image = image_resize.first + '/upload/' + image_resize.last
                            rescue
                                new_image = ''
                            end

                            icon_url = Core::Setting.find_by_method('icon_user_notification') rescue "http://res.cloudinary.com/dk0z4ums3/image/upload/v1522293202/icon_user_notification.png"

                            bundle = {
                                category: 'notif_backoffice',
                                data: {
                                    title: params[:notification][:article_all_user],
                                    message: message.strip + ' ...',
                                    image_url: new_image,
                                    metadata: "article#doctor_notification/" + article.slug + "#''",
                                    type: params[:notification][:select_type_all_user],
                                    icon: icon_url
                                }
                            }

                            SendUserNotificationJob.perform_later(bundle, 'user_all', article.id.to_s, nil, nil)

                            [{"message": "Send notification success"}, 200]
                        else
                            [{"message": 'Article not found.'}, 500]
                        end
                    else
                        [{"message": 'Something when wrong, please reload this page again.'}, 500]
                    end
                else
                    return [{"message": "Select type can't be blank."}, 500]
                end
            # else
            #     [{'message': 'Something when wrong, please reload this page again.'}, 500]
            # end
        else
            [{"message": 'Something when wrong, please reload this page again.'}, 500]
        end
    end

    

    def self.get_user_by_ids(user_ids)
        self.in(id: user_ids)
    end

    private

    def minimum_age
        unless self.birthday.blank?
            if (self.birthday.to_date + 15.years) > Date.today && role.name == "doctor"
                errors.add(:birthday, "Minimal umur 15 tahun")
            end
            user_version = self.version.gsub('.','').to_i rescue 0
            if (self.birthday.to_date + 10.years) > Date.today && role.name == "member" && user_version >= 120
                errors.add(:birthday, "Minimal umur 10 tahun")
            end
        end
    end

    def elastic_indexing
        if self.role == Core::Role.find_by(name: 'member')
            begin
            __elasticsearch__.index_document
            rescue
                Rails.logger.info "^^^^^^^^ CREATE ELASTICSEARCH PROBLEM ^^^^^^^^^"
            end
        end
    end

    def elastic_create_indexing
        if self.role == Core::Role.find_by(name: 'member')
            begin
                __elasticsearch__.index_document
            rescue Exception => e
                Rails.logger.info "^^^^^^^^ CREATE ELASTICSEARCH PROBLEM #{e} ^^^^^^^^^"
                ReindexJob.set(wait: (AloCache.get('reindex_delay_time') || "60").to_i.seconds).perform_later(self.class.name, 'index', self.id.to_s)
            end
        end
    end

    def elastic_update_indexing
        if self.role == Core::Role.find_by(name: 'member')
            begin
                __elasticsearch__.update_document
            rescue Exception => e
                if e.class.to_s =~ /NotFound/
                    Rails.logger.info "^^^^^^^^  UPDATE ELASTICSEARCH PROBLEM INDEX NOT FOUND ^^^^^^^^^"
                    __elasticsearch__.index_document
                else
                    Rails.logger.info "^^^^^^^^  UPDATE ELASTICSEARCH PROBLEM #{e} ^^^^^^^^^"
                    ReindexJob.set(wait: (AloCache.get('reindex_delay_time') || "60").to_i.seconds).perform_later(self.class.name, 'update', self.id.to_s)
                end
            end
        end
    end

    def elastic_destroy_indexing
        if self.role == Core::Role.find_by(name: 'member')
            begin
                __elasticsearch__.delete_document
            rescue Exception => e
                Rails.logger.info "^^^^^^^^ DELETE ELASTICSEARCH PROBLEM #{e} ^^^^^^^^^"
                ReindexJob.set(wait: (AloCache.get('reindex_delay_time') || "60").to_i.seconds).perform_later(self.class.name, 'delete', self.id.to_s)
            end
        end
    end


    def load_relations
        self.city = Admin::City.find(self.city_id)
    end
end

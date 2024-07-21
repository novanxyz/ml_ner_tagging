class Core::MetaQuestion < Core::AbstractQuestion
    include Mongoid::Document
    include Mongoid::Timestamps
    include Markazuna::CommonModel
    # store_in collection: 'meta_questions'

    has_many :meta_answers, class_name: 'Core::MetaAnswer', dependent: :destroy
    # embeds_many :meta_descriptions, class_name: 'Core::QuestionMetaDescription'
    # belongs_to :user, :class_name => 'Core::User', index: true
    #
    # field :title, type: String, default: ''
    # field :content, type: String, default: ''
    # field :image_url, type: String, default: ''
    # field :is_closed, type: Boolean, default: false
    # field :is_deleted, type: Boolean, default: false
    field :choice, type: Boolean, default: ''
    field :max_count_recommendation, type: Integer, default: 3
    field :campaign_id, type: String
    field :has_mini_conclusion, type: Boolean, default: false
    # field :is_anonymous, type: Boolean, default: false

    # validates_presence_of :title, :message => 'is Required.'
    # validates_presence_of :content, :message => 'is Required.'

    # index({is_deleted: 1, _type: 1})
    index({_type: 1, is_closed: 1, choice: 1, is_deleted: 1})
    # index({is_deleted: 1, created_at: -1})
    index({created_at: -1, is_deleted: 1})

    def self.is_asking_question(user)
        self.find_by(is_closed: false, user: user).present?
    end

    def self.get_bot_detail
        { id: '',
          firstname: 'Alodokter',
          lastname: '',
          username: 'alodokter.com',
          user_picture: 'http://res.cloudinary.com/dk0z4ums3/image/upload/v1476865311/magazine_images/default_images.png'
        }
    end

    def self.get_meta_questions_with_page(page = 0)
        self.where(is_deleted: false).order_by(:created_at => 'desc').hint({is_deleted: 1, created_at: -1}).page(page).per(DEFAULT_PAGE_SIZE)
    end

    def self.total_meta_questions
        self.where(is_deleted: false, _type: 'Core::MetaQuestion').hint({_type: 1, is_deleted: 1}).size
    end

    def self.count_of_yes
        self.where(is_deleted: false, _type: 'Core::MetaQuestion', is_closed: true, choice: true).hint({_type: 1, is_closed: 1, choice: 1, is_deleted: 1}).size
    end

    def self.count_of_no
        self.where(is_deleted: false, _type: 'Core::MetaQuestion', is_closed: true, choice: false).hint({_type: 1, is_closed: 1, choice: 1, is_deleted: 1}).size
    end

end
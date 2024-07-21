class Core::MetaAnswer
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Attributes::Dynamic
    store_in collection: 'meta_answers'

    belongs_to :meta_question, :class_name => 'Core::MetaQuestion', index: true
    belongs_to :token, :class_name => 'Core::TokenAuth'

    field :content, type: String, default: ''
    field :image_url, type: String, default: ''
    field :is_deleted, type: Boolean, default: false
    field :is_choice, type: Boolean, default: false
    field :user, type: Hash, default: {}
    field :bot, type: Hash, default: { id: '',
                                       firstname: 'Alodokter',
                                       lastname: '',
                                       username: 'alodokter.com',
                                       user_picture: 'http://res.cloudinary.com/dk0z4ums3/image/upload/v1476865311/magazine_images/default_images.png'
    }
    field :detail_answer, type: Hash, default: {}
    field :sequence, type: Integer, default: 0

    def token_name
        self.token.token rescue ''
    end

end
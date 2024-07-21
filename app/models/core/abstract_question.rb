class Core::AbstractQuestion
    include Mongoid::Document
    include Mongoid::Timestamps
    include Markazuna::CommonModel
    store_in collection: 'questions'

#    embeds_many :meta_descriptions, class_name: 'Core::QuestionMetaDescription'
#    embeds_many :intent_recommendations, class_name: 'Core::IntentRecommendation'
#    embeds_many :sub_intent_recommendations, class_name: 'Core::SubIntentRecommendation'
    belongs_to :user, :class_name => 'Core::User', index: true, inverse_of: :questions

    field :title, type: String
    field :content, type: String
    field :image_url, type: String, default: ''
    field :is_closed, type: Boolean, default: false
    field :is_deleted, type: Boolean, default: false
    field :is_anonymous, type: Boolean, default: false
    field :is_show, type: Boolean, default: true
    field :topic, type: String, default: ''
    field :top_sub_intent_recommendation, type: Hash, default: {}



    validates_presence_of :title, :message => 'is Required.'
    validates_presence_of :content, :message => 'is Required.'

end

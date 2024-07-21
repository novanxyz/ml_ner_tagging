class Core::Answer
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Attributes::Dynamic
    store_in collection: 'answers'

    belongs_to :question, :class_name => 'Core::Question', index: true
    belongs_to :user, :class_name => 'Core::User', index: true
    belongs_to :referral_chat, :class_name => 'Core::ReferralImage'
    belongs_to :sub_intent_question, :class_name => 'Core::SubIntentQuestion'
    embeds_many :answer_options, class_name: 'Core::AnswerOption'

    field :content, type: String, default: ''
    field :image_url, type: String, default: ''
    field :is_deleted, type: Boolean, default: false
    field :share_info, type: Hash, default: nil
    field :is_multiple_answer, type: Boolean, default: false
    field :is_choice, type: Boolean, default: false
    field :user_answers, type: Array, default: []
    field :is_hidden_for_doctor, type: Boolean, default: false
    field :is_hidden_for_user, type: Boolean, default: false
    field :is_intent_answer, type:Boolean, default: false
    field :is_doctor_recommendation, type: Boolean, default: false
    field :is_hospital_recommendation, type: Boolean, default: false
    field :answer_type, type: String, default: "0"
    field :referral_id, type:String, default: ''
    field :referral_name, type:String, default: ''

    # Referral answer type
    # - 50 for chat doctor specialist
    # - 51 for booking doctor specialist
    # - 52 for medical treatment
    # - 53 for emergency call

    # def is_gender_question
    #     result = false
    #     unless self.sub_intent_question_id.nil?
    #         result = self.sub_intent_question.is_gender_question rescue false
    #     end
    #     return result
    # end

    def self.get_answer_without_referral(question_id)
        self.where(question_id: question_id, :answer_type.nin =>  ["50", "51", "52", "53"]).order_by(created_at: 'asc')
    end
end

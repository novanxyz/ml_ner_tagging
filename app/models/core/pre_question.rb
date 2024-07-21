class Core::PreQuestion < Core::Question
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Reloadable
    include Markazuna::CommonModel
    include Elasticsearch::Model

    has_many :answers, foreign_key: 'question_id', :class_name => 'Core::Answer' do
        def count_answered_by_doctor(doctor_id)
            where(user: doctor_id).count
        end

        def find_first_answer_by_doctor(user_id)
            where(user: user_id).first
        end

        def count_answer
            where(is_deleted: false).count
        end

        def find_last_answer
            where(is_deleted: false).order_by(:created_at => 'asc').last
        end
    end

    embeds_many :question_relationships, class_name: 'Core::QuestionRelationship'
    belongs_to :picked_up_by, :class_name => 'Core::User', index: true

    belongs_to :intent, :class_name => 'Core::Intent'
    belongs_to :sub_intent, :class_name => 'Core::SubIntent'
    belongs_to :sub_intent_conclusion, :class_name => 'Core::SubIntentConclusion'
    has_many :hospital_recommendations, class_name: 'Core::HospitalRecommendation'
    has_many :doctor_recommendations, class_name: 'Core::DoctorRecommendation'
    has_one :review_chatbot, class_name: 'Core::ReviewChatbot'

    index({is_closed: 1})
    index({is_deleted: 1})
    index({is_deleted: 1, created_at: -1})
    index({is_closed: 1, is_deleted: 1, updated_at: -1})
    index({_type: 1, updated_at: 1})
    index({picked_up_by_id: 1, is_closed: 1, is_deleted: 1})
    index({picked_up_by_id: 1, is_deleted: 1, is_closed: 1, updated_at: -1})
    index({picked_up_by_id: 1, is_closed: 1, is_deleted: 1, created_at: -1})
    index({picked_up_by_id: 1, is_closed: 1, _type: 1, updated_at: 1})
    index({is_deleted: 1, _type:  1})
    index({title: 'text', content: 'text'})
    index({picked_up_by_id: 1, meta_chatbot: 1, id_closed: 1})

    index_name "alomobile"
    document_type "question"

    def self.get_pre_questions_with_page(page = 0)
        self.where(is_deleted: false).order_by("created_at"=> 'desc').hint({is_deleted: 1, created_at: -1}).page(page).per(10)
    end

    def self.search_all_questions(word, page = 0)
        self.__elasticsearch__.search(size: 1000, query: {multi_match: {query: word, fields: ["_id", "title", "content"]}}).records.order(created_at: 'desc').page(page).per(DEFAULT_PAGE_SIZE)
    end
end
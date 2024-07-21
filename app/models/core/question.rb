require 'markazuna/common_model'

class Core::Question < Core::AbstractQuestion
    include Mongoid::Document
    include Mongoid::Timestamps
    include Mongoid::Reloadable
    include Markazuna::CommonModel
#    include Fcm
#    include Elasticsearch::Model

    # kaminari page setting
    paginates_per 20
	
    field :access_type, type: String, default: ''	
    field :user_unread_count, type: Integer, default: ''	
    field :doctor_unread_count, type: Integer, default: ''	
    field :is_said_thanks, type: Boolean, default: ''	
    field :is_paid, type: Boolean, default: ''	
    field :time_picked_up, type: Time, default: ''	
    field :status_question_user, type: String, default: ''	
    field :status_question_doctor, type: String, default: ''	
    field :time_choice_intent, type: Time, default: ''	
    field :time_choice_sub_intent, type: Time, default: ''	
    field :time_conclusion_recommendation, type: Time, default: ''	
end

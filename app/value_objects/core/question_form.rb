
class Core::QuestionForm
    include ActiveModel::Model

    attr_accessor(["access_type", "user_unread_count", "doctor_unread_count", "is_said_thanks", "is_paid", "time_picked_up", "status_question_user", "status_question_doctor", "time_choice_intent", "time_choice_sub_intent", "time_conclusion_recommendation", "id"])

    # Validations
    
    validates :access_type, presence: true 
    validates :user_unread_count, presence: true 
    validates :doctor_unread_count, presence: true 
    validates :is_said_thanks, presence: true 
    validates :is_paid, presence: true 
    validates :time_picked_up, presence: true 
    validates :status_question_user, presence: true 
    validates :status_question_doctor, presence: true 
    validates :time_choice_intent, presence: true 
    validates :time_choice_sub_intent, presence: true 
    validates :time_conclusion_recommendation, presence: true 

    def save
        if valid?
            question = Core::Question.new(access_type: self:access_type, user_unread_count: self:user_unread_count, doctor_unread_count: self:doctor_unread_count, is_said_thanks: self:is_said_thanks, is_paid: self:is_paid, time_picked_up: self:time_picked_up, status_question_user: self:status_question_user, status_question_doctor: self:status_question_doctor, time_choice_intent: self:time_choice_intent, time_choice_sub_intent: self:time_choice_sub_intent, time_conclusion_recommendation: self:time_conclusion_recommendation, id: self:id)
            question.save
            true
        else
            false
        end
    end

    def update
        if valid?
            question = Core::Question.find(self.id)
            question.update_attributes!(access_type: self:access_type, user_unread_count: self:user_unread_count, doctor_unread_count: self:doctor_unread_count, is_said_thanks: self:is_said_thanks, is_paid: self:is_paid, time_picked_up: self:time_picked_up, status_question_user: self:status_question_user, status_question_doctor: self:status_question_doctor, time_choice_intent: self:time_choice_intent, time_choice_sub_intent: self:time_choice_sub_intent, time_conclusion_recommendation: self:time_conclusion_recommendation, id: self:id)
            true
        else
            false
        end
    end
end

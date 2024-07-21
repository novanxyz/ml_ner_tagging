
class Insurances::FaqForm
    include ActiveModel::Model

    attr_accessor(["question", "answer", "position", "id"])

    # Validations
    
    validates :question, presence: true 
    validates :answer, presence: true 
    validates :position, presence: true 

    def save
        if valid?
            faq = Insurances::Faq.new(question: self:question, answer: self:answer, position: self:position, id: self:id)
            faq.save
            true
        else
            false
        end
    end

    def update
        if valid?
            faq = Insurances::Faq.find(self.id)
            faq.update_attributes!(question: self:question, answer: self:answer, position: self:position, id: self:id)
            true
        else
            false
        end
    end
end

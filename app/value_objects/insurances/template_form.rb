
class Insurances::TemplateForm
    include ActiveModel::Model

    attr_accessor(["caption", "title_approval", "description_approval", "image_url_approval", "is_active", "id"])

    # Validations
    
    validates :caption, presence: true 
    validates :title_approval, presence: true 
    validates :description_approval, presence: true 
    validates :image_url_approval, presence: true 
    validates :is_active, presence: true 

    def save
        if valid?
            template = Insurances::Template.new(caption: self:caption, title_approval: self:title_approval, description_approval: self:description_approval, image_url_approval: self:image_url_approval, is_active: self:is_active, id: self:id)
            template.save
            true
        else
            false
        end
    end

    def update
        if valid?
            template = Insurances::Template.find(self.id)
            template.update_attributes!(caption: self:caption, title_approval: self:title_approval, description_approval: self:description_approval, image_url_approval: self:image_url_approval, is_active: self:is_active, id: self:id)
            true
        else
            false
        end
    end
end

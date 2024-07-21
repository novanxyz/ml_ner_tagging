class Core::UserMetaDescriptionForm
    include ActiveModel::Model

    attr_accessor(:id, :text_value)#

    # Validations
    

    def save
        if valid?
            user_meta_description = Core::UserMetaDescription.new(text_value: self.text_value)
            user_meta_description.save
            true
        else
            false
        end
    end

    def update
        if valid?
            user_meta_description = Core::UserMetaDescription.find(self.id)
            user_meta_description.update_attributes!(text_value: self.text_value)
            true
        else
            false
        end
    end
end

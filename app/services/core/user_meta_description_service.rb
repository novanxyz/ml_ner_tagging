class Core::UserMetaDescriptionService
    def create_user_meta_description(user_meta_description_form)
        user_meta_description_form.save
    end

    def update_user_meta_description(user_meta_description_form)
        user_meta_description_form.update
    end

    def delete_user_meta_description(id)
        user_meta_description = find_user_meta_description(id)
        return user_meta_description.delete, Core::UserMetaDescription.page(1).total_pages
    end

    def find_user_meta_description(id)
        Core::UserMetaDescription.find(id)
    end

    def find_user_meta_descriptions(query)
        page = query.delete(:page).to_i        
        query = {}  ## Configure the search first
        res = Core::UserMetaDescription.where(query)
        total_pages = ( res.count() / Core::UserMetaDescription.default_per_page ).ceil  #res.total_pages    
        return res.page(page) , total_pages
        return Core::UserMetaDescription.page(page), Core::UserMetaDescription.page(1).total_pages
    end
end

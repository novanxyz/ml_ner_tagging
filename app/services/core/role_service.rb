class Core::RoleService
    def create_role(role_form)
        role_form.save
    end

    def update_role(role_form)
        role_form.update
    end

    def delete_role(id)
        role = find_role(id)
        return role.delete, Core::Role.page(1).total_pages
    end

    def find_role(id)
        Core::Role.find(id)
    end

    def find_roles(query)
        page = query.delete(:page).to_i        
        query = {}  ## Configure the search first
        res = Core::Role.where(query)
        total_pages = ( res.count() / Core::Role.default_per_page ).ceil  #res.total_pages    
        return res.page(page) , total_pages
        return Core::Role.page(page), Core::Role.page(1).total_pages
    end
end

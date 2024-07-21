class Core::AdminService
    def create_admin(admin_form)
        admin_form.save
    end

    def update_admin(admin_form)
        admin_form.update
    end

    def delete_admin(id)
        admin = find_admin(id)
        return admin.delete, Core::Admin.page(1).total_pages
    end

    def find_admin(id)
        Core::Admin.find(id)
    end

    def find_admins(query)
        page = query.delete(:page).to_i        
        if query.key?"search"
            q = query.delete("search")
            query[:username] = /.*#{q}.*/i
        end
        res = Core::Admin.where(query)
        total_pages = ( res.count().to_f / Core::Admin.default_per_page ).ceil  #res.total_pages    
        return res.page(page) , total_pages
    end
end

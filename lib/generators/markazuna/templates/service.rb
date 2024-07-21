class <%= class_name %>Service
    def create_<%= singular_name %>(<%= singular_name %>_form)
        <%= singular_name %>_form.save
    end

    def update_<%= singular_name %>(<%= singular_name %>_form)
        <%= singular_name %>_form.update
    end

    def delete_<%= singular_name %>(id)
        <%= singular_name %> = find_<%= singular_name %>(id)
        return <%= singular_name %>.delete, <%= class_name %>.page(1).total_pages
    end

    def find_<%= singular_name %>(id)
        <%= class_name %>.find(id)
    end

    def find_<%= plural_name %>(query)
        page = query.delete(:page).to_i        
        query = {}  ## Configure the search first
        res = <%= class_name %>.where(query)
        total_pages = ( res.count().to_f / <%= class_name %>.default_per_page ).ceil  #res.total_pages    
        return res.page(page) , total_pages
    end
end

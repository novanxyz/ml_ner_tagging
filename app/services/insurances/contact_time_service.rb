class Insurances::ContactTimeService
    def create_contact_time(contact_time_form)
        contact_time_form.save
    end

    def update_contact_time(contact_time_form)
        contact_time_form.update
    end

    def delete_contact_time(id)
        contact_time = find_contact_time(id)
        return contact_time.delete, Insurances::ContactTime.page(1).total_pages
    end

    def find_contact_time(id)
        Insurances::ContactTime.find(id)
    end

    def find_contact_times(query)
        page = query.delete(:page).to_i        
        query = {}  ## Configure the search first
        res = Insurances::ContactTime.where(query)
        total_pages = ( res.count().to_f / Insurances::ContactTime.default_per_page ).ceil  #res.total_pages    
        return res.page(page) , total_pages
    end
end

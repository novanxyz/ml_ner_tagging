class Core::InterestService
    def create_interest(interest_form)
        interest_form.save
    end

    def update_interest(interest_form)
        interest_form.update
    end

    def delete_interest(id)
        interest = find_interest(id)
        return interest.delete, Core::Interest.page(1).total_pages
    end

    def find_interest(id)
        Core::Interest.find(id)
    end

    def find_interests(query)
        page = query.delete(:page).to_i        
        if query.key?"search"
            q = query.delete("search")
            query[:name] = /.*#{q}.*/i
        end        
        query[:is_deleted] = false
        res = Core::Interest.where(query)
        total_pages = ( res.count() / Core::Interest.default_per_page ).ceil  #res.total_pages    
        return res.page(page) , total_pages
        return Core::Interest.page(page), Core::Interest.page(1).total_pages
    end
end

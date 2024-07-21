class Core::DivisionService
    def create_division(division_form)
        division_form.save
    end

    def update_division(division_form)
        division_form.update
    end

    def delete_division(id)
        division = find_division(id)
        return division.delete, Core::Division.page(1).total_pages
    end

    def find_division(id)
        Core::Division.find(id)
    end

    def find_divisions(query)
        page = query.delete(:page).to_i        
        if query.key?"search"
            q = query.delete("search")
            query[:name] = /.*#{q}.*/i
        end
        query[:is_deleted] = false
        res = Core::Division.where(query)
        total_pages = ( res.count().to_f / Core::Division.default_per_page ).ceil  #res.total_pages    
        ret = res.page(page)
        divs = []
        ret.each do |d|                 
            divs << {:id => d.id.to_s , :name => d.name, :admins => d.admins,  :admin_cnt => d.admins.count }                
        end
        return divs , total_pages
    end
end

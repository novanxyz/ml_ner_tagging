class Core::DivisionActionService
    def create_division_action(division_action_form)
        division_action_form.save
    end

    def update_division_action(division_action_form)
        division_action_form.update
    end

    def delete_division_action(id)
        division_action = find_division_action(id)
        return division_action.delete, Core::DivisionAction.page(1).total_pages
    end

    def find_division_action(id)
        Core::DivisionAction.find(id)
    end

    def find_division_actions(query)
        page = query.delete(:page).to_i        
        query = {}  ## Configure the search first
        res = Core::DivisionAction.where(query)
        total_pages = ( res.count() / Core::DivisionAction.default_per_page ).ceil  #res.total_pages    
        return res.page(page) , total_pages
        return Core::DivisionAction.page(page), Core::DivisionAction.page(1).total_pages
    end
end

class Insurances::TemplateService
    def create_template(template_form)
        template_form.save
    end

    def update_template(template_form)
        template_form.update
    end

    def delete_template(id)
        template = find_template(id)
        return template.delete, Insurances::Template.page(1).total_pages
    end

    def find_template(id)
        Insurances::Template.find(id)
    end

    def find_templates(query)
        page = query.delete(:page).to_i
        if query.key?"search"
            q = query.delete("search")
            query[:caption] = /.*#{q}.*/i
        end
        
        res = Insurances::Template.where(query)
        total_pages = ( res.count().to_f / Insurances::Template.default_per_page ).ceil  #res.total_pages    
        return res.page(page) , total_pages
    end
end

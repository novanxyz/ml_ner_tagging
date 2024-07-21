class Insurances::ProviderService
    def create_provider(provider_form)
        provider_form.save
    end

    def update_provider(provider_form)
        provider_form.update
    end

    def delete_provider(id)
        provider = find_provider(id)
        return provider.delete, Insurances::Provider.page(1).total_pages
    end

    def find_provider(id)
        Insurances::Provider.find(id)
    end

    def find_providers(query)
        page = query.delete(:page).to_i        
        query = {}  ## Configure the search first
        res = Insurances::Provider.where(query)
        total_pages = ( res.count().to_f / Insurances::Provider.default_per_page ).ceil  #res.total_pages    
        return res.page(page) , total_pages
    end
end

class Insurances::FaqService
    def create_faq(faq_form)
        faq_form.save
    end

    def update_faq(faq_form)
        faq_form.update
    end

    def delete_faq(id)
        faq = find_faq(id)
        return faq.delete, Insurances::Faq.page(1).total_pages
    end

    def find_faq(id)
        Insurances::Faq.find(id)
    end

    def find_faqs(query)
        page = query.delete(:page).to_i        
        query = {}  ## Configure the search first
        res = Insurances::Faq.where(query)
        total_pages = ( res.count().to_f / Insurances::Faq.default_per_page ).ceil  #res.total_pages    
        return res.page(page) , total_pages
    end
end

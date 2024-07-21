class Insurances::ClaimService
    def create_claim(claim_form)
        claim_form.save
    end

    def update_claim(claim_form)
        claim_form.update
    end

    def delete_claim(id)
        claim = find_claim(id)
        return claim.delete, Insurances::Claim.page(1).total_pages
    end

    def find_claim(id)
        Insurances::Claim.find(id)
    end

    def find_claims(query)
        page = query.delete(:page).to_i
        if query.key?"search"
            q = query.delete("search")
            query[:number] = /.*#{q}.*/i
        end

        res = Insurances::Claim.where(query)        
        total_pages = ( res.count().to_f / Insurances::Claim.default_per_page ).ceil  #res.total_pages    
        return res.page(page) , total_pages
    end
end

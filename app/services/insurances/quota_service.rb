class Insurances::QuotaService
    def create_quota(quota_form)
        quota_form.save
    end

    def update_quota(quota_form)
        quota_form.update
    end

    def delete_quota(id)
        quota = find_quota(id)
        return quota.delete, Insurances::Quota.page(1).total_pages
    end

    def find_quota(id)
        Insurances::Quota.find(id)
    end

    def find_quota(query)
        page = query.delete(:page).to_i
        res = Insurances::Quota.where(query).order({:end_date => -1 })
        total_pages = ( res.count().to_f / Insurances::Quota.default_per_page ).ceil  #res.total_pages    
        return res.page(page) , total_pages
    end
end

class Insurances::InsuranceService
    def create_insurance(insurance_form)
        insurance_form.save
    end

    def update_insurance(insurance_form)
        insurance_form.update
    end

    def delete_insurance(id)
        insurance = find_insurance(id)
        return insurance.delete, Insurances::Insurance.page(1).total_pages
    end

    def find_insurance(id)
        Insurances::Insurance.find(id)
    end

    def find_insurances(query)
        page = query.delete(:page).to_i        
        res = Insurances::Insurance.where(query)
        total_pages = ( res.count() / Insurances::Insurance.default_per_page ).ceil  #res.total_pages    
        insurances = []
        res.page(page).each do |ins |
            insurance =  {}
            insurance[:id]      = ins.id.to_s            
            insurance[:user]    = ins.user
            insurance[:user][:city]   = ins.user.city
            insurance[:city]    =  ins.user.city
            insurance[:user][:version]   = ins.user.version
            insurance[:policy_number] = ins.policy_number
            insurance[:policy_holder] = ins.policy_holder
            insurance[:policy_type] = ins.policy_type
            insurance[:policy_holder] = ins.policy_holder
            insurance[:fullname]=  if ins.policy_holder.blank? then ins.user.fullname  else ins.policy_holder end
            # insurance[:created_at]= ins.created_at.in_time_zone('Jakarta').strftime('%d/%m/%Y')
            insurance[:start_date]= ins.start_date.in_time_zone('Jakarta').strftime('%d/%m/%Y') rescue ''
            insurance[:end_date]= ins.end_date.in_time_zone('Jakarta').strftime('%d/%m/%Y') rescue ''
            insurance[:approved_date]= ins.approved_date.in_time_zone('Jakarta').strftime('%d/%m/%Y')  rescue ''            
            insurance[:payment_end_date]= ins.payment_end_date.in_time_zone('Jakarta').strftime('%d/%m/%Y')  rescue ''                       
            insurance[:status]= ins.status            
            insurance[:total_month_paid]= ins.total_month_paid
            insurance[:phone_number]= ins.phone_number            
            insurance[:email]= ins.email
            insurance[:source]= ins.source rescue 'android'            
            insurance[:file_policy]= ins.file_policy
            insurance[:file_policy_uploaded_at]= ins.file_policy_uploaded_at
            insurance[:moderated_by] = ins.moderated_by
            insurances << insurance
        end
        return insurances , total_pages        
    end
end

class Core::DoctorService
    def create_doctor(doctor_form)
        doctor_form.save
    end

    def update_doctor(doctor_form)
        doctor_form.update
    end

    def delete_doctor(id)
        doctor = find_doctor(id)
        return doctor.delete, Core::Doctor.page(1).total_pages
    end

    def find_doctor(id)
        Core::Doctor.find(id)
    end

    def find_doctors(query)
        page = query.delete(:page).to_i        
        if query.key?"search"
            q = query.delete("search")
            query[:firstname] = /.*#{q}.*/i
        end        
        query[:_type] = 'Core:User'       
        res = Core::Doctor.where(query)
        total_pages = ( res.count() / Core::Doctor.default_per_page ).ceil  #res.total_pages    
        return res.page(page) , total_pages
        return Core::Doctor.page(page), Core::Doctor.page(1).total_pages
    end
end

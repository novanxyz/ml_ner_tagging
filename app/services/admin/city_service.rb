class Admin::CityService
    def create_city(city_form)
        city_form.save
    end

    def update_city(city_form)
        city_form.update
    end

    def delete_city(id)
        city = find_city(id)
        return city.delete, Admin::City.page(1).total_pages
    end

    def find_city(id)
        Admin::City.find(id)
    end

    def find_cities(query)
        page = query.delete(:page).to_i
        if query.key?"search"
            q = query.delete("search")
            query[:name] = /.*#{q}.*/i
        end
        res = Admin::City.where(query).order_by({:name => 1})
        total_pages = (res.count() / Admin::City.default_per_page).ceil  #res.total_pages
        puts total_pages
        return res.page(page) , total_pages
    end
end

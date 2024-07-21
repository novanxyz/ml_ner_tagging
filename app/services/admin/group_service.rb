class Admin::GroupService
    def create_group(group_form)
        group_form.save
    end

    def update_group(group_form)
        group_form.update
    end

    def delete_group(id)
        group = find_group(id)
        return group.delete, Admin::Group.page(1).total_pages
    end

    def find_group(id)
        Admin::Group.find(id)
    end

    def find_groups(page = 0)
        return Admin::Group.page(page), Admin::Group.page(1).total_pages
    end
end

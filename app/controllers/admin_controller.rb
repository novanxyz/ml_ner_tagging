require_dependency 'markazuna/di_container'

class AdminController < ApplicationController
    def index

    end

    def page
        case params[:name]
            when 'articles'
                render template: 'core/articles'

            when 'groups'
                render template: 'admin/groups'

            when 'users'
                render template: 'admin/users'
        end
    end
end

require_dependency 'markazuna/di_container'

class BackofficeController < ApplicationController
    def index        
    end

    def page

        begin
            puts params
            path = if params['name'].nil? then 'admin' else params['path'] end         
            name = if params['name'].nil? then params['path'] else params['name'] end
            path = 'core' if ['admins','users','divisions'].include?name
            path = 'insurances' if ['insurances','claims','quota'].include?name
            puts "#{path}/#{name}"        
            render template: "#{path}/#{name}"        
        rescue 
            path = 'backoffice'
            name = 'index'
            render template: "#{path}/#{name}"
        end

    end
    
end

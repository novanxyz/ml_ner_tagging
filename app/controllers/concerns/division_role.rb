module DivisionRole

    def authenticate_division!
        default_redirect = backoffice_path
        dn = current_user.division.name rescue ''
        ctrl = params[:controller]
        act = params[:action]

        return unless current_user
        ## escape old superadmin
        return if current_user.class.name == "Core::Admin" && current_user.role.name == 'admin'
        ## change this if default_redirect is changed
        return if ctrl == 'backoffice/dashboards'

        if current_user && current_user.role.blank?
            access_denied(default_redirect)
        else
            assign_location_variable(current_user)

            if get(dn).key?('only')
                access_denied(default_redirect) unless get(dn)['only'].key?(ctrl)
                return if get(dn)['only'][ctrl].blank?
                access_denied(default_redirect) unless get(dn)['only'][ctrl].include?(act)
            elsif get(dn).key?('except')
                return if get(dn)['except'].blank? || !get(dn)['except'].key?(ctrl)
                access_denied(default_redirect) if get(dn)['except'][ctrl].blank? || get(dn)['except'][ctrl].include?(act)
            end
        end
    end

    def assign_location_variable(user)
        instance_variable_set("@division_#{user.division.name.parameterize.underscore}", {
            user.division.rule => user.division.group_action_to_area
        })
    end

    def get(dn)
        instance_variable_get("@division_#{dn.parameterize.underscore}")
    end

    def access_denied(default_redirect)
        if request.xhr?
            flash[:alert] = 'Access Denied'
            flash.keep(:alert)
            render :js => "window.location = #{default_redirect}"
        else
            redirect_to default_redirect, status: 301, :flash => { :alert => 'Access Denied. Please call superadmin.' }
        end
    end

    # def get_ctrl(default_redirect)
    #     Rails.application.routes.recognize_path(default_redirect)[:controller]
    # end
    #
    # def get_act(default_redirect)
    #     Rails.application.routes.recognize_path(default_redirect)[:action]
    # end
end
require 'json'

class ApplicationController < ActionController::Base
    include BackofficeAuthenticatable
    include DivisionRole
    include ActionController::MimeResponds

    before_action :authenticate_user!
    before_action :authenticate_with_role!
    before_action :authenticate_division!, :unless => :dashboard?
    respond_to :html, :json


    layout :layout_by_resource

    def layout_by_resource
        if user_signed_in?
            'application'
        else
            'login'
        end
    end

    def go_to_page(conditions, url, notice)
        redirect_to(url, notice: notice) if conditions
    end

    private
    def dashboard?
        params[:controller] == "backoffice/dashboards"
    end



    # Overwriting the sign_in redirect path method
    def after_sign_in_path_for(resource)
        Rails.application.routes.url_helpers.backoffice_path
    end

    # Overwriting the sign_out redirect path method
    def after_sign_out_path_for(resource_or_scope)
        Rails.application.routes.url_helpers.backoffice_path
    end
end

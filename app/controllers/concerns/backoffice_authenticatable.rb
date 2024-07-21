module BackofficeAuthenticatable
    def authenticate_with_role!
        # redirect_to root_path, status: 301 unless user_signed_in?
        # if user_signed_in?
        #     if current_core_user.group_id != Admin::Group.find_by(name: 'admin')
        #         sign_out current_core_user
        #         redirect_to admin_path, status: 301, :flash => { :error => "Access Denied" }
        #     end
        # else
        #     redirect_to admin_path, status: 301
        # end
    end

    def user_signed_in?
        current_user.present?
    end
    

end

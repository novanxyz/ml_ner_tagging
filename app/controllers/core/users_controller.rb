require_dependency 'markazuna/di_container'


class Core::UsersController < ApplicationController
    include Markazuna::INJECT['user_service']
    include Markazuna::INJECT['city_service']
    include MetaDescriptionHelper

    # http://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html
    wrap_parameters :core_user, include: [:id, :email, :username, :firstname, :lastname,:gender, :birthday, :password,:city, :phone, :interests => [] ]

    def index
        query = query_params.reject{|_, v| v.blank? || v == 'null'}

        users, page_count = user_service.find_users(query)
        if (users.size > 0)
            respond_to do |format|
                format.json { render :json => { results: users, count: page_count }}
            end
        else
            render :json => { results: []}
        end
    end

    def delete
        status, page_count = user_service.delete_user(params[:id])
        if status
            respond_to do |format|
                format.json { render :json => { status: "200", count: page_count } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def create
        user_form = Core::UserForm.new(user_form_params)
        if user_service.create_user(user_form)
            respond_to do |format|
                format.json { render :json => { status: "200", message: "Success" } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def edit
        id = params[:id]
        @user = user_service.find_user(id)
        
        if @user            
            respond_to do |format|
                format.json { render :json => { status: "200", payload: @user } }
                format.html do
                    view_data
                    @city = Admin::City.all()                    
                    @interests = Core::Interest.all()
                    @url = user_path(@user) 
                    render "users/edit" 
                end
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def update
        update_params = user_form_params.to_h
        update_params[:id] = params[:id] unless update_params[:id] 
        update_params[:interests] = update_params[:interests].reject{|v| v.blank? || v == 'null'}
        user_form = Core::UserForm.new(update_params)
        puts update_params
        puts user_form
        
        if user_service.update_user(user_form) == true            
            respond_to do |format|
                format.json { render :json => { status: "200", message: "Success" } }
                format.html { redirect_to core_user_path(params[:id])}
            end
        else
            puts user_form.errors.messages
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
                format.html { redirect_to user_edit_path(params[:id]), :flash => user_form.errors.messages }
            end
        end
    end

    def show   
        @user =  user_service.find_user(params[:id])
        view_data
        render 'users/show'        
    end

    def send_notif_by_interest
        message = Core::User.send_notif_by_interest(params)

        redirect_to log_user_notification_backoffice_users_url, notice: message.first[:message] rescue 'Something when wrong'
    end

    def send_notif_by_user
        message = Core::User.send_notif_by_user(params)

        redirect_to log_user_notification_backoffice_users_url, notice: message.first[:message] rescue 'Something when wrong'
    end

    def send_notif_by_all_user
        message = Core::User.send_notif_by_all_user(params)

        redirect_to log_user_notification_backoffice_users_url, notice: message.first[:message] rescue 'Something when wrong'
    end

    private
   
    def view_data
        @meta_descriptions = []
        except_sequence = [1,2]
        @user.meta_descriptions.each do |question_meta_description|
            if !except_sequence.include?(question_meta_description.meta_description.sequence)
                @meta_descriptions << { sequence: question_meta_description.meta_description.sequence, 
                                        value: format_meta_description_value(question_meta_description)}
            end
        end        
    end

    def query_params        
        params.permit(:email, :username, :firstname, :lastname, :page, :search).to_h
    end

    # Using strong parameters
    def user_form_params
        params.require(:core_user).permit(:id, :email, :username, :firstname, :lastname,:birthday, :gender, :interests,  :password, :city, :phone, interests: [] )
        # params.require(:core_user).permit! # allow all
    end

    
end
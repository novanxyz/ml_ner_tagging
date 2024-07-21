require_dependency 'markazuna/di_container'

class Core::AdminsController < ApplicationController
    include Markazuna::INJECT['admin_service']

    # http://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html
    wrap_parameters :admin, include: [:id, :email, :username, :firstname, :lastname]

    def index
        query = query_params.reject{|_, v| v.blank? || v == 'null'}

        admins, page_count = admin_service.find_admins(query)
        if (admins.size > 0)
            respond_to do |format|
                format.json { render :json => { results: admins, count: page_count }}
            end
        else
            render :json => { results: []}
        end
    end

    def delete
        status, page_count = admin_service.delete_admin(params[:id])
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
        admin_form = Core::AdminForm.new(admin_form_params)
        if admin_service.create_admin(admin_form)
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
        admin = admin_service.find_admin(id)

        if admin
            respond_to do |format|
                format.json { render :json => { status: "200", payload: admin } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def update
        admin_form = Core::AdminForm.new(admin_form_params)
        if admin_service.update_admin(admin_form)
            respond_to do |format|
                format.json { render :json => { status: "200", message: "Success" } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    private
    def query_params        
        params.permit(:email, :username, :firstname, :lastname, :page, :search).to_h
    end

    # Using strong parameters
    def admin_form_params
        params.require(:admin).permit(:id, :email, :username, :firstname, :lastname)
        # params.require(:core_user).permit! # allow all
    end
end
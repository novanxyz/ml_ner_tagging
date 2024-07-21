require_dependency 'markazuna/di_container'

class Core::RolesController < ApplicationController
    include Markazuna::INJECT['role_service']

    # http://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html
    wrap_parameters :role, include: [:id, :name]

    def index
        query = query_params.reject{|_, v| v.blank? || v == 'null'}

        roles, page_count = role_service.find_roles(query)
        if (roles.size > 0)
            respond_to do |format|
                format.json { render :json => { results: roles, count: page_count }}
            end
        else
            render :json => { results: []}
        end
    end

    def delete
        status, page_count = role_service.delete_role(params[:id])
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
        role_form = Core::RoleForm.new(role_form_params)
        if role_service.create_role(role_form)
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
        role = role_service.find_role(id)

        if role
            respond_to do |format|
                format.json { render :json => { status: "200", payload: role } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def update
        role_form = Core::RoleForm.new(role_form_params)
        if role_service.update_role(role_form)
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
        params.permit(:name, :page, :search).to_h
    end

    # Using strong parameters
    def role_form_params
        params.require(:role).permit(:id, :name)
        # params.require(:core_user).permit! # allow all
    end
end
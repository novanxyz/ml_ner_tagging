require_dependency 'markazuna/di_container'

class Admin::GroupsController < ApplicationController
    include Markazuna::INJECT['group_service']

    # http://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html
    wrap_parameters :group, include: [:id, :name, :description]

    def index
        groups, page_count = group_service.find_groups(params[:page])
        if (groups.size > 0)
            respond_to do |format|
                format.json { render :json => { results: groups, count: page_count }}
            end
        else
            render :json => { results: []}
        end
    end

    def delete
        status, page_count = group_service.delete_group(params[:id])
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
        group_form = Admin::GroupForm.new(group_form_params)
        if group_service.create_group(group_form)
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
        group = group_service.find_group(id)

        if group
            respond_to do |format|
                format.json { render :json => { status: "200", payload: group } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def update
        group_form = Admin::GroupForm.new(group_form_params)
        if group_service.update_group(group_form)
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

    # Using strong parameters
    def group_form_params
        params.require(:group).permit(:id, :name, :description)
        # params.require(:core_user).permit! # allow all
    end
end
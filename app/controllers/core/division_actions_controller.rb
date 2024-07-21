require_dependency 'markazuna/di_container'

class Core::DivisionActionsController < ApplicationController
    include Markazuna::INJECT['division_action_service']

    # http://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html
    wrap_parameters :division_action, include: [:id, :name, :path, :is_deleted]

    def index
        query = query_params.reject{|_, v| v.blank? || v == 'null'}

        division_actions, page_count = division_action_service.find_division_actions(query)
        if (division_actions.size > 0)
            respond_to do |format|
                format.json { render :json => { results: division_actions, count: page_count }}
            end
        else
            render :json => { results: []}
        end
    end

    def delete
        status, page_count = division_action_service.delete_division_action(params[:id])
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
        division_action_form = Core::DivisionActionForm.new(division_action_form_params)
        if division_action_service.create_division_action(division_action_form)
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
        division_action = division_action_service.find_division_action(id)

        if division_action
            respond_to do |format|
                format.json { render :json => { status: "200", payload: division_action } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def update
        division_action_form = Core::DivisionActionForm.new(division_action_form_params)
        if division_action_service.update_division_action(division_action_form)
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
        params.permit(:name, :path, :is_deleted, :page, :search).to_h
    end

    # Using strong parameters
    def division_action_form_params
        params.require(:division_action).permit(:id, :name, :path, :is_deleted)
        # params.require(:core_user).permit! # allow all
    end
end
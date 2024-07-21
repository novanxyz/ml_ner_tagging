require_dependency 'markazuna/di_container'

class Core::DivisionsController < ApplicationController
    include Markazuna::INJECT['division_service']

    # http://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html
    wrap_parameters :division, include: [:id, :name, :rule, :division_page, :is_deleted ]

    def index
        query = query_params.reject{|_, v| v.blank? || v == 'null'}

        divisions, page_count = division_service.find_divisions(query)                
        if (divisions.size > 0)            
            respond_to do |format|
                format.json { render :json => { results: divisions, count: page_count }}
            end
        else
            render :json => { results: []}
        end
    end

    def delete
        status, page_count = division_service.delete_division(params[:id])
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
        division_form = Core::DivisionForm.new(division_form_params)
        if division_service.create_division(division_form)
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
        division = division_service.find_division(id)

        if division
            respond_to do |format|
                format.json { render :json => { status: "200", payload: division } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def update
        division_form = Core::DivisionForm.new(division_form_params)
        if division_service.update_division(division_form)
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
        params.permit(:name, :rule, :division_page, :is_deleted, :page, :search).to_h
    end

    # Using strong parameters
    def division_form_params
        params.require(:division).permit(:id, :name, :rule, :division_page, :is_deleted)
        # params.require(:core_user).permit! # allow all
    end
end
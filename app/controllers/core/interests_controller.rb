require_dependency 'markazuna/di_container'

class Core::InterestsController < ApplicationController
    include Markazuna::INJECT['interest_service']

    # http://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html
    wrap_parameters :interest, include: [:id, :name, :is_deleted]

    def index
        query = query_params.reject{|_, v| v.blank? || v == 'null'}

        interests, page_count = interest_service.find_interests(query)
        if (interests.size > 0)
            respond_to do |format|
                format.json { render :json => { results: interests, count: page_count }}
            end
        else
            render :json => { results: []}
        end
    end

    def delete
        status, page_count = interest_service.delete_interest(params[:id])
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
        interest_form = Core::InterestForm.new(interest_form_params)
        if interest_service.create_interest(interest_form)
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
        interest = interest_service.find_interest(id)

        if interest
            respond_to do |format|
                format.json { render :json => { status: "200", payload: interest } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def update
        interest_form = Core::InterestForm.new(interest_form_params)
        if interest_service.update_interest(interest_form)
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
        params.permit(:name, :is_deleted, :page, :search).to_h
    end

    # Using strong parameters
    def interest_form_params
        params.require(:interest).permit(:id, :name, :is_deleted)
        # params.require(:core_user).permit! # allow all
    end
end
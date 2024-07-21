require_dependency 'markazuna/di_container'

class Insurances::InsurancesController < ApplicationController
    include Markazuna::INJECT['insurance_service']
    include Markazuna::INJECT['user_service']

    # http://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html
    wrap_parameters :insurance, include: [:policy_number, :start_date, :end_date, :policy_holder, :status, :policy_type, :payment_end_date, :total_month_paid, :source, :fullname, :phone_number, :email, :file_policy, :file_policy_uploaded_at, :approved_date]

    def index
        query = query_params.reject{|_, v| v.blank? || v == 'null'}

        insurances, page_count = insurance_service.find_insurances(query)
        if (insurances.size > 0)
            respond_to do |format|
                format.json { render :json => { results: insurances, count: page_count }}
            end
        else
            render :json => { results: []}
        end
    end

    def delete
        status, page_count = insurance_service.delete_insurance(params[:id])
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
        insurance_form = Insurances::InsuranceForm.new(insurance_form_params)
        if insurance_service.create_insurance(insurance_form)
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
        insurance = insurance_service.find_insurance(id)

        if insurance
            respond_to do |format|
                format.json { render :json => { status: "200", payload: insurance } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def update
        insurance_form = Insurances::InsuranceForm.new(insurance_form_params)
        if insurance_service.update_insurance(insurance_form)
            respond_to do |format|
                format.json { render :json => { status: "200", message: "Success" } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def show
        @insurance = insurance_service.find_insurance(params[:id])
        render "insurances/show"
    end

    private
    def query_params        
        params.permit(:policy_number, :start_date, :end_date, :policy_holder, :status, :policy_type, :payment_end_date, :total_month_paid, :source, :fullname, :phone_number, :email, :file_policy, :file_policy_uploaded_at, :approved_date, :page, :search).to_h
    end

    # Using strong parameters
    def insurance_form_params
        params.require(:insurance).permit(:policy_number, :start_date, :end_date, :policy_holder, :status, :policy_type, :payment_end_date, :total_month_paid, :source, :fullname, :phone_number, :email, :file_policy, :file_policy_uploaded_at, :approved_date)
        # params.require(:core_user).permit! # allow all
    end
end
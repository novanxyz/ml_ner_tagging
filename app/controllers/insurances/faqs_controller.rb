require_dependency 'markazuna/di_container'

class Insurances::FaqsController < ApplicationController
    include Markazuna::INJECT['faq_service']

    # http://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html
    wrap_parameters :faq, include: [:question, :answer, :position]

    def index
        query = query_params.reject{|_, v| v.blank? || v == 'null'}

        faqs, page_count = faq_service.find_faqs(query)
        if (faqs.size > 0)
            respond_to do |format|
                format.json { render :json => { results: faqs, count: page_count }}
            end
        else
            render :json => { results: []}
        end
    end

    def delete
        status, page_count = faq_service.delete_faq(params[:id])
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
        faq_form = Insurances::FaqForm.new(faq_form_params)
        if faq_service.create_faq(faq_form)
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
        faq = faq_service.find_faq(id)

        if faq
            respond_to do |format|
                format.json { render :json => { status: "200", payload: faq } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def update
        faq_form = Insurances::FaqForm.new(faq_form_params)
        if faq_service.update_faq(faq_form)
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
        params.permit(:question, :answer, :position, :page, :search).to_h
    end

    # Using strong parameters
    def faq_form_params
        params.require(:faq).permit(:question, :answer, :position)
        # params.require(:core_user).permit! # allow all
    end
end
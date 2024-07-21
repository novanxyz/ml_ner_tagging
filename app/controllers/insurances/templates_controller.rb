require_dependency 'markazuna/di_container'

class Insurances::TemplatesController < ApplicationController
    include Markazuna::INJECT['template_service']

    # http://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html
    wrap_parameters :template, include: [:caption, :title_approval, :description_approval, :image_url_approval, :is_active]

    def index
        query = query_params.reject{|_, v| v.blank? || v == 'null'}

        templates, page_count = template_service.find_templates(query)
        if (templates.size > 0)
            respond_to do |format|
                format.json { render :json => { results: templates, count: page_count }}
            end
        else
            render :json => { results: []}
        end
    end

    def delete
        status, page_count = template_service.delete_template(params[:id])
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
        template_form = Insurances::TemplateForm.new(template_form_params)
        if template_service.create_template(template_form)
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
        template = template_service.find_template(id)

        if template
            respond_to do |format|
                format.json { render :json => { status: "200", payload: template } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def update
        template_form = Insurances::TemplateForm.new(template_form_params)
        if template_service.update_template(template_form)
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
        params.permit(:caption, :title_approval, :description_approval, :image_url_approval, :is_active, :page, :search).to_h
    end

    # Using strong parameters
    def template_form_params
        params.require(:template).permit(:caption, :title_approval, :description_approval, :image_url_approval, :is_active)
        # params.require(:core_user).permit! # allow all
    end
end
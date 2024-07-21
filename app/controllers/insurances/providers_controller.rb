require_dependency 'markazuna/di_container'

class Insurances::ProvidersController < ApplicationController
    include Markazuna::INJECT['provider_service']

    # http://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html
    wrap_parameters :provider, include: [:name, :description, :icon_url, :mobile_phone, :is_active]

    def index
        query = query_params.reject{|_, v| v.blank? || v == 'null'}

        providers, page_count = provider_service.find_providers(query)
        if (providers.size > 0)
            respond_to do |format|
                format.json { render :json => { results: providers, count: page_count }}
            end
        else
            render :json => { results: []}
        end
    end

    def delete
        status, page_count = provider_service.delete_provider(params[:id])
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
        provider_form = Insurances::ProviderForm.new(provider_form_params)
        if provider_service.create_provider(provider_form)
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
        provider = provider_service.find_provider(id)

        if provider
            respond_to do |format|
                format.json { render :json => { status: "200", payload: provider } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def update
        provider_form = Insurances::ProviderForm.new(provider_form_params)
        if provider_service.update_provider(provider_form)
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
        params.permit(:name, :description, :icon_url, :mobile_phone, :is_active, :page, :search).to_h
    end

    # Using strong parameters
    def provider_form_params
        params.require(:provider).permit(:name, :description, :icon_url, :mobile_phone, :is_active)
        # params.require(:core_user).permit! # allow all
    end
end
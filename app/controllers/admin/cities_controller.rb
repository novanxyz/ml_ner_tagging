require_dependency 'markazuna/di_container'

class Admin::CitiesController < ApplicationController
    include Markazuna::INJECT['city_service']

    # http://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html
    wrap_parameters :city, include: [:id, :name, :is_deleted, :coordinates, :permalink, :uid]

    def index
        query = query_params.reject{|_, v| v.blank? || v == 'null'}
        cities, page_count = city_service.find_cities(query)
        if (cities.size > 0)
            respond_to do |format|
                format.json { render :json => { results: cities, count: page_count }}
            end
        else
            render :json => { results: []}
        end
    end

    def delete
        status, page_count = city_service.delete_city(params[:id])
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
        city_form = Admin::CityForm.new(city_form_params)
        if city_service.create_city(city_form)
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
        city = city_service.find_city(id)

        if city
            respond_to do |format|
                format.json { render :json => { status: "200", payload: city } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def update
        city_form = Admin::CityForm.new(city_form_params)
        puts city_form_params
        if city_service.update_city(city_form)
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
        params.permit(:name, :is_deleted, :coordinates, :permalink, :uid, :page, :search).to_h
    end

    # Using strong parameters
    def city_form_params
        params.require(:city).permit!#(:name, :is_deleted, :coordinates, :permalink, :uid)
        # params.require(:core_user).permit! # allow all
    end
end
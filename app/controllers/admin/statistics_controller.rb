require_dependency 'markazuna/di_container'

class Admin::StatisticsController < ApplicationController
    include Markazuna::INJECT['statistic_service']

    # http://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html
    wrap_parameters :statistic, include: [:name, :label, :value, :delta, :stat_time]

    def index
        query = query_params.reject{|_, v| v.blank? || v == 'null'}

        statistics, page_count = statistic_service.find_dashboard_statistics(query)
        
        if (statistics.size > 0)
            respond_to do |format|
                format.json { render :json => { results: statistics, count: page_count }}
            end
        else
            render :json => { results: []}
        end
    end

    def delete
        status, page_count = statistic_service.delete_statistic(params[:id])
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
        statistic_form = Admin::StatisticForm.new(statistic_form_params)
        if statistic_service.create_statistic(statistic_form)
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
        statistic = statistic_service.find_statistic(id)

        if statistic
            respond_to do |format|
                format.json { render :json => { status: "200", payload: statistic } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def update
        statistic_form = Admin::StatisticForm.new(statistic_form_params)
        if statistic_service.update_statistic(statistic_form)
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
        params.permit(:name, :label, :value, :delta, :stat_time, :page, :search,:type, :start_date, :end_date).to_h
    end

    # Using strong parameters
    def statistic_form_params
        params.require(:statistic).permit(:name, :label, :value, :delta, :stat_time)
        # params.require(:core_user).permit! # allow all
    end
end
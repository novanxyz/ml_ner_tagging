require_dependency 'markazuna/di_container'

class Core::DoctorsController < ApplicationController
    include Markazuna::INJECT['doctor_service']

    # http://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html
    wrap_parameters :doctor, include: [:id, :uid, :rate, :price, :thanks]

    def index
        query = query_params.reject{|_, v| v.blank? || v == 'null'}

        doctors, page_count = doctor_service.find_doctors(query)
        if (doctors.size > 0)
            respond_to do |format|
                format.json { render :json => { results: doctors, count: page_count }}
            end
        else
            render :json => { results: []}
        end
    end

    def delete
        status, page_count = doctor_service.delete_doctor(params[:id])
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
        doctor_form = Core::DoctorForm.new(doctor_form_params)
        if doctor_service.create_doctor(doctor_form)
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
        doctor = doctor_service.find_doctor(id)

        if doctor
            respond_to do |format|
                format.json { render :json => { status: "200", payload: doctor } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def update
        doctor_form = Core::DoctorForm.new(doctor_form_params)
        if doctor_service.update_doctor(doctor_form)
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
        params.permit(:doctor).permit(:uid, :rate, :price, :thanks, :page, :search).to_h
    end

    # Using strong parameters
    def doctor_form_params
        params.require(:doctor).permit(:id, :uid, :rate, :price, :thanks)
        # params.require(:core_user).permit! # allow all
    end
end
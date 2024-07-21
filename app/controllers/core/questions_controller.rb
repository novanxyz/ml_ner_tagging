require_dependency 'markazuna/di_container'

class Core::QuestionsController < ApplicationController
    include Markazuna::INJECT['question_service']

    # http://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html
    wrap_parameters :question, include: [:access_type, :user_unread_count, :doctor_unread_count, :is_said_thanks, :is_paid, :time_picked_up, :status_question_user, :status_question_doctor, :time_choice_intent, :time_choice_sub_intent, :time_conclusion_recommendation]

    def index
        query = query_params.reject{|_, v| v.blank? || v == 'null'}

        questions, page_count = question_service.find_questions(query)
        if (questions.size > 0)
            respond_to do |format|
                format.json { render :json => { results: questions, count: page_count }}
            end
        else
            render :json => { results: []}
        end
    end

    def delete
        status, page_count = question_service.delete_question(params[:id])
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
        question_form = Core::QuestionForm.new(question_form_params)
        if question_service.create_question(question_form)
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
        question = question_service.find_question(id)

        if question
            respond_to do |format|
                format.json { render :json => { status: "200", payload: question } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def update
        question_form = Core::QuestionForm.new(question_form_params)
        if question_service.update_question(question_form)
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
        params.permit(:access_type, :user_unread_count, :doctor_unread_count, :is_said_thanks, :is_paid, :time_picked_up, :status_question_user, :status_question_doctor, :time_choice_intent, :time_choice_sub_intent, :time_conclusion_recommendation, :page, :search, :user_id ).to_h
    end

    # Using strong parameters
    def question_form_params
        params.require(:question).permit(:access_type, :user_unread_count, :doctor_unread_count, :is_said_thanks, :is_paid, :time_picked_up, :status_question_user, :status_question_doctor, :time_choice_intent, :time_choice_sub_intent, :time_conclusion_recommendation)
        # params.require(:core_user).permit! # allow all
    end
end
require_dependency 'markazuna/di_container'

class Insurances::ClaimsController < ApplicationController
    include Markazuna::INJECT['claim_service']

    # http://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html
    wrap_parameters :claim, include: [:increment_claim, :clain_number, :reject_time, :accept_time, :status, :reviewer_comment, :is_finish ]

    def index
        query = query_params.reject{|_, v| v.blank? || v == 'null'}

        if query[:created_at].present?
            query[:created_at] = JSON.parse(query[:created_at])             
            query[:created_at][:$gte] = Date.parse(query[:created_at][:$gte])
            query[:created_at][:$lte] = Date.parse(query[:created_at][:$lte])
        end
                
        claims, page_count = claim_service.find_claims(query)
        if (claims.size > 0)
            respond_to do |format|
                format.json { render :json => { results: claims, count: page_count }}
            end
        else
            render :json => { results: []}
        end
    end

    def delete
        status, page_count = claim_service.delete_claim(params[:id])
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
        claim_form = Insurances::ClaimForm.new(claim_form_params)
        if claim_service.create_claim(claim_form)
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
        claim = claim_service.find_claim(id)

        if claim
            respond_to do |format|
                format.json { render :json => { status: "200", payload: claim } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def update
        claim_form = Insurances::ClaimForm.new(claim_form_params)
        if claim_service.update_claim(claim_form)
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
        params.permit(:increment_claim, :clain_number, :reject_time, :accept_time, :status, :reviewer_comment, :is_finish, :page, :search,:user_id,:created_at ).to_h
    end

    # Using strong parameters
    def claim_form_params
        params.require(:claim).permit(:increment_claim, :clain_number, :reject_time, :accept_time, :status, :reviewer_comment, :is_finish)
        # params.require(:core_user).permit! # allow all
    end
end
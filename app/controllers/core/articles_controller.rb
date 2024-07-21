require_dependency 'markazuna/di_container'

class Core::ArticlesController < ApplicationController
    include Markazuna::INJECT['article_service']
    # before_action :authenticate_core_user!, except: :show

    # http://api.rubyonrails.org/classes/ActionController/ParamsWrapper.html
    wrap_parameters :article, include: [:id, :title, :content, :slug]

    def index
        articles, page_count = article_service.find_articles(params[:page])
        if (articles.size > 0)
            respond_to do |format|
                format.json { render :json => { results: articles, count: page_count }}
            end
        else
            render :json => { results: []}
        end
    end

    def delete
        status, page_count = article_service.delete_article(params[:id])
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
        article_form = Core::ArticleForm.new(article_form_params)
        if article_service.create_article(article_form)
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
        article = article_service.find_article(id)

        if article
            respond_to do |format|
                format.json { render :json => { status: "200", payload: article } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def update
        article_form = Core::ArticleForm.new(article_form_params)
        if article_service.update_article(article_form)
            respond_to do |format|
                format.json { render :json => { status: "200", message: "Success" } }
            end
        else
            respond_to do |format|
                format.json { render :json => { status: "404", message: "Failed" } }
            end
        end
    end

    def tinymce
        render layout: 'tinycme', template: 'core/tinymce'
    end

    private

    # Using strong parameters
    def article_form_params
        params.require(:article).permit(:id, :title, :content, :slug)
        # params.require(:core_user).permit! # allow all
    end
end
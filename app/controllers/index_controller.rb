require_dependency 'markazuna/di_container'

class IndexController < ActionController::Base
    include Markazuna::INJECT['article_service']
    layout 'index'

    def index
        render :index
    end

    def show 
        @article = article_service.find_article_by_slug(params[:slug])
        render layout: 'post', template: 'core/article'
    end
end

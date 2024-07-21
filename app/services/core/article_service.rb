class Core::ArticleService
    def create_article(article_form)
        article_form.save
    end

    def update_article(article_form)
        article_form.update
    end

    def delete_article(id)
        article = find_article(id)
        return article.delete, Core::Article.page(1).total_pages
    end

    def find_article(id)
        Core::Article.find(id)
    end

    def find_article_by_slug(slug)
        Core::Article.find_by(:slug => slug)
    end

    def find_articles(page = 0)
        return Core::Article.page(page), Core::Article.page(1).total_pages
    end
end

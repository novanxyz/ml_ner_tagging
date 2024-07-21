
class Core::ArticleForm
    include ActiveModel::Model

    attr_accessor(:id, :title, :content, :slug)

    # Validations
    validates :title, presence: true
    validates :content, presence: true
    validates :slug, presence: true
    
    def save
        if valid?
            article = Core::Article.new(title: self.title, content: self.content, slug: self.slug)
            article.save
            true
        else
            false
        end
    end

    def update
        if valid?
            article = Core::Article.find(self.id)
            article.update_attributes!(title: self.title, content: self.content, slug: self.slug)
            true
        else
            false
        end
    end
end

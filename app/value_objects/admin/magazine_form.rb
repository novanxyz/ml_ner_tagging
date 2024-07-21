
class Admin::MagazineForm
    include ActiveModel::Model

    attr_accessor(["title", "content", "picture", "pict_detail", "highlight", "is_deleted", "share_link", "target_tags", "post_id", "slug", "custom_slug", "score", "sponsored_tags", "id"])

    # Validations
    
    validates :title, presence: true 
    validates :content, presence: true 
    validates :picture, presence: true 
    validates :pict_detail, presence: true 
    validates :highlight, presence: true 
    validates :is_deleted, presence: true 
    validates :share_link, presence: true 
    validates :target_tags, presence: true 
    validates :post_id, presence: true 
    validates :slug, presence: true 
    validates :custom_slug, presence: true 
    validates :score, presence: true 
    validates :sponsored_tags, presence: true 

    def save
        if valid?
            magazine = Admin::Magazine.new(title: self:title, content: self:content, picture: self:picture, pict_detail: self:pict_detail, highlight: self:highlight, is_deleted: self:is_deleted, share_link: self:share_link, target_tags: self:target_tags, post_id: self:post_id, slug: self:slug, custom_slug: self:custom_slug, score: self:score, sponsored_tags: self:sponsored_tags, id: self:id)
            magazine.save
            true
        else
            false
        end
    end

    def update
        if valid?
            magazine = Admin::Magazine.find(self.id)
            magazine.update_attributes!(title: self:title, content: self:content, picture: self:picture, pict_detail: self:pict_detail, highlight: self:highlight, is_deleted: self:is_deleted, share_link: self:share_link, target_tags: self:target_tags, post_id: self:post_id, slug: self:slug, custom_slug: self:custom_slug, score: self:score, sponsored_tags: self:sponsored_tags, id: self:id)
            true
        else
            false
        end
    end
end

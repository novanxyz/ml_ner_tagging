class Core::Prepost
    include Mongoid::Document
    store_in collection: 'preposts'

    field :slug, type: String
    field :custom_slug, type: String

    belongs_to :postable, polymorphic: true


    def self.get_post(post_slug)
        self.or({slug: post_slug}, {custom_slug: post_slug}).first rescue nil
    end
end
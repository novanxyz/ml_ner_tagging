class Admin::Term
    include Mongoid::Document
    store_in collection: 'terms'

    field :name, type: String
    has_many :term_taxonomies, :class_name => 'Admin::TermTaxonomy'

    index({name: 1})

    def self.get_term
        self.all
    end
end

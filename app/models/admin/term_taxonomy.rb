class Admin::TermTaxonomy
    include Mongoid::Document
    store_in collection: 'term_taxonomies'

    field :taxonomy, type: String
    belongs_to :term, :class_name => 'Admin::Term', index: true
end

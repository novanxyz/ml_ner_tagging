class Admin::MagazineRelationship
    include Mongoid::Document
    store_in collection: 'magazine_relationships'

    embedded_in :magazine, class_name: 'Admin::Magazine'
    belongs_to :term_taxonomy, :class_name => 'Admin::TermTaxonomy', index: true
end

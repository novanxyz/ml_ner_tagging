class Admin::MagazinePopularity
    include Mongoid::Document
    include Mongoid::Timestamps
    include Markazuna::CommonModel
    store_in collection: 'magazine_popularities'

    field :total_view, type: Integer, default: 0

    belongs_to :magazine, :class_name => 'Admin::Magazine', index: true

    validates_presence_of :total_view
end
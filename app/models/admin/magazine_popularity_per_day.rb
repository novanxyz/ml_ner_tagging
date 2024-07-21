class Admin::MagazinePopularityPerDay
    include Mongoid::Document
    include Mongoid::Timestamps
    include MoslemCorner::CommonModel
    store_in collection: 'magazine_popularity_per_days'

    field :counter_date, type: Date, default: Date.today
    field :total_view, type: Integer, default: 0

    belongs_to :magazine, :class_name => 'Admin::Magazine', index: true

    validates_presence_of :counter_date
    validates_presence_of :total_view
end
class Core::Directory
    include Mongoid::Document
    include Mongoid::Timestamps
    store_in collection: 'directories'

    field :is_deleted, type: Boolean, default: false

    belongs_to :directory_category, :class_name => 'Core::DirectoryCategory', index: true
    belongs_to :user, :class_name => 'Core::User', index: true
    validates_presence_of :directory_category

    index({is_deleted: 1})
end

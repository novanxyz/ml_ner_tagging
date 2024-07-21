class Core::MetaDescriptionValue
    include Mongoid::Document
    store_in collection: 'meta_descriptions_values'

    field :value, type: String
    field :is_open_text, type: Boolean, default: false
    field :is_deleted, type: Boolean, default: false
    field :sequence, type: Integer
    belongs_to :meta_description, :class_name => 'Core::MetaDescription', index: true

    after_save :delete_cache_init_data
    after_update :delete_cache_init_data

    index({is_deleted: 1})

    private

    def delete_cache_init_data
        AloCache.delete_by_namespace('get_init_data_')
    end
end

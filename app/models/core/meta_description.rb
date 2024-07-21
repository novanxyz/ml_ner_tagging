class Core::MetaDescription
    include Mongoid::Document
    include Mongoid::Timestamps
    include Markazuna::CommonModel
    store_in collection: 'meta_descriptions'

    field :question, type: String
    field :is_deleted, type: Boolean, default: false
    field :sequence, type: Integer

    validates_presence_of :question
    validates_presence_of :sequence
    validate :validate_choice_count, :on => :create
    validates_uniqueness_of :sequence
    validates_numericality_of :sequence

    after_save :delete_cache_init_data
    after_update :delete_cache_init_data

    index({sequence: 1, is_deleted: 1})

    has_many :meta_description_values, :order => 'sequence ASC', :class_name => 'Core::MetaDescriptionValue' #, dependent: :destroy
    accepts_nested_attributes_for :meta_description_values, :allow_destroy => true

    private
    def validate_choice_count
        choice_count = 0
        meta_description_values.each { |choice|
            choice_count += 1 if choice.value.empty?
        }
        if choice_count > 1
            errors.add(:meta_description_values, 'Need 2 or more choices')
        end
    end

    # def self.list_preference
    #     where(is_deleted: false).order_by(:sequence => 'asc')
    # end

    def self.get_meta_description_with_page(page)
        self.where(is_deleted: false).order_by(:sequence => 'asc').page(page).per(DEFAULT_PAGE_SIZE)
    end

    # methods define by Kiagus Arief Adriansyah
    def self.get_all_sort_by_sequence
        self.where(is_deleted: false).order_by(:sequence => 'asc')
    end

    def self.get_specific_sequence(sequences)
        self.where(sequence: { '$in': sequences  }).order_by(:sequence => 'asc')
    end

    private

    def delete_cache_init_data
        AloCache.delete_by_namespace('get_init_data_')
    end
end

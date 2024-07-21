require 'elasticsearch/model'
require 'markazuna/common_model'

class Admin::Magazine    
    include Mongoid::Document
    include Mongoid::Timestamps
    include Markazuna::CommonModel
    include Elasticsearch::Model
    

    store_in collection: 'magazines'

    # kaminari page setting
    paginates_per 20
	
    field :title, type: String, default: ''	
    field :content, type: String, default: ''	
    field :picture, type: String, default: ''	
    field :pict_detail, type: String, default: ''	
    field :highlight, type: Boolean, default: ''	
    field :is_deleted, type: Boolean, default: ''	
    field :share_link, type: String, default: ''	
    field :target_tags, type: Array, default: []	
    field :post_id, type: String, default: ''	
    field :slug, type: String, default: ''	
    field :custom_slug, type: String, default: ''	
    field :score, type: Float, default: ''	
    field :sponsored_tags, type: Array, default: []

    belongs_to :user, :class_name => 'Core::User', index: true # TODO please review this relationship
    embeds_many :magazine_relationships, :class_name => 'Admin::MagazineRelationship'
    has_one :prepost, :class_name => 'Admin::Prepost', as: :postable

    validates_presence_of :title
    validates_presence_of :content
    validates_presence_of :picture

    after_save :delete_cache
    after_update :delete_cache
    after_save :delete_cache_list
    after_update :delete_cache_list
    before_save :create_if_blank
    after_save :pub_event

    index({is_deleted: 1, title: 1})
    index({is_deleted: 1, highlight: -1, created_at: -1})
    index({updated_at: -1})

    # indexing text for query search $text https://docs.mongodb.com/manual/core/index-text/
    index({title: 'text', content: 'text'})

    index_name "alomobile"

    after_create do
        begin
            __elasticsearch__.index_document
        rescue Exception => e
            Rails.logger.info "^^^^^^^^ CREATE ELASTICSEARCH PROBLEM #{e} ^^^^^^^^^"
            ReindexJob.set(wait: (AloCache.get('reindex_delay_time') || "60").to_i.seconds).perform_later(self.class.name, 'index', self.id.to_s)
        end
    end

    after_update do
        begin
            __elasticsearch__.update_document
        rescue Exception => e
            if e.class.to_s =~ /NotFound/
                Rails.logger.info "^^^^^^^^  UPDATE ELASTICSEARCH PROBLEM INDEX NOT FOUND ^^^^^^^^^"
                __elasticsearch__.index_document
            else
                Rails.logger.info "^^^^^^^^  UPDATE ELASTICSEARCH PROBLEM #{e} ^^^^^^^^^"
                ReindexJob.set(wait: (AloCache.get('reindex_delay_time') || "60").to_i.seconds).perform_later(self.class.name, 'update', self.id.to_s)
            end
        end
    end

    after_destroy do
        begin
            __elasticsearch__.delete_document
        rescue Exception => e
            Rails.logger.info "^^^^^^^^ DELETE ELASTICSEARCH PROBLEM #{e} ^^^^^^^^^"
            ReindexJob.set(wait: (AloCache.get('reindex_delay_time') || "60").to_i.seconds).perform_later(self.class.name, 'delete', self.id.to_s)
        end
    end

    settings index: { number_of_shards: 1 } do
        mappings dynamic: 'false' do
            indexes :title, type: 'string', analyzer: 'indonesian', index_options: 'offsets'
            indexes :content, type: 'string', analyzer: 'indonesian', index_options: 'offsets'
            indexes :pict_detail do
                indexes :public_id, type: 'string', index: 'not_analyzed'
                indexes :version, type: 'integer', index: 'not_analyzed'
                indexes :signature, type: 'string', index: 'not_analyzed'
                indexes :width, type: 'integer', index: 'not_analyzed'
                indexes :height, type: 'integer', index: 'not_analyzed'
                indexes :format, type: 'string', index: 'not_analyzed'
                indexes :resource_type, type: 'string', index: 'not_analyzed'
                indexes :created_at, type: 'string', index: 'not_analyzed'
                indexes :tags, type: 'string', index: 'not_analyzed'
                indexes :bytes, type: 'integer', index: 'not_analyzed'
                indexes :type, type: 'string', index: 'not_analyzed'
                indexes :etag, type: 'string', index: 'not_analyzed'
                indexes :url, type: 'string', index: 'not_analyzed'
                indexes :secure_url, type: 'string', index: 'not_analyzed'
                indexes :original_filename, type: 'string', index: 'not_analyzed'
            end
            indexes :highlight, type: 'boolean', index: 'not_analyzed'
            indexes :is_deleted, type: 'boolean', index: 'not_analyzed'
            indexes :share_link, type: 'string', index: 'not_analyzed'
            indexes :target_tags, type: 'string', index: 'not_analyzed'
            indexes :slug, type: 'string', index: 'not_analyzed'
            indexes :custom_slug, type: 'string', index: 'not_analyzed'
        end
    end

    # elasticsearch imported field
    def as_indexed_json(options={})
        self.as_json({only: [:title, :content, :pict_detail, :highlight, :is_deleted, :share_link, :target_tags, :slug, :custom_slug]})
    end

    def self.get_highlight
        self.where(is_deleted: false, highlight: true).order_by(:created_at => 'desc').hint(is_deleted: 1, highlight: -1, created_at: -1).first
    end

    def self.get_magazines(page, page_size = DEFAULT_PAGE_SIZE)
        self.where(is_deleted: false).any_of({:highlight => false}, {:highlight => nil}).order_by(:created_at => 'desc').hint(is_deleted: 1, highlight: -1, created_at: -1).page(page).per(page_size)
    end

    def self.get_shuffle_magazines(page, page_size = DEFAULT_PAGE_SIZE)
        date1 = Time.parse('2014-06-30')
        magazine_count = self.where(is_deleted: false, :created_at.gte=> date1.strftime('%Y-%m-%d')).any_of({:highlight => false}, {:highlight => nil}).hint(is_deleted: 1, highlight: -1, created_at: -1).count
        total_page = magazine_count / 5
        random_page = (1..total_page).to_a.sample
        self.where(is_deleted: false, :created_at.gte=> date1.strftime('%Y-%m-%d')).any_of({:highlight => false}, {:highlight => nil}).order_by(:created_at => ['asc', 'desc'].to_a.sample).hint(is_deleted: 1, highlight: -1, created_at: -1).page(random_page).per(5)
    end

    def self.get_shuffle_magazine_by_interests(interests)
        term_interests = Core::TermInterest.where(:interest.in=> interests.collect{|x|x.id})
        term_taxonomies = Core::TermTaxonomy.where(taxonomy: "magazine_tag", :term.in=> term_interests.collect{|x|x.term.id if !x.term.nil?}.flatten.compact)
        date1 = Time.parse('2014-06-30')
        magazine_count = self.any_in(is_deleted: false, 'magazine_relationships.term_taxonomy_id'=>term_taxonomies.collect{|x|x.id}).and(:created_at.gte=> date1).any_of({:highlight => false}, {:highlight => nil}).count
        total_page = magazine_count / 5
        random_page = (1..total_page).to_a.sample
        self.any_in(is_deleted: false, 'magazine_relationships.term_taxonomy_id'=>term_taxonomies.collect{|x|x.id}).and(:created_at.gte=> date1).any_of({:highlight => false}, {:highlight => nil}).order_by(created_at: ['asc', 'desc'].sample).page(random_page).per(5)
    end

    def self.get_magazines_by_timestamp(timestamp)
        self.where(is_deleted: false, created_at: {:$gte => timestamp}).any_of({:highlight => false}, {:highlight => nil}).order_by(:created_at => 'desc')
    end

    

    def self.search_magazines(word, page)
        # self.where(is_deleted: false, title: /.*#{CGI.unescape(word)}.*/i).order_by(:title => 'asc').page(page).per(DEFAULT_PAGE_SIZE)
        #!word.nil? ? self.where({ :$text => { :$search => CGI.unescape(word)}, is_deleted: false }).order_by(:title => 'asc').page(page).per(DEFAULT_PAGE_SIZE) : []
        # Search of Magazine is more accurate using score by keyword (word, url etc)
        !word.nil? ? Kaminari.paginate_array(self.collection.find({ :$text => { :$search => CGI.unescape(word) }}).projection(score: { :$meta => "textScore"} ).sort({score: { :$meta => "textScore" }}).entries.map{ |g| self.new(g) }).page(page).per(DEFAULT_PAGE_SIZE) : []
    end

    def self.count_magazine
        self.where(is_deleted: false).count
    end

    def self.count_magazine_new
        self.__elasticsearch__.search({ "query": { "term": { "is_deleted": false } } }).results.total
    end

    def self.get_magazines_with_page(page, per_page)
        self.where(is_deleted: false).order_by(:updated_at => 'desc').hint(updated_at: -1).page(page).per(per_page)
    end

    def self.general_search(word, limit)
        self.where({ :$text => { :$search => CGI.unescape(word)}, is_deleted: false }).limit(limit)
    end

    def self.get_by_slug(slug)
        self.or({slug: slug}, {custom_slug: slug}).first rescue nil
    end

    def self.article_deep_link
        all.collect {|x| {"#{x.title}"=>  [x.title, x.pict_detail["url"], Nokogiri::HTML(x.content).text[0..149] + "...", x.slug, '']} }
    end


    ## method for v1.3.0

    def self.get_shuffle_magazine_by_interests_new(interests, page_size = 10)
        interest_ids = interests.map{|x| x.id }
        term_ids = Core::TermInterest.where(interest_id: { '$in': interest_ids }).map{|x| x.term_id }
        term_taxonomie_ids = Core::TermTaxonomy.where(taxonomy: "magazine_tag", term_id: { '$in': term_ids }).map{|x| x.id }
        date1 = Time.parse('2014-06-30')
        magazine_count = self.any_in(is_deleted: false, 'magazine_relationships.term_taxonomy_id'=>term_taxonomie_ids).and(:created_at.gte=> date1).any_of({:highlight => false}, {:highlight => nil}).count
        total_page = magazine_count / page_size
        random_page = (1..total_page).to_a.sample
        self.any_in(is_deleted: false, 'magazine_relationships.term_taxonomy_id'=>term_taxonomie_ids).and(:created_at.gte=> date1).any_of({:highlight => false}, {:highlight => nil}).order_by(created_at: ['asc', 'desc'].sample).page(random_page).per(page_size)
    end

    def self.get_shuffle_magazines_new(page, page_size = DEFAULT_PAGE_SIZE)
        date1 = Time.parse('2014-06-30')
        magazine_count = self.where(is_deleted: false, :created_at.gte=> date1.strftime('%Y-%m-%d')).any_of({:highlight => false}, {:highlight => nil}).hint(is_deleted: 1, highlight: -1, created_at: -1).count
        total_page = magazine_count / page_size
        random_page = (1..total_page).to_a.sample
        self.where(is_deleted: false, :created_at.gte=> date1.strftime('%Y-%m-%d')).any_of({:highlight => false}, {:highlight => nil}).order_by(:created_at => ['asc', 'desc'].to_a.sample).hint(is_deleted: 1, highlight: -1, created_at: -1).page(random_page).per(page_size)
    end

    def increment_total_view
        magazine_popularity = Core::MagazinePopularity.find_by(magazine_id: self.id)
        if magazine_popularity.nil?
            magazine_popularity = Core::MagazinePopularity.new(magazine_id: self.id)
        end

        magazine_popularity.total_view = magazine_popularity.total_view + 1

        if magazine_popularity.save
            magazine_popularity_per_day = Core::MagazinePopularityPerDay.find_by(counter_date: Date.today, magazine_id: self.id)
            if magazine_popularity_per_day.nil?
                magazine_popularity_per_day = Core::MagazinePopularityPerDay.new(counter_date: Date.today, magazine_id: self.id, total_view: 0)
            end

            magazine_popularity_per_day.total_view = magazine_popularity_per_day.total_view + 1
            magazine_popularity_per_day.save
        end
    end

    def get_term_taxonomies
        term_taxonomy_ids = []
        if magazine_relationships.count > 0
            magazine_relationships.each do |magazine_relationship|
                term = magazine_relationship.term_taxonomy.term rescue nil
                if !term.nil?
                    term_taxonomy_ids << term.term_taxonomies.collect {|x|x.id}
                end
            end
        end

        term_taxonomy_ids
    end

    # def self.get_related_magazines(object, day, term_taxonomy_ids)
    #     if object.class == Core::Magazine
    #         related_magazines = where(is_deleted: false, :created_at.gte=>Time.now.beginning_of_day.utc - day, :created_at.lte=>Time.now.end_of_day.utc).not_in(id: object.id).in("magazine_relationships.term_taxonomy_id"=>term_taxonomy_ids).limit(5)
    #     else
    #         related_magazines = where(is_deleted: false, :created_at.gte=>Time.now.beginning_of_day.utc - day, :created_at.lte=>Time.now.end_of_day.utc).in("magazine_relationships.term_taxonomy_id"=>term_taxonomy_ids).limit(5)
    #     end
    #
    #     related_magazines
    # end

    # def self.get_related_magazines_based_popularity(object, related_magazines, term_taxonomy_ids)
    #     total_add_popularity = 5 - related_magazines.count
    #     if object.class == Core::Magazine
    #         tag_popularities = where(is_deleted: false).in("magazine_relationships.term_taxonomy_id"=>term_taxonomy_ids).not_in(id: object.id).order_by(created_at: 'desc').limit(total_add_popularity)
    #     else
    #         tag_popularities = where(is_deleted: false).in("magazine_relationships.term_taxonomy_id"=>term_taxonomy_ids).order_by(created_at: 'desc').limit(total_add_popularity)
    #     end
    #
    #     related_magazines = (related_magazines + tag_popularities).flatten.compact.uniq
    #
    #     if related_magazines.count < 5
    #         total_add_popularity = 5 - related_magazines.count
    #         per_day_popularities = Core::MagazinePopularityPerDay.all.order_by(total_view: 'desc').limit(total_add_popularity)
    #         new_magazines = where(:id.in=> per_day_popularities.collect{|x|x.magazine_id})
    #         related_magazines = (related_magazines + new_magazines).flatten.compact.uniq
    #     end
    #
    #     related_magazines
    # end

    def self.get_related_magazines(term_taxonomy_ids, object, number_of_day, related_magazines)
        if object.class == Core::Magazine
            magazine_ids = related_magazines.collect {|x|x.id}
            magazine_ids << object.id
            if number_of_day == 0
                related_magazines = where(is_deleted: false).not_in(id: magazine_ids).in("magazine_relationships.term_taxonomy_id"=>term_taxonomy_ids).order_by(created_at: 'desc').limit(5 - related_magazines.count)
            else
                related_magazines = where(is_deleted: false, :created_at.gte=>(Time.now - number_of_day.day).beginning_of_day.utc, :created_at.lte=>Time.now.end_of_day.utc).not_in(id: magazine_ids).in("magazine_relationships.term_taxonomy_id"=>term_taxonomy_ids).order_by(created_at: 'desc').limit(5 - related_magazines.count)
            end
        else
            if number_of_day == 0
                related_magazines = where(is_deleted: false).in("magazine_relationships.term_taxonomy_id"=>term_taxonomy_ids).order_by(created_at: 'desc').limit(5 - related_magazines.count)
            else
                related_magazines = where(is_deleted: false, :created_at.gte=>(Time.now - number_of_day.day).beginning_of_day.utc, :created_at.lte=>Time.now.end_of_day.utc).in("magazine_relationships.term_taxonomy_id"=>term_taxonomy_ids).order_by(created_at: 'desc').limit(5 - related_magazines.count)
            end
        end

        related_magazines
    end

    def self.get_popularity_magazines(number_of_day, magazine_ids, object, related_magazines)
        if object.class == Core::Magazine
            magazine_ids = related_magazines.collect {|x|x.id}
            magazine_ids << object.id
            popular_magazines = Core::MagazinePopularityPerDay.where(:magazine_id.in=> magazine_ids, :created_at.gte=> (Time.now - number_of_day.day).beginning_of_day.utc, :created_at.lte=> Time.now.end_of_day.utc ).not_in(magazine_id: magazine_ids).order_by(total_view: 'desc').limit(5)
        else
            popular_magazines = Core::MagazinePopularityPerDay.where(:magazine_id.in=> magazine_ids, :created_at.gte=> (Time.now - number_of_day.day).beginning_of_day.utc, :created_at.lte=> Time.now.end_of_day.utc ).not_in(magazine_id: magazine_ids).order_by(total_view: 'desc').limit(5)
        end

        related_magazines = where(:id.in=> popular_magazines.collect{|x|x.magazine_id})

        related_magazines
    end

    def self.get_newest_magazines(related_magazines, object)
        if object.class == Core::Magazine
            magazine_ids = related_magazines.collect {|x|x.id}
            magazine_ids << object.id
            related_magazines = where(is_deleted: false).not_in(id: magazine_ids).order_by(created_at: 'desc').limit(5 - related_magazines.count)
        else
            related_magazines = where(is_deleted: false).order_by(created_at: 'desc').limit(5 - related_magazines.count)
        end

        related_magazines
    end

    def self.get_related_article(term_taxonomy_ids, magazine)
        term_taxonomy_ids = term_taxonomy_ids.flatten.compact
        related_magazines = get_related_magazines(term_taxonomy_ids, magazine, 7, [])

        if related_magazines.count < 5
            all_related_magazines = get_related_magazines(term_taxonomy_ids, magazine, 0, [])
            related_magazines = get_popularity_magazines(14, all_related_magazines.collect{|x|x.id}, magazine, related_magazines)
            if related_magazines.count < 5
                additional_magazines = get_related_magazines(term_taxonomy_ids, magazine, 0, related_magazines)

                related_magazines = related_magazines + additional_magazines
                if related_magazines.count < 5
                    newest_magazines = get_newest_magazines(related_magazines, magazine)
                    related_magazines = related_magazines + newest_magazines
                end
            end
        end

        related_magazine_json = render_related_magazine(related_magazines)

        related_magazine_json

        # term_taxonomy_ids = term_taxonomy_ids.flatten.compact
        # related_magazines = get_related_magazines(magazine, 7.day, term_taxonomy_ids)
        #
        # if related_magazines.count < 5
        #     related_magazines = get_related_magazines(magazine, 14.day, term_taxonomy_ids)
        # end
        #
        # if related_magazines.count < 5
        #     related_magazines = get_related_magazines_based_popularity(magazine, related_magazines, term_taxonomy_ids)
        # end
        #
        # related_magazine_json = render_related_magazine(related_magazines)
        #
        # related_magazine_json
    end

    def self.render_related_magazine(related_magazines)
        related_magazine_json = []
        related_magazines.each do |related_magazine|
            pict_detail = related_magazine['pict_detail']['url'] rescue ''
            short_content = ActionController::Base.helpers.excerpt(ActionController::Base.helpers.strip_tags(related_magazine['content']), ' ')
            target_tags = []

            related_magazine['target_tags'].each do |target_tag|
                target_tags << {'value'=>target_tag}
            end

            content = related_magazine.content rescue ''
            related_magazine_json << {
                'id' => related_magazine['id'].to_s,
                'title' => related_magazine['title'],
                'highlight' => related_magazine['highlight'],
                'slug' => related_magazine['slug'],
                'short_content' => short_content,
                'img_url' => pict_detail,
                'share_link' => related_magazine['share_link'],
                'target_tags' => target_tags,
                'content' => content
            }
        end

        related_magazine_json
    end

    def self.get_by_autocomplete(params)
        self.where(is_deleted: false, title: /.*#{params[:title]}.*/i).page(params[:page]).per(10).map{|x| {value: x.id.to_s, label: x.title.to_s, content: (Nokogiri::HTML::Document.parse(x.content).text.strip.truncate(200) rescue ""), image: (x.pict_detail[:url] rescue "") } }
    end

    private
    def delete_cache
        # ['v1', 'v120', 'v130', 'v131', 'v140', 'v150'].each do |version|
        #    cache_id = Rails.root.join('public', 'page_cache', 'api', version, 'magazines', 'get_detail', "#{self.id}.json")
        #    cache_slug = Rails.root.join('public', 'page_cache', 'api', version, 'magazines', 'get_detail', "#{self.slug}.json")
        #    cache_post = Rails.root.join('public', 'page_cache', 'api', version, 'posts', 'get_post', "#{self.slug}.json")
        #    File.delete(cache_id) if File.exist?(cache_id)
        #    File.delete(cache_slug) if File.exist?(cache_slug)
        #    File.delete(cache_post) if File.exist?(cache_post)
        # end
        [self.id, self.slug].each do |slug|
            data = {slug: slug}
            AloPubsub.new.delete_cache('delete-cache', data)
        end
    end

    def delete_cache_list
        AloCache.delete_by_namespace('get_magazines_index_')
        AloCache.delete_by_namespace('get_magazines_get_by_user_')
        AloCache.delete_by_namespace('get_infos_')
    end

    def create_if_blank
        if self.slug.blank?
            slug = (Core::Magazine.or({slug: self.title.parameterize, custom_slug: self.title.parameterize}).present? ? "#{self.title.parameterize}-#{SecureRandom.random_number(100)}" : "#{self.title.parameterize}")
            self.slug = slug
        end
        if self.post_id.blank?
            self.post_id = SecureRandom.random_number(9999999)
        end
    end

    def pub_event
        unless self.changes.blank?
            if self.changes["updated_at"][0].present?
                Rails.logger.info "{{{{{{{{ UPDATE ARTICLE }}}}}}}}}"
                event_name = 'update_article'
            else
                Rails.logger.info "{{{{{{{{ NEW ARTICLE }}}}}}}}}"
                event_name = 'new_article'
            end
            data_event = {
              "object_id": self.id.to_s,
              "post_id": self.post_id,
              "post_slug": self.slug,
              "post_title": self.title,
              "post_content": self.content,
              "post_status": self.is_deleted == false ? 'publish' : 'unpublish',
              "post_date": self.created_at.to_i.to_s,
              "post_image_url": self.pict_detail["url"]
            }
            EventArticleJob.perform_later(event_name, data_event)
        end
    end
end

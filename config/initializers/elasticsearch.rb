require 'typhoeus'
require 'typhoeus/adapters/faraday'
require 'elasticsearch/model'


# transport_configuration = lambda do |f|
#     f.response :logger
#     f.adapter  :typhoeus
# end

# proxy_options = {uri: ''}
# default_transport_options = {proxy: proxy_options}
default_host = { scheme: ENV['ELASTICSEARCH_SCHEME'], host: ENV['ELASTICSEARCH_HOST'], port: ENV['ELASTICSEARCH_PORT'] }

config = {
    hosts: default_host,
    # transport_options: default_transport_options,
    adapter: :typhoeus
}
Elasticsearch::Model.client = Elasticsearch::Client.new(config)
#Searchkick.client = Elasticsearch::Client.new(hosts: default_host, retry_on_failure: true, transport_options: {request: {timeout: 250}})

#Elasticsearch::Model.client = Elasticsearch::Client.new url: ENV['ELASTICSEARCH_URL'] || "http://localhost:9200/"
begin
unless Admin::Magazine.__elasticsearch__.index_exists?
    Admin::Magazine.__elasticsearch__.create_index! force: true
    Admin::Magazine.import
end

unless Core::DirectoryText.__elasticsearch__.index_exists?
    Core::DirectoryText.__elasticsearch__.create_index! force: true
    Core::DirectoryText.import
end

unless Core::Question.__elasticsearch__.index_exists?
    Core::Question.__elasticsearch__.create_index! force: true
    Core::Question.import
end
rescue
end


require 'status_page/version'
require 'json'
require 'status_page/redis_connection'

module StatusPage

  DEFAULT_METRICS_SET = { 'general' => { 'os' => true, 'cpu' => true, 'ram' => true, 'file_system' => true }}

  # Configuration for StatusPage, use like:
  #
  #   StatusPage.configure do |config|
  #     config.redis = { :namespace => 'myapp', :size => 25, :url => 'redis://myhost:8877/0' }
  #     config.metrics_set = YAML.load(File.read(File.expand_path('../../status_page.yml.example',  __FILE__)))
  #   end
  #
  def self.configure
    yield self
  end

  def self.redis(&block)
    raise ArgumentError, "requires a block" unless block
    redis_pool.with(&block)
  end

  def self.redis_pool
    @redis ||= StatusPage::RedisConnection.create
  end

  def self.redis=(hash)
    @redis = if hash.is_a?(ConnectionPool)
      hash
    else
      StatusPage::RedisConnection.create(hash)
    end
  end

  def self.metrics_set
    @metrics_set || DEFAULT_METRICS_SET
  end

  def self.metrics_set=(hash)
    @metrics_set = hash
  end
end

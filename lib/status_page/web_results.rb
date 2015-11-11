require 'ostruct'
require 'json'

module StatusPage
  class WebResults
    class Value
      attr_reader :key, :value, :time

      def initialize(key, value, time)
        @key, @value, @time = key, value, time
      end

      def status
        return 'wrong' if value.to_s =~ /not\s+installed$/
        'correct'
      end
    end

    def metrics_keys
      StatusPage.redis do |conn|
        conn.keys.select { |k| k =~ /^ruby|jruby/ }
      end
    end

    def platforms
      @platforms ||= metrics_keys.map { |k| k.scan(/^(\w+)\//) }.flatten.uniq
    end

    def summary
      results = {}

      StatusPage.metrics_set.each do |group, metrics|
        results[group] = []

        metrics.each do |key, _|
          ruby_record = StatusPage.redis { |conn| conn.lrange("ruby/#{group}/#{key}", -2, -1).first }
          jruby_record = StatusPage.redis { |conn| conn.lrange("jruby/#{group}/#{key}", -2, -1).first }

          values = [ prepare_value(:ruby, ruby_record), prepare_value(:jruby, jruby_record) ].compact
          results[group] << OpenStruct.new(key: key, platforms: values)
        end
      end

      results
    end

    def history(key)
      results = []
      size_of_set = StatusPage.redis { |conn| conn.llen(key) }

      StatusPage.redis { |conn| conn.lrange(key, (size_of_set - 50), -1) }.reverse.each do |record|
        results << prepare_value(key, record)
      end
      results
    end

    private

    def prepare_value(key, json)
      return unless json
      record = JSON.parse(json)
      Value.new(key, record['value'], Time.parse(record['time']).to_s)
    end
  end
end
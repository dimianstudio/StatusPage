require 'yaml'
require 'active_support/inflector'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/keys'

Dir["#{File.expand_path('../',  __FILE__)}/**/*.rb"].each { |f| require f }

module StatusPage
  class Client
    def collect
      StatusPage.metrics_set.each do |group, metrics|
        send("__visit_#{group}", metrics) if respond_to?("__visit_#{group}", true)
      end
    end

    def platform
      if defined?(RUBY_ENGINE) && RUBY_ENGINE == 'jruby'
        :jruby
      else
        :ruby
      end
    end

    private

    def metric_defined?(constant_name)
      constant_name.constantize rescue nil
      Object.const_defined?(constant_name)
    end

    def __visit_general(metrics)
      metrics.each do |metric, value|
        next unless value

        metric_class = "StatusPage::Metric::General::#{metric.classify}"
        next unless metric_defined?(metric_class)

        save_metric("general/#{metric}", metric_class.constantize.new.result)
      end
    end

    def __visit_software(metrics)
      metrics.each do |metric, value|
        next unless value

        metric_class = "StatusPage::Metric::Software"

        options = case value
          when TrueClass then { name: metric, command: "#{metric} --version" }
          when String then { name: metric, command: value }
          when Hash
            metric_class = value.delete('metric_class') if value['metric_class'].present?
            { name: metric }.merge(value.symbolize_keys)
        end

        next unless metric_defined?(metric_class)

        save_metric("software/#{metric}", metric_class.constantize.new(options).result)
      end
    end

    def __visit_processes(metrics)
    end

    def __visit_checks(metrics)
      metrics.each do |metric, value|
        next unless value
        next unless metric_defined?(value['metric_class'])

        save_metric("checks/#{metric}", value['metric_class'].constantize.new.result)
      end
    end

    def save_metric(name, value)
      StatusPage.redis do |conn|
        conn.lpush("#{platform}/#{name}", JSON.dump(value: value, time: Time.now.utc))
      end
    end
  end
end
require 'yaml'
require 'active_support/inflector'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/hash/keys'

require 'status_page/metric/general/cpu'
require 'status_page/metric/general/file_system'
require 'status_page/metric/general/operation_system'
require 'status_page/metric/general/ram'
require 'status_page/metric/process'
require 'status_page/metric/software'

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
      constant_name.constantize
      true
    rescue
      false
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
      __visit_type('software', metrics) { |name| "#{name} --version" }
    end

    def __visit_process(metrics)
      __visit_type('process', metrics) do |name|
        "ps aux | grep \"[#{name.to_s[0]}]#{name.to_s[1..-1]}\""
      end
    end

    def __visit_type(type, metrics, &block)
      metrics.each do |metric, value|
        next unless value

        metric_class = "StatusPage::Metric::#{type.humanize}"

        options = case value
          when TrueClass
            { name: metric, command: block.call(metric) }
          when String
            { name: metric, command: value }
          when Hash
            opts = value.clone
            metric_class = opts.delete('metric_class') if opts['metric_class'].present?
            opts['command'] = block.call(opts.delete('process')) if opts['process'].present?
            { name: metric }.merge(opts.symbolize_keys)
        end

        next unless metric_defined?(metric_class)

        save_metric("#{type}/#{metric}", metric_class.constantize.new(options).result)
      end
    end

    def __visit_checks(metrics)
      metrics.each do |metric, value|
        next unless value
        next unless metric_defined?(value['metric_class'])

        save_metric("checks/#{metric}", value['metric_class'].constantize.new.result)
      end
    end

    def save_metric(name, value)
      hash = value.is_a?(Hash) ? value : { value: value }

      StatusPage.redis do |conn|
        conn.lpush("#{platform}/#{name}", JSON.dump(hash.merge(time: Time.now.utc)))
        conn.ltrim("#{platform}/#{name}", 0, StatusPage.history_size)
      end
    end
  end
end

module StatusPage
  module Metric
    class Process < Base
      def initialize(options)
        @options = options
      end

      def name
        @options[:name]
      end

      def command
        @options[:command]
      end

      def result
        executable = command.scan(/(.*?)\s+/).flatten.first
        check_command = `which #{executable}`

        if check_command =~ /not found/ || check_command.empty?
          "#{name} not installed"
        else
          `#{command}`.strip
        end
      end
    end
  end
end
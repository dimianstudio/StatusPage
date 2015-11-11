module StatusPage
  module Metric
    class Base
      def result
        send(:"result_for_#{host_os}")
      end

      def result_for_mac
        raise NotImplementedError, '#result_for_mac is not implemented'
      end

      def result_for_linux
        raise NotImplementedError, '#result_for_linux is not implemented'
      end

      def result_for_custom
      end

      def host_os
        case RbConfig::CONFIG['host_os']
        when /mac|darwin/ then :mac
        when /linux|cygwin/ then :linux
        else
          :custom
        end
      end
    end
  end
end
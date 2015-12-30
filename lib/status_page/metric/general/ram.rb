require 'status_page/metric/base'

module StatusPage
  module Metric
    module General
      class Ram < StatusPage::Metric::Base
        def result_for_mac
          (`sysctl -n hw.memsize`.to_i / 1024).to_s
        end

        def result_for_linux
          `cat /proc/meminfo | grep MemTotal`.gsub(/MemTotal\:/, '').strip
        end
      end
    end
  end
end
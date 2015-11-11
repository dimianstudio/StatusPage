module StatusPage
  module Metric
    module General
      class Cpu < StatusPage::Metric::Base
        def result_for_mac
          `sysctl -n machdep.cpu.brand_string`
        end

        def result_for_linux
          `lscpu`
        end
      end
    end
  end
end
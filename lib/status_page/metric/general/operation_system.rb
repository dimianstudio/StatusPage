module StatusPage
  module Metric
    module General
      class OperationSystem < StatusPage::Metric::Base
        def result_for_mac
          `sw_vers`
        end

        def result_for_linux
          `lsb_release -a`
        end
      end
    end
  end
end
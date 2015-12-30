require 'status_page/metric/base'

module StatusPage
  module Metric
    module General
      class FileSystem < StatusPage::Metric::Base
        def result_for_mac
          `df`
        end

        def result_for_linux
          `df -lh`
        end
      end
    end
  end
end
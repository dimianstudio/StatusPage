require 'status_page/metric/software'

module StatusPage
  module Metric
    class Process < Software
      def result
        result = `#{command}`

        if result.split("\n").empty?
          { value: "#{name} is not running", status: 'error' }
        else
          { value: "running", raw_data: result }
        end
      end
    end
  end
end

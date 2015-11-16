require File.expand_path('../software',  __FILE__)

module StatusPage
  module Metric
    class Process < Software
      def result
        result = `#{command}`

        if result.split("\n").empty?
          "#{name} is not running"
        else
          { value: "running", raw_data: result }
        end
      end
    end
  end
end
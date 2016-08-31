module Bidu
  module House
    class Report
      class Database < Report
        def error?
          @error ||= ! can_connect?
        end

        private

        def can_connect?
          return false unless connection
          require "active_record_ext/#{connection.adapter_name.underscore}"
          connection.connection_ok?
        end

        def connection
          ::ActiveRecord::Base.connection
        rescue StandardError
          nil
        end
      end
    end
  end
end


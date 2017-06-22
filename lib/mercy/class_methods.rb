module Bidu
  module Mercy
    module ClassMethods

      def status_report(*attr_names)
        id = attr_names.first
        options = {
          id: id
        }.merge(attr_names.extract_options!)

        self.status_builder.add_report_config(id, options)
      end

      def status_builder
        @status_builder ||= Mercy::StatusBuilder.new
      end
    end
  end
end

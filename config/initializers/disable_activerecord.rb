if Rails.env.production?
  Rails.application.config.middleware.delete(ActiveRecord::Migration::CheckPending)
  
  # Skip AR connection
  ActiveRecord::Base.establish_connection :nulldb if defined?(ActiveRecord::Base)
  
  # Mock AR methods
  module ActiveRecord
    class Base
      def self.has_many(*args); end
      def self.has_one(*args); end
      def self.belongs_to(*args); end
      def self.has_and_belongs_to_many(*args); end
    end
  end
end

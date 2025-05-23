# Skip during asset precompilation
unless defined?(Rake) && Rake.application.top_level_tasks.include?('assets:precompile')
  if Rails.env.production?
    begin
      Rails.application.config.middleware.delete(ActiveRecord::Migration::CheckPending)
      
      # Skip AR connection
      if defined?(ActiveRecord::Base)
        ActiveRecord::Base.establish_connection(adapter: :nulldb)
      end
      
      # Mock AR methods
      module ActiveRecord
        class Base
          def self.has_many(*args); end
          def self.has_one(*args); end
          def self.belongs_to(*args); end
          def self.has_and_belongs_to_many(*args); end
        end
      end
    rescue => e
      puts "Failed to disable ActiveRecord: #{e.message}"
    end
  end
end

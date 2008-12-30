require_dependency 'project'
 
# Patches Redmine's projects dynamically. Adds a relationship
# Issue +belongs_to+ to Deliverable
module ProjectPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
 
    base.send(:include, InstanceMethods)
 
    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      has_many :todos
      #raise ActiveRecord::RecordNotFound, "pie"
    end
 
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end
end
 
# Add module to Project
Project.send(:include, ProjectPatch)


ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
          :default => "%d/%m/%Y",
          :short_day => "%b %d"
)


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



# Patches Redmine's Users dynamically. 
# Adds relationships for accessing assigned and authored todos.
module UserPatch
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
 
    base.send(:include, InstanceMethods)
 
    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      
      #A user can 
      has_many :authored_todos, :class_name => 'Todo', :foreign_key => 'author_id', :order => 'position'
      has_many :assigned_todos, :class_name => 'Todo', :foreign_key => 'assigned_to_id', :order => 'position'
      
      #define a method to get the todos belonging to this user by UNIONing the above two collections
      def todos
        self.authored_todos | self.assigned_todos
      end
      #raise ActiveRecord::RecordNotFound, "pie"
    end
 
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end
end
 
# Add module to Project
User.send(:include, UserPatch)


ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
          :default => "%d/%m/%Y",
          :short_day => "%b %d"
)


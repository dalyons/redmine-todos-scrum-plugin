#require_dependency 'project'
#require_dependency 'user'
#require 'project'
#require_dependency 'project'
#require_dependency 'user'

# Patches Redmine's projects dynamically. Adds a relationship
# Issue +belongs_to+ to Deliverable
module TodosProjectPatch
 # require_dependency 'project'

  def self.included(base) # :nodoc:
    Project.extend(ClassMethods)
 
    Project.send(:include, InstanceMethods)
 
    # Same as typing in the class
    Project.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      has_many :todos, :as => :todoable, :dependent => :destroy
      #raise ActiveRecord::RecordNotFound, "pie"
	#puts "ARRRRGH!!!!!!!!!!" + base.to_s
    end
 
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
  end
end

# Patches Redmine's Users dynamically. 
# Adds relationships for accessing assigned and authored todos.
module TodosUserPatch
  
  def self.included(base) # :nodoc:
    base.extend(ClassMethods)
 
    base.send(:include, InstanceMethods)
 
    # Same as typing in the class
    base.class_eval do
      unloadable # Send unloadable so it will not be unloaded in development
      
      has_many :todos, :as => :todoable, :dependent => :destroy
      
      #A user can 
      has_many :authored_todos, :class_name => 'Todo', :foreign_key => 'author_id', :order => 'position'
      has_many :assigned_todos, :class_name => 'Todo', :foreign_key => 'assigned_to_id', :order => 'position'
      
      #define a method to get the todos belonging to this user by UNIONing the above two collections
      def my_todos
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
 
ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(
          :default => "%d/%m/%Y",
          :short_day => "%b %d"
)


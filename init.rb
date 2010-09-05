require 'redmine'

# Hooks
require_dependency 'todo_issues_hook'

# Patches to the Redmine core
require 'dispatcher'

Dispatcher.to_prepare do
  require_dependency 'project'
  require_dependency 'user'

  #application.rb changed names between rails verisons - hack for backwards compatibility
  begin
    require_dependency 'application_controller'
  rescue MissingSourceFile
    require_dependency 'application'
  end

  #This file loads some associations into the core redmine classes, like associations to todos.
    require 'patch_redmine_classes'
  require 'todo_issues_controller_patch'

  # Add module to Project.
  Project.send(:include, TodosProjectPatch)

  # Add module to User, once.
  User.send(:include, TodosUserPatch)

  IssuesController.send(:include, TodoIssuesControllerPatch)
end

Redmine::Plugin.register :redmine_todos_plugin do
  name 'Redmine Todo Lists plugin'
  author 'David Lyons'
  description 'A plugin to create and manage agile-esque todo lists on a per project basis.'
  version '0.0.4.1'
  

  settings :default => {
    'todos_auto_complete_parent' => false
  }, :partial => 'settings/settings'
  
  
  project_module :todo_lists do
    permission :view_todos, {:todos => [:index, :show] }
      
    permission :edit_todos,
      {:todos => [:create, :destroy, :new, :toggle_complete, :sort, :edit, :update],
        :issues => [:create, :destroy, :new, :toggle_complete, :sort, :edit, :update]}
  
    permission :use_personal_todos,
      {:mytodos => [:index,:destroy, :new, :create, :toggle_complete, :index, :sort, :edit, :update]}
         
  end
 
  menu :top_menu, :mytodos, { :controller => 'mytodos', :action => 'index' }, 
    :caption => :my_todos_title,
    :if => Proc.new {
      User.current.allowed_to?(:use_personal_todos, nil, :global => true)
    }
     
  menu :project_menu, :todos, {:controller => 'todos', :action => 'index'}, 
      :caption => :label_todo_plural, :after => :new_issue, :param => :project_id

  activity_provider :todos, :default => false
end

#fix required to make the plugin work in devel mode with rails 2.2
# as per http://www.ruby-forum.com/topic/171629
load_paths.each do |path|
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end





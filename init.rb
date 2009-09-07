require 'redmine'

#This file loads some associations into the core redmine classes, like associations to todos.
##REMOVED because I couldnt get it to work in dev enviroment, where model classes are continiously reloaded
#require 'patch_redmine_classes'
#
# Hooks
require 'todo_issues_hook'

# Patches to the Redmine core
require 'dispatcher'

Dispatcher.to_prepare do
  require_dependency 'application'
  require 'todo_issues_controller_patch'
  IssuesController.send(:include, TodoIssuesControllerPatch)
end

Redmine::Plugin.register :redmine_todos_plugin do
  name 'Redmine Todo Lists plugin'
  author 'David Lyons'
  description 'A plugin to create and manage agile-esque todo lists on a per project basis.'
  version '0.0.3.7'
  

  settings :default => {
    'todos_auto_complete_parent' => false
  }, :partial => 'settings/settings'
  
  
  project_module :todo_lists do
  	permission :view_project_todo_lists,
      {:todos => [:index] }
      
    permission :edit_project_todo_lists, 
      {:todos => [:create, :destroy, :new, :toggle_complete, :sort],
        :issues => [:create, :destroy, :new, :toggle_complete, :sort]}
  
    permission :use_personal_todo_lists, 
      {:mytodos => [:index,:destroy, :new, :create, :toggle_complete, :index, :sort]}
         
  end
	
  menu :top_menu, :mytodos, { :controller => 'mytodos', :action => 'index' }, 
      :caption => :my_todos_title #, :public => false
     
  menu :project_menu, :todos, {:controller => 'todos', :action => 'index'}, 
      :caption => :project_todos_title, :after => :new_issue, :param => :project_id
end

#fix required to make the plugin work in devel mode with rails 2.2
# as per http://www.ruby-forum.com/topic/171629
load_paths.each do |path|
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end





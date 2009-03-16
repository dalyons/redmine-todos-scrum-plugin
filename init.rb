require 'redmine'

#This file loads some associations into the core redmine classes, like associations to todos.
##REMOVED because I couldnt get it to work in dev enviroment, where model classes are continiously reloaded
#require 'patch_redmine_classes'

Redmine::Plugin.register :redmine_todo_lists do
  name 'Redmine Todo Lists plugin'
  author 'David Lyons'
  description 'A plugin to create and manage agile-esque todo lists on a per project basis.'
  version '0.0.3.1'
  
  
  #project_module :task_lists_module do
   # permission :view_customer, {:customers => [:show]}
   # permission :assign_customer, {:customers => [:assign, :select]}
   # permission :see_customer_list, {:customers => [:list]}
   # permission :edit_customer, {:customers => [:edit, :update, :new, :create, :destroy]}
  #end

  settings :default => {
    'todos_auto_complete_parent' => false
  }, :partial => 'settings/settings'
  
  
  project_module :todo_lists do
  	permission :view_project_todo_lists, {:todos => [:index] }
  	permission :edit_project_todo_lists, 
  	    {:todos => [:create, :destroy, :new, :toggle_complete, :sort]} 
  	
  	permission :use_personal_todo_lists, {:mytodos =>
  	       [:index,:destroy, :new, :create, :toggle_complete, :index, :sort]}
  	       
  	#, :require => :member#{:todos => [:index, :my_todos]}  #, :public => true
  	
  end
	
	menu :top_menu, :todo_lists, { :controller => 'mytodos', :action => 'index' }, :caption => 'My todos'
  menu :project_menu, :todo_lists, {:controller => 'todos', :action => 'index'}, :caption => :projects_todo_title, :after => :new_issue, :param => :project_id
end

#fix required to make the plugin work in devel mode with rails 2.2
# as per http://www.ruby-forum.com/topic/171629
load_paths.each do |path|
  ActiveSupport::Dependencies.load_once_paths.delete(path)
end





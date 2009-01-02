require 'redmine'

require_dependency 'patch_redmine_classes'

Redmine::Plugin.register :redmine_task_lists do
  name 'Redmine Task Lists plugin'
  author 'David Lyons'
  description 'A plugin to create and manage agile-esque todo lists on a per project basis.'
  version '0.0.2'
  
  
  #project_module :task_lists_module do
   # permission :view_customer, {:customers => [:show]}
   # permission :assign_customer, {:customers => [:assign, :select]}
   # permission :see_customer_list, {:customers => [:list]}
   # permission :edit_customer, {:customers => [:edit, :update, :new, :create, :destroy]}
  #end

	settings :default => {
		'todos_auto_complete_parent' => false
	}, :partial => 'settings/settings'
  
  
  project_module :task_lists do
  	permission :view_task_lists, {:todos => [:index, 'my_todos'] } #, :require => :member#{:todos => [:index, :my_todos]}  #, :public => true
  	permission :edit_task_lists, {:todos => [:create, :destroy, :new, :toggle_complete, :index, :sort]}
  end
	
	menu :top_menu, :task_lists, { :controller => 'todos', :action => 'my_todos' }, :caption => 'My todos'
  menu :project_menu, :task_lists, {:controller => 'todos', :action => 'index'}, :caption => :projects_todo_title, :after => :new_issue, :param => :project_id
end

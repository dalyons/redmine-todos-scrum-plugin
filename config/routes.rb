#custom routes for this plugin
ActionController::Routing::Routes.draw do |map|

  map.resources :todos, :name_prefix => 'project_', :path_prefix => '/projects/:project_id',
    :member => {:toggle_complete => :post }, :collection => {:sort => :post}
  
  map.resources :todos, :name_prefix => 'user_', :path_prefix => '/users/:user_id', :controller => :mytodos,
    :member => {:toggle_complete => :post }, :collection => {:sort => :post}
  
  #nicer looking shortcut to mytodos for the top menu
  map.my_todos 'my/todos', :controller => :mytodos, :action => :index
  
  #map.resources :mytodos, :name_prefix => 'project_', :path_prefix => '/projects/:project_id'
  #map.with_options :controller => 'mytodos' do |mytodos_routes|
  #  mytodos_routes.new_personal_todo 'mytodos/:parent_id/new', :action => 'new'
  #  mytodos_routes.connect 'mytodos/:parent_id/new.:format', :action => 'new'
  #end
  
  #  map.resources :comments, :path_prefix => '/articles/:article_id'

    #map.with_options :controller => 'todos' do |todos_routes|

    #todos_routes.new_issue_todo 'projects/:project_id/issues/:issue_id/todos/:parent_id/new', :action => 'new'
    #todos_routes.new_project_todo 'projects/:project_id/todos/:parent_id/new', :action => 'new'
    #todos_routes.connect 'projects/:project_id/issues/:issue_id/todos/:parent_id/new(.:format)', :action => 'new'
    #todos_routes.connect "projects/:project_id/todos/:action/:id"
    #todos_routes.connect "projects/:project_id/todos/:action/:id.:format"
    
  #end

end

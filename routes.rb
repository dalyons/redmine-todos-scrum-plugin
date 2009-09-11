#custom routes for this plugin
ActionController::Routing::Routes.draw do |map|
  map.with_options :controller => 'todos' do |todos_routes|
    todos_routes.connect "projects/:project_id/todos/:action/:id"
    todos_routes.connect "projects/:project_id/todos/:action/:id.:format"
    todos_routes.connect 'projects/:project_id/issues/:issue_id/todos/:parent_id/new', :action => 'new'
    todos_routes.connect 'projects/:project_id/issues/:issue_id/todos/:parent_id/new.:format', :action => 'new'
  end

  map.with_options :controller => 'mytodos' do |mytodos_routes|
    mytodos_routes.connect 'mytodos/:parent_id/new', :action => 'new'
    mytodos_routes.connect 'mytodos/:parent_id/new.:format', :action => 'new'
  end
end
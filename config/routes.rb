  
match  'my/todos'                                            => 'mytodos#index'
post   '/users/:user_id/todos'                               => 'mytodos#create'
post   '/users/:user_id/todos/:id/toggle_complete'           => 'mytodos#toggle_complete'
delete '/users/:user_id/todos/:id'                           => 'mytodos#destroy'
get    '/users/:user_id/todos/:id/edit'                      => 'mytodos#edit'
put    '/users/:user_id/todos/:id'                           => 'mytodos#update'
get    '/users/:user_id/todos/new'                           => 'mytodos#new'
get    '/users/:user_id/todos/:id'                           => 'mytodos#show'
get    '/projects/:project_id/todos/reload'                  => 'todos#show'
#resources :todos do
#  scope '/projects/:project_id', :name_prefix => 'project_' do
#    collection do
#      post :sort
#    end
#    member do
#      post :toggle_complete
#    end
#
#  end
#
#  scope '/users/:user_id', :name_prefix => 'user_' do
#    collection do
#      post :sort
#    end
#    member do
#      post :toggle_complete
#    end
#
#  end
#end

resources :projects do
  resources :todos do
    collection do
      post :sort
    end
    member do
      post :toggle_complete
    end
  end
end

resources :users do
  resources :todos do
    collection do
      post :sort
    end
    member do
      post :toggle_complete
    end
  end
end
  
match 'my/todos', :to => 'mytodos#index'

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
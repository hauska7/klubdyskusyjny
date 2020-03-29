Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  root to: "main#home"

  get '/login', to: 'main#login'
  get '/logout', to: 'main#logout'

  get '/show', to: 'main#show'
  post '/update', to: 'main#update'
  post '/create', to: 'main#create'
  post '/delete', to: 'main#delete'
end

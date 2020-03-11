Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  # resources :events
  post '/events', to: "events#create"
  delete '/events', to: "events#destroy"
  get "/events/:id", to: "events#show"
  # post '/events', to: 'events#create'
  # get '/events', to: 'events#create'
end

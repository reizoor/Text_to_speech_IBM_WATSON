Rails.application.routes.draw do
  root :to => 'watsons#index'
  post '/api', to:'watsons#index', as:'watson_api'
  # ¿get '/api/:text', to:'watson#newapi', as:'watson_see_api'
  # get '/api&&', to:'watsons#api', as:'watson_api'
  
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end

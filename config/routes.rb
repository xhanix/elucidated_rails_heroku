Rails.application.routes.draw do
  resources :sales
  resources :products
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/buy/:permalink', to: 'transactions#new', as: :show_buy
  post '/buy/:permalink', to:'transactions#create', as: :buy
  get '/pickup/:guid', to:'transactions#pickup', as: :pickup
  get  '/download/:guid', to: 'transactions#download', as: :download
end

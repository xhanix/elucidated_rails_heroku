Rails.application.routes.draw do
  get 'plans/show'

  resources :sales
  resources :products
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/buy/:permalink', to: 'transactions#new', as: :show_buy
  post '/buy/:permalink', to:'transactions#create', as: :buy
  get '/pickup/:guid', to:'transactions#pickup', as: :pickup
  get  '/download/:guid', to: 'transactions#download', as: :download
  get  '/status/:guid', to: 'transactions#status', as: :status
  get  '/sub_status/:guid', to: 'subscriptions#status', as: :sub_status
  mount StripeEvent::Engine => '/stripe-events'
  match '/iframe/:permalink' => 'transactions#iframe', via: :get, as: :buy_iframe
  resources :subscriptions
  resources :plans
end

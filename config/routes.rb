 require 'sidekiq/web'

Rails.application.routes.draw do
  devise_for :licenseusers
  devise_for :authusers
  get 'plans/show'

  authenticate :authuser do
   mount Sidekiq::Web => '/sidekiq'
  end

  resources :sales
  resources :products
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
  get '/buy/:permalink', to: 'transactions#new', as: :show_buy
  post '/buy/:permalink', to:'transactions#create', as: :buy
  get '/pickup/:guid', to:'transactions#pickup', as: :pickup
  get  '/download/:guid', to: 'transactions#download', as: :download

  get  '/status/:guid', to: 'transactions#status', as: :status
  mount StripeEvent::Engine => '/stripe-events'
  match '/iframe/:permalink' => 'transactions#iframe', via: :get, as: :buy_iframe
  get  '/sub_status/:guid', to: 'subscriptions#status', as: :sub_status
  get '/download_app/:guid', to:'subscriptions#pickup', as: :download_app
  get 'app_download/:guid', to: 'subscriptions#download', as: :app_download
  resources :subscriptions do
    member do
      get 'cancel'
    end
  end
  resources :plans
  root 'static_pages#home'
  get '/about', to: 'static_pages#about'
  get '/home', to: 'static_pages#home'
  get '/pricing', to: 'static_pages#pricing'
  get '/features', to: 'static_pages#features'
  get '/contact', to: 'static_pages#contact'
  get  "/client_token", to: 'subscriptions#clienToken', as: :client_token
  post '/webhooks', to: 'webhooks#parse', as: :webhook
end

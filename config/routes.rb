Rails.application.routes.draw do

  get '/add_collection', to: 'eight_track_actions#add_collection', as: :add_collection
  get '/showmix', to: 'mixes#show', as: :show_mix
  get '/play(/:mix_id)', to: 'player#play', as: :play

  match ":controller(/:action(/:id))", via: [:get, :post, :delete]
  get '/search',    to: 'mixes#index', as: :search
  get '/next_page', to: 'mixes#query_next_page', as: :next_page
  get '/login', to: 'session#new', as: :login
  get '/signup', to: 'session#signup', as: :signup
  get '/logout', to: 'session#logout', as: :logout
  get '/hot_tags_search', to: 'mixes#hot_tags_search', as: :hot_tags_search
  root to: 'home#welcome', as: 'home'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end

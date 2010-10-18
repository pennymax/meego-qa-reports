Meegoqa::Application.routes.draw do
  devise_for :users

  # The priority is based upon order of creation:
  # first created -> highest priority.

  match '/upload' => 'reports#upload_form', :via => "get"
  match '/upload_post' => 'reports#upload', :via => "post"
  match '/upload_attachment' => 'reports#upload_attachment', :via => "post"

  match '/finalize' => 'reports#preview', :via => "get"
  match '/publish' => 'reports#publish', :via => "post"
  match '/edit' => 'reports#edit', :via => "get"
  match '/report/list/:target-:testtype-:hwproduct' => 'reports#filtered_list', :via => "get"
  match '/report/list/:target-:testtype' => 'reports#filtered_list', :via => "get"
  match '/report/list/:target' => 'reports#filtered_list', :via => "get"
  match '/report/view/(:id)' => 'reports#view', :via => "get"
  match '/report/print/(:id)' => 'reports#print', :via => "get"
  
  match '/delete' => 'reports#delete', :via => "post"


  match '/ajax_update_txt' => 'reports#update_txt', :via => "post"
  match '/ajax_update_title' => 'reports#update_title', :via => "post"
  match '/ajax_update_comment' => 'reports#update_case_comment', :via => "post"
  match '/ajax_update_result' => 'reports#update_case_result', :via => "post"
  
  match '/fetch_bugzilla_data' => 'reports#fetch_bugzilla_data', :via => "get"

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => "welcome#index"

  root :to => "reports#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end

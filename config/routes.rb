Meegoqa::Application.routes.draw do
  devise_for :users, :controllers => { :sessions => "users/sessions" }  #, :path_names => { :sign_up => "b52b6563d18b1458d90466504d63afca/register" }

  # The priority is based upon order of creation:
  # first created -> highest priority.

  match '/upload_post' => 'upload#upload', :via => "post"
  match '/upload_attachment' => 'upload#upload_attachment', :via => "post"

  match '/finalize' => 'reports#preview', :via => "get"
  match '/publish' => 'reports#publish', :via => "post"
  

  constraints(:release_version => /\d+\.{1}\d+/) do
    match '/:release_version/:target/:testtype/:hwproduct/upload' => 'upload#upload_form', :via => "get"
    match '/:release_version/:target/:testtype/upload' => 'upload#upload_form', :via => "get"
    match '/:release_version/:target/upload' => 'upload#upload_form', :via => "get"
    match '/:release_version/upload' => 'upload#upload_form', :via => "get"

    match '/:release_version/:target/:testtype/:hwproduct/:id' => 'reports#view', :via => "get"
    match '/:release_version/:target/:testtype/:hwproduct/:id/edit' => 'reports#edit', :via => "get"
    match '/:release_version/:target/:testtype/:hwproduct/:id/delete' => 'reports#delete', :via => "post"
    match '/:release_version/:target/:testtype/:hwproduct/:id/print' => 'reports#print', :via => "get"
    
    match '/:release_version/:target/:testtype/:hwproduct' => 'index#filtered_list', :via => "get"
    match '/:release_version/:target/:testtype' => 'index#filtered_list', :via => "get"
    match '/:release_version/:target' => 'index#filtered_list', :via => "get"
    match '/:release_version' => 'index#index', :via => "get"
  end

  match '/upload' => 'upload#upload_form', :via => "get"

  match '/ajax_update_txt' => 'reports#update_txt', :via => "post"
  match '/ajax_update_title' => 'reports#update_title', :via => "post"
  match '/ajax_update_comment' => 'reports#update_case_comment', :via => "post"
  match '/ajax_update_result' => 'reports#update_case_result', :via => "post"
  
  match '/fetch_bugzilla_data' => 'reports#fetch_bugzilla_data', :via => "get"

  # to test exception notifier
  match '/raise_exception' => 'exceptions#index'

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

  root :to => "index#index"

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id(.:format)))'
end

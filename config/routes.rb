Rails.application.routes.draw do
  # get "dashboard/index" -------------------------se comento
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
  
  # Render dynamic PWA files from app/views/pwa/*
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker -------------------------se comento
  
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest -------------------------se comento
  
  
  # Defines the root path route ("/")
  # root "posts#index"
  # mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?
  resources :posts
  resources :rooms, only: [:index, :create, :destroy]
  
  get 'posts/increment', as: :increment
  post 'job_groups', to: "posts#job_groups"
  
  root to: 'pages#home'
  
  devise_for :users, skip: [:registrations]

  # ERRORS
  match "/404", to: "errors#not_found", via: :all
  match "/500", to: "errors#internal_server_error", via: :all
  match "/503", to: "errors#service_unavailable", via: :all
  match "not_found", to: "errors#not_found", via: :all
  match "not_allowed", to: "errors#not_allowed", via: :all
  
  
  resources :catalogs do
    resources :products 
    collection do
      get 'showcase'
    end
  end

  get '/movements/product_exchange_form', to: 'movements#product_exchange_form'

  resources :movements do
    collection do
      get :catalog_content
    end
  end


  resources :products do
    member do
      patch 'toggle_active'
    end
  end
  resources :alerts
  resources :relationships
  resources :company_settings
  resources :relation_ships
  resources :branch_settings
  resources :people
  resources :person_addresses
  resources :person_phones
  resources :person_emails
  resources :groups
  resources :group_users
  resources :companies
  resources :cities
  resources :branch_settings
  resources :posts
  resources :users
 resources :branch_users do
  member do
    patch 'toggle_active'
  end
end


  resources :branch_alerts do
    collection do
      post :mark_as_read
      post :filter_alerts
    end
  end

  post 'mark_as_read', to: 'alerts#mark_as_read'

  get '/movements/:id/annulment', to: 'movements#annulment', as: 'annulment'

  get '/customers/search_person_customers', to: redirect('/movements/new')
  get '/customers/search_person_customer', to: redirect('/movements/new')
  resources :customers do
    collection do
      post :search_person_customer, defaults: { format: :turbo_stream }
      post :search_person_customers, to: 'customers#search_person_customer',defaults: { format: :turbo_stream }
    end
  end

  get 'new_group_movement', to: 'groups#new_movement'
  post 'create_group_movement', to: 'groups#create_movement'

  get '/customers/:id/current_account', to: 'customers#current_account', as: 'current_account'
  get '/customers/:id/current_account_exteneral', to: 'customers#current_account_exteneral', as: 'current_account_exteneral'

  get 'new_customer_wizard', to: 'customers#new_customer_wizard'
  post 'wizard_previous_step', to: 'customers#wizard_previous_step'
  post 'wizard_next_step', to: 'customers#wizard_next_step'
  post 'validate_person', to: 'customers#validate_person'

  get 'search_customer_person', to: 'customers#search_customer_person'
  post 'create_customer_external', to: 'people#create_customer_external'
  get 'confirmation_principal_person', to: 'people#confirmation_principal_person'
  get 'validate_email/:token', to: 'people#validate_email', as: :validate_email
  get 'email_validated', to: 'people#email_validated', as: :email_validated
  get 'email_validation_error', to: 'people#email_validation_error', as: :email_validation_error
  get 'finish_upload', to: 'people#finish_upload'
  get 'person_balance', to: 'people#balance'

  post 'turbo_test', to: 'customers#turbo_test'
  # post 'search_person_customer', to: 'customers#search_person_customer'
  post 'excel_customers', to: 'customers#excel_customers'
  post 'search_person_by_document', to: 'people#search_by_document'

  post 'activate_customer', to: 'customers#activate_customer'

  get '/people_pending', to: 'people#people_pending'

  resources :states do
    collection do
      get :cities
    end
  end

  resources :countries do
    collection do
      get :states
    end
  end

  resources :branches do
    get :edit_days_sleep
    get :show_days_sleep
    get :edit_admits_exchange
    get :show_admits_exchange
    get :edit_admits_product_exchange
    get :show_admits_product_exchange
    get :edit_alert_quantity
    get :show_alert_quantity
    patch :update_alert_quantity
    put :update_alert_quantity
    get :edit_email
    get :show_email
    get :qr_branch
    post :upload_image
    post :email_upload_image
    delete :delete_image
    delete :email_delete_image
    post :change_background_color
    post :change_text_color
    get :today_settings, on: :member
  end

  get '/companies/:id/edit_days_sleep', to: 'companies#edit_days_sleep', as: 'edit_days_sleep'
  get '/companies/:id/show_days_sleep', to: 'companies#show_days_sleep', as: 'show_days_sleep'

  get '/companies/:id/edit_alert_quantity', to: 'companies#edit_alert_quantity', as: 'edit_alert_quantity'
  get '/companies/:id/show_alert_quantity', to: 'companies#show_alert_quantity', as: 'show_alert_quantity'

  patch '/companies/:id/update_alert_quantity', to: 'companies#update_alert_quantity', as: 'update_alert_quantity'
  put '/companies/:id/update_alert_quantity', to: 'companies#update_alert_quantity'

  get '/companies/:id/edit_email', to: 'companies#edit_email', as: 'edit_email'
  get '/companies/:id/show_email', to: 'companies#show_email', as: 'show_email'

  get '/qr_companies/:id', to: 'companies#qr_companies', as: 'qr_companies'
  get '/all_qr_company/:id', to: 'companies#all_qr_company', as: 'all_qr_company'

  post 'create_employee', to: 'branch_users#create_employee'
  post '/branch_users/:id/edit_employee', to: 'branch_users#edit_employee', as: 'edit_employee'
  
  get 'form_employee', to: 'branch_users#form_employee'
  post 'add_or_create_employee', to: 'branch_users#add_or_create_employee'

  get 'dashboard', to: 'pages#dashboard' # Graficos
  get 'general_data', to: 'pages#general_data' # Datos y estadisticas Generales
  get 'periodic_data', to: 'pages#periodic_data' # Datos periodicos

  get 'error404', to: 'pages#error404'
  get 'not_allowed', to: 'pages#not_allowed'

  get 'select_company', to: 'pages#select_company'
  get 'set_group', to: 'application#set_group'
  get 'set_company', to: 'application#set_company'
  get 'select_branch', to: 'pages#select_branch'
  get 'set_branch', to: 'application#set_branch'
  post 'enter_as_admin', to: 'application#enter_as_admin'

  post 'excel_movements', to: 'movements#excel_movements'

  post 'upload_image_company', to: 'companies#upload_image_company', as: 'upload_image_company'
  delete 'delete_image_company', to: 'companies#delete_image_company'

  post 'select_country', to: 'countries#select_country'
  post 'select_state', to: 'states#select_state'
  get 'generate_qr_pdf', to: 'companies#generate_qr_pdf'

  # -------------------------Filtros----------------------------------
  post 'filter_alerts', to: 'alerts#filter_alerts'

  post 'filter_movements', to: 'movements#filter_movements'
  post 'filter_customers', to: 'customers#filter_customers'
  post 'filter_employees', to: 'branch_users#filter_employees'



  post 'form_new_person', to: 'customers#form_new_person'
  get 'form_new_person', to: 'customers#form_new_person'

  post 'associate_company',  to: 'customers#associate_company'

  post 'activate_employee', to: 'branch_users#activate_employee'

  post 'create_user', to:'users#create_user'

  get 'show_branch_users', to: 'branch_users#show_branch_users'

  # -------------------------QRs----------------------------------
  get 'query_customer', to: 'customers#query_customer', as: 'query_customer'
  get 'new_customer_external', to: 'customers#new_customer_external'
  get 'new_movement_external', to: 'movements#new_movement_external'


  resources :qr_branches, only: [] do
    collection do
      get :all_qr_branch
      get :new_customer_external
      # post :search_person_customer, defaults: { format: :turbo_stream }
      get :query_customer
      get :new_movement_external
    end
  end


  # New routes working:
  post 'test_email', to:'redis_keys#test_email'
  post 're_send_movement_mail', to:'redis_keys#re_send_movement_mail'
  get '/redis_keys', to: 'redis_keys#index', as: 'redis_keys'
  get '/redis_keys/new', to: 'redis_keys#new_task', as: 'new_redis_keys'
  post '/redis_keys', to: 'redis_keys#create_task'
  get '/redis_keys/:key/edit', to: 'redis_keys#edit_task'
  put '/redis_keys/:key', to: 'redis_keys#update_task'
  patch '/redis_keys/:key', to: 'redis_keys#update_task'
  delete '/redis_keys/:key', to: 'redis_keys#destroy_task'
  resources :redis_keys, only: [:index] do
    post :clear_tmp_pdfs, on: :collection
    collection do
      post :import_keys
    end
  end


  get 'update_frame_content', to: 'pages#update_frame_content'
  post 'update_stream_content', to: 'pages#update_stream_content'
  get 'load_customers_graphs', to: 'pages#load_customers_graphs'
end

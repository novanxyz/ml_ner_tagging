Rails.application.routes.draw do

    devise_for :user,
                class_name: 'Core::Admin',
                module: :devise,
                path: 'backoffice',
                path_names: { sign_in: 'login', sign_out: 'logout' },
               :controllers => {
                   sessions: 'core/admin/sessions',
                   registrations: 'core/admin/registrations',
                   passwords: 'core/admin/passwords'
               }

    # devise_scope :user do
    #     get '/admin', to: 'devise/sessions#new', as: 'backoffice_home'
    # end               

    root to: 'index#index'

    scope :backoffice do
        root to: 'backoffice#index', :as => "backoffice"

		get '/users/log_user_notification', to: 'backoffice#page' , defaults: {:path => 'users', :name => 'log_user_notification' },  :as => "log_user_notification"
        get '/users/:id', controller: 'core/users', action: 'show', :as => "core_user"
        get '/users/:id/edit', controller: 'core/users', action: 'edit', :as => "user_edit"
        get '/insurances/:id/claims', controller: 'insurances/insurances', action: 'show', :as => "user_claims"
		
		get '/:path(/:name)', to: 'backoffice#page'
    end

    scope :api do        

        # http://guides.rubyonrails.org/routing.html#adding-more-restful-actions
        resources :users, controller: 'core/users', except: :delete do
            get 'delete', on: :member
        end

        resources :groups, controller: 'admin/groups', except: :delete do
            get 'delete', on: :member
        end

        resources :articles, controller: 'core/articles', except: :delete do
            get 'delete', on: :member
        end
        
        ## ADDITIONAL ROUTINGS ##
		resources :statistics, controller: 'admin/statistics' do
			get 'delete', on: :member 
		end

		resources :magazines, controller: 'admin/magazines' do
			get 'delete', on: :member 
		end

		resources :questions, controller: 'core/questions' do
			get 'delete', on: :member 
		end

		resources :contact_times, controller: 'insurances/contact_times' do
			get 'delete', on: :member 
		end

		resources :faqs, controller: 'insurances/faqs' do
			get 'delete', on: :member 
		end

		resources :providers, controller: 'insurances/providers' do
			get 'delete', on: :member 
		end

		resources :templates, controller: 'insurances/templates' do
			get 'delete', on: :member 
		end

		resources :insurances, controller: 'insurances/insurances' do
			get 'delete', on: :member 
		end

		resources :division_actions, controller: 'core/division_actions' do
			get 'delete', on: :member 
		end

		resources :roles, controller: 'core/roles' do
			get 'delete', on: :member 
		end

		resources :automated_notifications, controller: 'admin/automated_notifications' do
			get 'delete', on: :member 
		end

		resources :user_notifications, controller: 'users/user_notifications' do
			get 'delete', on: :member 
			post 'upload', to: :upload
		end
		

		resources :interests, controller: 'core/interests' do
			get 'delete', on: :member 
		end

		resources :user_meta_descriptions, controller: 'core/user_meta_descriptions' do
			get 'delete', on: :member 
		end

		resources :doctors, controller: 'core/doctors' do
			get 'delete', on: :member 
		end

		resources :divisions, controller: 'core/divisions' do
			get 'delete', on: :member 
		end

		resources :admins, controller: 'core/admins' do
			get 'delete', on: :member 
		end

		resources :users, controller: 'core/users' do
			get 'delete', on: :member 
		end

		resources :claims, controller: 'insurances/claims' do
			get 'delete', on: :member # http://guides.rubyonrails.org/routing.html#adding-more-restful-actions
		end

        resources :admins, controller: 'core/admins' do
            get 'delete', on: :member # http://guides.rubyonrails.org/routing.html#adding-more-restful-actions
        end
			
        resources :quota, controller: 'insurances/quota' do
            get 'delete', on: :member # http://guides.rubyonrails.org/routing.html#adding-more-restful-actions
        end

        resources :cities, controller: 'admin/cities' do
            get 'delete', on: :member # http://guides.rubyonrails.org/routing.html#adding-more-restful-actions
        end

    end

    get 'tinymce',  to: 'core/articles#tinymce'
    resources :articles, param: :slug, controller: 'index', path: '/', only: :show
  
  
end

Rails.application.routes.draw do
  resource :session
  resources :passwords, param: :token
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  namespace :admin do
    root "dashboard#index"

    resources :clients
    resources :projects do
      resources :budgets, shallow: true, except: :index do
        member do
          post :send_to_client
          post :new_version
        end
        resources :budget_items, shallow: true, except: %i[ index show ]
      end
    end
    resources :time_entries, only: %i[ index new create destroy ]
    resources :rates, only: %i[ index new create ]
    resources :maintenance_contracts do
      member { post :generate_charge }
    end
    resources :maintenance_charges, only: :index
    resources :payments, except: %i[ edit update destroy ] do
      member do
        patch :confirm
        patch :reject
      end
    end
    resources :users, except: %i[ show destroy ]
  end

  root "admin/dashboard#index"
end

EventEngine::Engine.routes.draw do
  namespace :dashboard do
    root to: "home#index"
    resources :events, only: [:index, :show]
    resources :dead_letters, only: [:index] do
      member do
        post :retry
      end
      collection do
        post :retry_all
      end
    end
  end
end

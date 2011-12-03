TenderScraper::Application.routes.draw do
  resources :tenders do
    member do
      get 'unlock'
      get 'lock'
    end
    collection do
      get 'get_statuses'
    end
  end
  root :to => 'tenders#index'
end

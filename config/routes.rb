TenderScraper::Application.routes.draw do
  resources :tenders do
    member do
      get 'unlock'
      get 'lock'
    end
  end
  root :to => 'tenders#index'
end

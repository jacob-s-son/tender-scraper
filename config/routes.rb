TenderScraper::Application.routes.draw do
  resources :tenders do
    get 'toggle_lock', :on => :member
  end
  root :to => 'tenders#index'
end

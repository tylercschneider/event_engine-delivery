Rails.application.routes.draw do
  mount EventEngine::Delivery::Engine => "/event_engine", as: :event_engine
end

Rails.application.routes.draw do
  mount EventEngine::Delivery::Engine => "/event_engine-delivery"
end

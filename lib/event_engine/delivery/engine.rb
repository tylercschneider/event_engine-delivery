module EventEngine
  module Delivery
    class Engine < ::Rails::Engine
      isolate_namespace EventEngine::Delivery
    end
  end
end

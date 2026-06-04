require "test_helper"

class DefinitionLoaderTest < ActiveSupport::TestCase
  test "eager load registers event definitions" do
    EventEngine::DefinitionLoader.ensure_loaded!

    assert EventEngine::EventDefinition.descendants.any?,
           "Expected at least one EventDefinition to be loaded"
  end
end

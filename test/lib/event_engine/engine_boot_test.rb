require "test_helper"
require "tempfile"

class EngineBootTest < ActiveSupport::TestCase
  include EventEngineTestHelpers

  test "engine loads schema file into registry and installs helpers" do
    helpers_snapshot = snapshot_event_engine_helpers
    file = Tempfile.new(["event_schema", ".rb"])

    file.write(<<~RUBY)
      EventEngine::EventSchema.define do |schema|
        schema.register(
          EventEngine::EventDefinition::Schema.new(
            event_name: :cow_fed,
            event_version: 1,
            event_type: :domain,
            required_inputs: [:cow],
            optional_inputs: [],
            payload_fields: [{ name: :weight, from: :cow, attr: :weight }]
          )
        )
      end
    RUBY
    file.close

    assert_nothing_raised do
      EventEngine::Engine.send(
        :load_schema_and_install_helpers,
        schema_path: file.path
      )
    end

    assert EventEngine.respond_to?(:cow_fed)
  ensure
    restore_event_engine_helpers(helpers_snapshot)
    file.unlink if file
  end
end

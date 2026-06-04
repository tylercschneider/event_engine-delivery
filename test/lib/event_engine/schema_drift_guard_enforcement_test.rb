require "test_helper"
require "tempfile"

class SchemaDriftGuardEnforcementTest < ActiveSupport::TestCase
  class CowFed < EventEngine::EventDefinition
    event_name :cow_fed
    event_type :domain
    input :cow
    required_payload :weight, from: :cow, attr: :weight
  end

  test "raises when DSL and schema file are out of sync" do
    file = Tempfile.new("event_schema.rb")

    # Baseline dump
    EventEngine::EventSchemaDumper.dump!(
      definitions: [CowFed],
      path: file.path
    )

    # Introduce drift
    CowFed.required_payload :age, from: :cow, attr: :age

    assert_raises(EventEngine::SchemaDriftGuard::DriftError) do
      EventEngine::SchemaDriftGuard.check!(
        schema_path: file.path,
        definitions: [CowFed]
      )
    end
  ensure
    file.unlink
  end
end

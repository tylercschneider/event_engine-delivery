require "test_helper"
require "tempfile"

class EventSchemaDriftGuardTest < ActiveSupport::TestCase
  class CowFed < EventEngine::EventDefinition
    event_name :cow_fed
    event_type :domain
    input :cow
    required_payload :weight, from: :cow, attr: :weight
  end

  test "fails when DSL and event_schema.rb are out of sync" do
    file = Tempfile.new("event_schema.rb")

    # First dump (baseline)
    EventEngine::EventSchemaDumper.dump!(
      definitions: [CowFed],
      path: file.path
    )

    # Modify DSL (introduce drift)
    CowFed.required_payload :age, from: :cow, attr: :age

    # Dump again to a string (expected schema)
    expected_file = Tempfile.new("expected_event_schema.rb")
    EventEngine::EventSchemaDumper.dump!(
      definitions: [CowFed],
      path: expected_file.path
    )

    assert_not_equal(
      File.read(file.path),
      File.read(expected_file.path),
      "Schema drift should be detected when DSL changes"
    )
  ensure
    file.unlink
    expected_file.unlink
  end
end

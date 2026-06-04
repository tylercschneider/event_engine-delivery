require "test_helper"
require "tempfile"

class EventSchemaDumpTest < ActiveSupport::TestCase
  class CowFed < EventEngine::EventDefinition
    event_name :cow_fed
    event_type :domain
    input :cow
    required_payload :weight, from: :cow, attr: :weight
  end

  def read_versions(path)
    File.read(path).scan(/event_version:\s*(\d+)/).flatten.map(&:to_i)
  end

  test "dump writes initial version when schema file does not exist" do
    file = Tempfile.new("event_schema.rb")
    path = file.path
    file.unlink # ensure non-existent
 
    EventEngine::EventSchemaDumper.dump!(
      definitions: [CowFed],
      path: path
    )

    versions = read_versions(path)
    assert_equal [1], versions
  ensure
    file.unlink if File.exist?(path)
  end

  test "dump does not create new version when schema unchanged" do
    file = Tempfile.new("event_schema.rb")
    EventEngine::EventSchemaDumper.dump!(
      definitions: [CowFed],
      path: file.path
    )

    EventEngine::EventSchemaDumper.dump!(
      definitions: [CowFed],
      path: file.path
    )

    versions = read_versions(file.path)
    assert_equal [1], versions
  ensure
    file.unlink
  end
end

require "test_helper"
require "rake"

class EventEngineSchemaCheckTaskTest < ActiveSupport::TestCase
  # def setup
  #   Rake.application = Rake::Application.new
  #   Rake.application.clear

  #   load EventEngine::Engine.root.join("lib/tasks/event_engine_schema_check.rake")

  #   Rake::Task.define_task(:environment)
  # end


  # test "schema:check passes when no drift exists" do
  #   compiled = stub_compiled_registry(match: true)
  #   file = stub_file_registry

  #   EventEngine.stub(:compiled_schema_registry, compiled) do
  #     EventEngine.stub(:file_schema_registry, file) do
  #       Rake::Task["event_engine:schema_check"].invoke
  #     end
  #   end
  # end

  # test "schema:check fails when drift exists" do
  #   compiled = stub_compiled_registry(match: false)
  #   file = stub_file_registry

  #   EventEngine.stub(:compiled_schema_registry, compiled) do
  #     EventEngine.stub(:file_schema_registry, file) do
  #       error = assert_raises(RuntimeError) do
  #         Rake::Task["event_engine:schema_check"].invoke
  #       end

  #       assert_match(/Schema drift detected/, error.message)
  #     end
  #   end
  # end

  # private

  # def stub_compiled_registry(match:)
  #   Object.new.tap do |obj|
  #     def obj.events = [:cow_fed]
  #     def obj.latest_for(_)
  #       OpenStruct.new(fingerprint: @fingerprint)
  #     end

  #     obj.instance_variable_set(
  #       :@fingerprint,
  #       match ? "same" : "different"
  #     )
  #   end
  # end

  # def stub_file_registry
  #   Object.new.tap do |obj|
  #     def obj.versions_for(_)
  #       [1]
  #     end

  #     def obj.schema_for(_, _)
  #       OpenStruct.new(fingerprint: "same")
  #     end
  #   end
  # end
end

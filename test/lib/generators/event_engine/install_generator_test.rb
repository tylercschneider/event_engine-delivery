require "test_helper"
require "tmpdir"
require "generators/event_engine/install_generator"

module EventEngine
  module Generators
    class InstallGeneratorTest < ActiveSupport::TestCase
      test "has a generate_subagents method" do
        assert_includes InstallGenerator.instance_methods, :generate_subagents
      end

      # Smoke integration test: run the generator step end to end and confirm it
      # writes an agent definition into the app's .claude/agents/ directory.
      test "generate_subagents writes the define agent into .claude/agents" do
        Dir.mktmpdir do |dir|
          generator = InstallGenerator.new([], {}, destination_root: dir)
          capture_io { generator.generate_subagents }

          assert File.exist?(File.join(dir, ".claude/agents/event_engine-define.md"))
        end
      end
    end
  end
end

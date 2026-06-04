module EventEngineTestHelpers
  def snapshot_event_engine_helpers
    EventEngine.singleton_methods
  end

  def restore_event_engine_helpers(snapshot)
    (EventEngine.singleton_methods - snapshot).each do |method_name|
      EventEngine.singleton_class.remove_method(method_name)
    end
  end
end

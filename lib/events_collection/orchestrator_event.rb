module CommonEvents
  class OrchestratorEvent
    attr_accessor :data
    def initialize(data)
      @data = data
    end

    def process
      throw 'override this method please.'
    end
  end
end
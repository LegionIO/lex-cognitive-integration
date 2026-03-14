# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveIntegration
      class Client
        include Runners::CognitiveIntegration

        def initialize(engine: nil)
          @default_engine = engine || Helpers::IntegrationEngine.new
        end
      end
    end
  end
end

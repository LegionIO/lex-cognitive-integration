# frozen_string_literal: true

require_relative 'cognitive_integration/version'
require_relative 'cognitive_integration/helpers/constants'
require_relative 'cognitive_integration/helpers/modal_signal'
require_relative 'cognitive_integration/helpers/integrated_representation'
require_relative 'cognitive_integration/helpers/integration_engine'
require_relative 'cognitive_integration/runners/cognitive_integration'
require_relative 'cognitive_integration/client'

module Legion
  module Extensions
    module CognitiveIntegration
      extend Legion::Extensions::Core if defined?(Legion::Extensions::Core)
    end
  end
end

# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveIntegration
      module Helpers
        module Constants
          MAX_SIGNALS = 500
          MAX_REPRESENTATIONS = 200
          MIN_SIGNALS_FOR_BINDING = 2

          # Modality types
          MODALITIES = %i[
            visual auditory semantic emotional motor
            proprioceptive temporal spatial contextual
          ].freeze

          # Binding dynamics
          DEFAULT_BINDING_STRENGTH = 0.5
          BINDING_DECAY_RATE = 0.03
          REINFORCEMENT_RATE = 0.08
          CONFLICT_PENALTY = 0.15

          # Thresholds
          COHERENT_THRESHOLD = 0.6
          FRAGMENTED_THRESHOLD = 0.3

          # Binding strength labels
          BINDING_LABELS = {
            (0.8..)     => :tightly_bound,
            (0.6...0.8) => :bound,
            (0.4...0.6) => :loosely_bound,
            (0.2...0.4) => :fragmentary,
            (..0.2)     => :unbound
          }.freeze

          # Signal confidence labels
          CONFIDENCE_LABELS = {
            (0.8..)     => :certain,
            (0.6...0.8) => :confident,
            (0.4...0.6) => :moderate,
            (0.2...0.4) => :low,
            (..0.2)     => :uncertain
          }.freeze

          # Integration quality labels
          QUALITY_LABELS = {
            (0.8..)     => :excellent,
            (0.6...0.8) => :good,
            (0.4...0.6) => :adequate,
            (0.2...0.4) => :poor,
            (..0.2)     => :failed
          }.freeze
        end
      end
    end
  end
end

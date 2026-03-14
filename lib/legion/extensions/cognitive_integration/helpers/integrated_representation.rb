# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveIntegration
      module Helpers
        class IntegratedRepresentation
          include Constants

          attr_reader :id, :signal_ids, :modalities, :binding_strength,
                      :coherence, :created_at

          def initialize(signals:)
            @id               = SecureRandom.uuid
            @signal_ids       = signals.map(&:id)
            @modalities       = signals.map(&:modality).uniq
            @binding_strength = compute_binding(signals)
            @coherence        = compute_coherence(signals)
            @reinforcement_count = 0
            @created_at       = Time.now.utc
          end

          def reinforce!
            @binding_strength = (@binding_strength + REINFORCEMENT_RATE).clamp(0.0, 1.0).round(10)
            @reinforcement_count += 1
            self
          end

          def decay!
            @binding_strength = (@binding_strength - BINDING_DECAY_RATE).clamp(0.0, 1.0).round(10)
            self
          end

          def disrupt!(amount: CONFLICT_PENALTY)
            @binding_strength = (@binding_strength - amount).clamp(0.0, 1.0).round(10)
            @coherence = (@coherence - (amount * 0.5)).clamp(0.0, 1.0).round(10)
            self
          end

          def modal_count = @modalities.size
          def multi_modal? = @modalities.size > 1
          def coherent? = @coherence >= COHERENT_THRESHOLD
          def fragmented? = @coherence < FRAGMENTED_THRESHOLD

          def binding_label
            match = BINDING_LABELS.find { |range, _| range.cover?(@binding_strength) }
            match ? match.last : :unbound
          end

          def quality_label
            score = ((@binding_strength * 0.6) + (@coherence * 0.4)).round(10)
            match = QUALITY_LABELS.find { |range, _| range.cover?(score) }
            match ? match.last : :failed
          end

          def quality_score
            ((@binding_strength * 0.6) + (@coherence * 0.4)).round(10)
          end

          def to_h
            {
              id:                  @id,
              signal_ids:          @signal_ids,
              modalities:          @modalities,
              modal_count:         modal_count,
              multi_modal:         multi_modal?,
              binding_strength:    @binding_strength,
              binding_label:       binding_label,
              coherence:           @coherence,
              coherent:            coherent?,
              fragmented:          fragmented?,
              quality_score:       quality_score,
              quality_label:       quality_label,
              reinforcement_count: @reinforcement_count,
              created_at:          @created_at
            }
          end

          private

          def compute_binding(signals)
            return DEFAULT_BINDING_STRENGTH if signals.empty?

            weights = signals.map(&:effective_weight)
            (weights.sum / weights.size).round(10)
          end

          def compute_coherence(signals)
            return 0.0 if signals.size < 2

            confidences = signals.map(&:confidence)
            mean = confidences.sum / confidences.size
            variance = confidences.sum { |c| (c - mean)**2 } / confidences.size
            (1.0 - Math.sqrt(variance)).clamp(0.0, 1.0).round(10)
          end
        end
      end
    end
  end
end

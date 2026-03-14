# frozen_string_literal: true

require 'securerandom'

module Legion
  module Extensions
    module CognitiveIntegration
      module Helpers
        class ModalSignal
          include Constants

          attr_reader :id, :modality, :content, :confidence, :salience,
                      :created_at

          def initialize(modality:, content:, confidence: 0.5, salience: 0.5)
            @id         = SecureRandom.uuid
            @modality   = modality.to_sym
            @content    = content
            @confidence = confidence.to_f.clamp(0.0, 1.0).round(10)
            @salience   = salience.to_f.clamp(0.0, 1.0).round(10)
            @created_at = Time.now.utc
          end

          def effective_weight
            (@confidence * @salience).round(10)
          end

          def salient?
            @salience >= 0.6
          end

          def confident?
            @confidence >= 0.6
          end

          def confidence_label
            match = CONFIDENCE_LABELS.find { |range, _| range.cover?(@confidence) }
            match ? match.last : :uncertain
          end

          def to_h
            {
              id:               @id,
              modality:         @modality,
              content:          @content,
              confidence:       @confidence,
              confidence_label: confidence_label,
              salience:         @salience,
              effective_weight: effective_weight,
              salient:          salient?,
              created_at:       @created_at
            }
          end
        end
      end
    end
  end
end

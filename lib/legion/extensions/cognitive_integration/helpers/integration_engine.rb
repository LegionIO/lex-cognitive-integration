# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveIntegration
      module Helpers
        class IntegrationEngine
          include Constants

          def initialize
            @signals         = {}
            @representations = {}
          end

          def add_signal(modality:, content:, confidence: 0.5, salience: 0.5)
            prune_signals_if_needed
            signal = ModalSignal.new(modality: modality, content: content,
                                     confidence: confidence, salience: salience)
            @signals[signal.id] = signal
            signal
          end

          def remove_signal(signal_id:)
            @signals.delete(signal_id)
          end

          def integrate(signal_ids:)
            signals = signal_ids.filter_map { |sid| @signals[sid] }
            return nil if signals.size < MIN_SIGNALS_FOR_BINDING

            prune_representations_if_needed
            rep = IntegratedRepresentation.new(signals: signals)
            @representations[rep.id] = rep
            rep
          end

          def integrate_by_modalities(modalities:)
            mods = modalities.map(&:to_sym)
            matching = @signals.values.select { |s| mods.include?(s.modality) }
            return nil if matching.size < MIN_SIGNALS_FOR_BINDING

            integrate(signal_ids: matching.map(&:id))
          end

          def integrate_all_salient
            salient = @signals.values.select(&:salient?)
            return nil if salient.size < MIN_SIGNALS_FOR_BINDING

            integrate(signal_ids: salient.map(&:id))
          end

          def reinforce(representation_id:)
            rep = @representations[representation_id]
            return nil unless rep

            rep.reinforce!
          end

          def disrupt(representation_id:, amount: CONFLICT_PENALTY)
            rep = @representations[representation_id]
            return nil unless rep

            rep.disrupt!(amount: amount)
          end

          def decay_all!
            @representations.each_value(&:decay!)
            prune_weak_representations
            { representations_remaining: @representations.size }
          end

          def signals_by_modality(modality:)
            m = modality.to_sym
            @signals.values.select { |s| s.modality == m }
          end

          def multi_modal_representations
            @representations.values.select(&:multi_modal?)
          end

          def coherent_representations
            @representations.values.select(&:coherent?)
          end

          def fragmented_representations
            @representations.values.select(&:fragmented?)
          end

          def strongest_representations(limit: 5)
            @representations.values.sort_by { |r| -r.binding_strength }.first(limit)
          end

          def average_binding_strength
            return DEFAULT_BINDING_STRENGTH if @representations.empty?

            vals = @representations.values.map(&:binding_strength)
            (vals.sum / vals.size).round(10)
          end

          def average_coherence
            return 0.5 if @representations.empty?

            vals = @representations.values.map(&:coherence)
            (vals.sum / vals.size).round(10)
          end

          def modality_coverage
            @signals.values.map(&:modality).uniq
          end

          def integration_report
            {
              total_signals:            @signals.size,
              total_representations:    @representations.size,
              multi_modal_count:        multi_modal_representations.size,
              coherent_count:           coherent_representations.size,
              fragmented_count:         fragmented_representations.size,
              average_binding_strength: average_binding_strength,
              average_coherence:        average_coherence,
              modality_coverage:        modality_coverage,
              strongest:                strongest_representations(limit: 3).map(&:to_h)
            }
          end

          def to_h
            {
              total_signals:            @signals.size,
              total_representations:    @representations.size,
              multi_modal_count:        multi_modal_representations.size,
              coherent_count:           coherent_representations.size,
              average_binding_strength: average_binding_strength,
              average_coherence:        average_coherence
            }
          end

          private

          def prune_signals_if_needed
            return if @signals.size < MAX_SIGNALS

            oldest = @signals.values.min_by(&:created_at)
            @signals.delete(oldest.id) if oldest
          end

          def prune_representations_if_needed
            return if @representations.size < MAX_REPRESENTATIONS

            weakest = @representations.values.min_by(&:binding_strength)
            @representations.delete(weakest.id) if weakest
          end

          def prune_weak_representations
            @representations.reject! { |_, r| r.binding_strength <= 0.0 }
          end
        end
      end
    end
  end
end

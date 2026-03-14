# frozen_string_literal: true

module Legion
  module Extensions
    module CognitiveIntegration
      module Runners
        module CognitiveIntegration
          include Legion::Extensions::Helpers::Lex if defined?(Legion::Extensions::Helpers::Lex)

          def add_signal(modality:, content:, confidence: 0.5, salience: 0.5, engine: nil, **)
            eng = engine || default_engine
            signal = eng.add_signal(modality: modality, content: content,
                                    confidence: confidence, salience: salience)
            { success: true, signal: signal.to_h }
          end

          def remove_signal(signal_id:, engine: nil, **)
            eng = engine || default_engine
            signal = eng.remove_signal(signal_id: signal_id)
            return { success: false, error: 'signal not found' } unless signal

            { success: true, removed: signal.to_h }
          end

          def integrate(signal_ids:, engine: nil, **)
            eng = engine || default_engine
            rep = eng.integrate(signal_ids: signal_ids)
            return { success: false, error: 'insufficient signals for binding' } unless rep

            { success: true, representation: rep.to_h }
          end

          def integrate_by_modalities(modalities:, engine: nil, **)
            eng = engine || default_engine
            rep = eng.integrate_by_modalities(modalities: modalities)
            return { success: false, error: 'insufficient matching signals' } unless rep

            { success: true, representation: rep.to_h }
          end

          def integrate_all_salient(engine: nil, **)
            eng = engine || default_engine
            rep = eng.integrate_all_salient
            return { success: false, error: 'insufficient salient signals' } unless rep

            { success: true, representation: rep.to_h }
          end

          def reinforce(representation_id:, engine: nil, **)
            eng = engine || default_engine
            rep = eng.reinforce(representation_id: representation_id)
            return { success: false, error: 'representation not found' } unless rep

            { success: true, representation: rep.to_h }
          end

          def disrupt(representation_id:, amount: nil, engine: nil, **)
            eng = engine || default_engine
            amt = amount || Helpers::Constants::CONFLICT_PENALTY
            rep = eng.disrupt(representation_id: representation_id, amount: amt)
            return { success: false, error: 'representation not found' } unless rep

            { success: true, representation: rep.to_h }
          end

          def decay(engine: nil, **)
            eng = engine || default_engine
            result = eng.decay_all!
            { success: true, **result }
          end

          def signals_by_modality(modality:, engine: nil, **)
            eng = engine || default_engine
            { success: true, signals: eng.signals_by_modality(modality: modality).map(&:to_h) }
          end

          def coherent_representations(engine: nil, **)
            eng = engine || default_engine
            { success: true, representations: eng.coherent_representations.map(&:to_h) }
          end

          def integration_report(engine: nil, **)
            eng = engine || default_engine
            { success: true, report: eng.integration_report }
          end

          def status(engine: nil, **)
            eng = engine || default_engine
            { success: true, **eng.to_h }
          end

          private

          def default_engine
            @default_engine ||= Helpers::IntegrationEngine.new
          end
        end
      end
    end
  end
end

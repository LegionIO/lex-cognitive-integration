# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveIntegration::Helpers::IntegrationEngine do
  subject(:engine) { described_class.new }

  let(:visual) { engine.add_signal(modality: :visual, content: 'face', confidence: 0.8, salience: 0.7) }
  let(:auditory) { engine.add_signal(modality: :auditory, content: 'voice', confidence: 0.7, salience: 0.6) }
  let(:emotional) { engine.add_signal(modality: :emotional, content: 'warmth', confidence: 0.9, salience: 0.8) }

  describe '#add_signal' do
    it 'creates a modal signal' do
      signal = engine.add_signal(modality: :visual, content: 'test')
      expect(signal).to be_a(Legion::Extensions::CognitiveIntegration::Helpers::ModalSignal)
    end

    it 'stores the signal' do
      signal = engine.add_signal(modality: :visual, content: 'stored')
      found = engine.signals_by_modality(modality: :visual)
      expect(found.map(&:id)).to include(signal.id)
    end
  end

  describe '#remove_signal' do
    it 'removes existing signal' do
      signal = engine.add_signal(modality: :visual, content: 'remove_me')
      engine.remove_signal(signal_id: signal.id)
      expect(engine.signals_by_modality(modality: :visual)).to be_empty
    end

    it 'returns nil for unknown signal' do
      expect(engine.remove_signal(signal_id: 'nonexistent')).to be_nil
    end
  end

  describe '#integrate' do
    it 'creates an integrated representation' do
      rep = engine.integrate(signal_ids: [visual.id, auditory.id])
      expect(rep).to be_a(Legion::Extensions::CognitiveIntegration::Helpers::IntegratedRepresentation)
    end

    it 'returns nil with insufficient signals' do
      expect(engine.integrate(signal_ids: [visual.id])).to be_nil
    end

    it 'returns nil with all invalid ids' do
      expect(engine.integrate(signal_ids: %w[bad1 bad2])).to be_nil
    end

    it 'creates multi-modal representation' do
      rep = engine.integrate(signal_ids: [visual.id, auditory.id, emotional.id])
      expect(rep.multi_modal?).to be true
      expect(rep.modal_count).to eq(3)
    end
  end

  describe '#integrate_by_modalities' do
    it 'integrates matching signals' do
      visual
      auditory
      rep = engine.integrate_by_modalities(modalities: %i[visual auditory])
      expect(rep).not_to be_nil
      expect(rep.modalities).to contain_exactly(:visual, :auditory)
    end

    it 'returns nil with insufficient matching signals' do
      visual
      expect(engine.integrate_by_modalities(modalities: [:auditory])).to be_nil
    end
  end

  describe '#integrate_all_salient' do
    it 'integrates salient signals' do
      visual
      emotional
      rep = engine.integrate_all_salient
      expect(rep).not_to be_nil
    end

    it 'returns nil with no salient signals' do
      engine.add_signal(modality: :visual, content: 'x', salience: 0.1)
      expect(engine.integrate_all_salient).to be_nil
    end
  end

  describe '#reinforce' do
    it 'increases binding strength' do
      rep = engine.integrate(signal_ids: [visual.id, auditory.id])
      original = rep.binding_strength
      engine.reinforce(representation_id: rep.id)
      expect(rep.binding_strength).to be > original
    end

    it 'returns nil for unknown representation' do
      expect(engine.reinforce(representation_id: 'bad')).to be_nil
    end
  end

  describe '#disrupt' do
    it 'decreases binding strength' do
      rep = engine.integrate(signal_ids: [visual.id, auditory.id])
      original = rep.binding_strength
      engine.disrupt(representation_id: rep.id)
      expect(rep.binding_strength).to be < original
    end
  end

  describe '#decay_all!' do
    it 'decays all representations' do
      rep = engine.integrate(signal_ids: [visual.id, auditory.id])
      original = rep.binding_strength
      engine.decay_all!
      expect(rep.binding_strength).to be < original
    end
  end

  describe '#signals_by_modality' do
    it 'returns signals matching the modality' do
      visual
      auditory
      found = engine.signals_by_modality(modality: :visual)
      expect(found.size).to eq(1)
      expect(found.first.modality).to eq(:visual)
    end
  end

  describe '#multi_modal_representations' do
    it 'returns only multi-modal representations' do
      engine.integrate(signal_ids: [visual.id, auditory.id])
      expect(engine.multi_modal_representations.size).to eq(1)
    end
  end

  describe '#coherent_representations' do
    it 'returns coherent representations' do
      engine.integrate(signal_ids: [visual.id, auditory.id])
      result = engine.coherent_representations
      expect(result).to be_an(Array)
    end
  end

  describe '#strongest_representations' do
    it 'returns representations sorted by binding strength' do
      rep1 = engine.integrate(signal_ids: [visual.id, auditory.id])
      engine.reinforce(representation_id: rep1.id)
      top = engine.strongest_representations(limit: 1)
      expect(top.first.id).to eq(rep1.id)
    end
  end

  describe '#average_binding_strength' do
    it 'returns default with no representations' do
      default = Legion::Extensions::CognitiveIntegration::Helpers::Constants::DEFAULT_BINDING_STRENGTH
      expect(engine.average_binding_strength).to eq(default)
    end

    it 'computes mean binding strength' do
      engine.integrate(signal_ids: [visual.id, auditory.id])
      expect(engine.average_binding_strength).to be > 0
    end
  end

  describe '#modality_coverage' do
    it 'returns unique modalities across all signals' do
      visual
      auditory
      expect(engine.modality_coverage).to contain_exactly(:visual, :auditory)
    end
  end

  describe '#integration_report' do
    it 'returns comprehensive report' do
      engine.integrate(signal_ids: [visual.id, auditory.id])
      report = engine.integration_report
      expect(report).to include(
        :total_signals, :total_representations, :multi_modal_count,
        :coherent_count, :fragmented_count, :average_binding_strength,
        :average_coherence, :modality_coverage, :strongest
      )
    end
  end

  describe '#to_h' do
    it 'returns summary hash' do
      hash = engine.to_h
      expect(hash).to include(
        :total_signals, :total_representations, :multi_modal_count,
        :coherent_count, :average_binding_strength, :average_coherence
      )
    end
  end
end

# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveIntegration::Helpers::IntegratedRepresentation do
  let(:visual) do
    Legion::Extensions::CognitiveIntegration::Helpers::ModalSignal.new(
      modality: :visual, content: 'face', confidence: 0.8, salience: 0.7
    )
  end
  let(:auditory) do
    Legion::Extensions::CognitiveIntegration::Helpers::ModalSignal.new(
      modality: :auditory, content: 'voice', confidence: 0.7, salience: 0.6
    )
  end
  let(:emotional) do
    Legion::Extensions::CognitiveIntegration::Helpers::ModalSignal.new(
      modality: :emotional, content: 'warmth', confidence: 0.9, salience: 0.8
    )
  end

  subject(:rep) { described_class.new(signals: [visual, auditory]) }

  describe '#initialize' do
    it 'assigns a UUID id' do
      expect(rep.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'captures signal ids' do
      expect(rep.signal_ids).to contain_exactly(visual.id, auditory.id)
    end

    it 'captures unique modalities' do
      expect(rep.modalities).to contain_exactly(:visual, :auditory)
    end

    it 'computes initial binding strength' do
      expect(rep.binding_strength).to be_between(0.0, 1.0)
    end

    it 'computes initial coherence' do
      expect(rep.coherence).to be_between(0.0, 1.0)
    end
  end

  describe '#reinforce!' do
    it 'increases binding strength' do
      original = rep.binding_strength
      rep.reinforce!
      expect(rep.binding_strength).to be > original
    end

    it 'returns self' do
      expect(rep.reinforce!).to eq(rep)
    end

    it 'clamps at 1.0' do
      15.times { rep.reinforce! }
      expect(rep.binding_strength).to eq(1.0)
    end
  end

  describe '#decay!' do
    it 'decreases binding strength' do
      original = rep.binding_strength
      rep.decay!
      expect(rep.binding_strength).to be < original
    end
  end

  describe '#disrupt!' do
    it 'decreases binding strength' do
      original = rep.binding_strength
      rep.disrupt!
      expect(rep.binding_strength).to be < original
    end

    it 'decreases coherence' do
      original = rep.coherence
      rep.disrupt!
      expect(rep.coherence).to be < original
    end
  end

  describe '#multi_modal?' do
    it 'is true for multiple modalities' do
      expect(rep.multi_modal?).to be true
    end

    it 'is false for single modality' do
      visual2 = Legion::Extensions::CognitiveIntegration::Helpers::ModalSignal.new(
        modality: :visual, content: 'color', confidence: 0.8
      )
      single = described_class.new(signals: [visual, visual2])
      expect(single.multi_modal?).to be false
    end
  end

  describe '#modal_count' do
    it 'returns number of unique modalities' do
      tri = described_class.new(signals: [visual, auditory, emotional])
      expect(tri.modal_count).to eq(3)
    end
  end

  describe '#coherent?' do
    it 'returns boolean based on coherence threshold' do
      expect(rep.coherent?).to be(true).or be(false)
    end
  end

  describe '#fragmented?' do
    it 'returns boolean' do
      expect(rep.fragmented?).to be(true).or be(false)
    end
  end

  describe '#binding_label' do
    it 'returns a symbol' do
      expect(rep.binding_label).to be_a(Symbol)
    end
  end

  describe '#quality_label' do
    it 'returns a symbol' do
      expect(rep.quality_label).to be_a(Symbol)
    end
  end

  describe '#quality_score' do
    it 'is between 0 and 1' do
      expect(rep.quality_score).to be_between(0.0, 1.0)
    end

    it 'combines binding and coherence' do
      expect(rep.quality_score).to be > 0
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      hash = rep.to_h
      expect(hash).to include(
        :id, :signal_ids, :modalities, :modal_count, :multi_modal,
        :binding_strength, :binding_label, :coherence, :coherent,
        :fragmented, :quality_score, :quality_label,
        :reinforcement_count, :created_at
      )
    end
  end
end

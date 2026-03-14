# frozen_string_literal: true

RSpec.describe Legion::Extensions::CognitiveIntegration::Helpers::ModalSignal do
  subject(:signal) { described_class.new(modality: :visual, content: 'red circle') }

  describe '#initialize' do
    it 'assigns a UUID id' do
      expect(signal.id).to match(/\A[0-9a-f-]{36}\z/)
    end

    it 'sets modality' do
      expect(signal.modality).to eq(:visual)
    end

    it 'sets content' do
      expect(signal.content).to eq('red circle')
    end

    it 'defaults confidence to 0.5' do
      expect(signal.confidence).to eq(0.5)
    end

    it 'defaults salience to 0.5' do
      expect(signal.salience).to eq(0.5)
    end

    it 'clamps high confidence' do
      high = described_class.new(modality: :visual, content: 'x', confidence: 2.0)
      expect(high.confidence).to eq(1.0)
    end
  end

  describe '#effective_weight' do
    it 'multiplies confidence by salience' do
      expect(signal.effective_weight).to eq(0.25)
    end

    it 'is higher with high confidence and salience' do
      high = described_class.new(modality: :visual, content: 'x', confidence: 0.9, salience: 0.9)
      expect(high.effective_weight).to eq(0.81)
    end
  end

  describe '#salient?' do
    it 'is false at default salience' do
      expect(signal.salient?).to be false
    end

    it 'is true with high salience' do
      high = described_class.new(modality: :visual, content: 'x', salience: 0.8)
      expect(high.salient?).to be true
    end
  end

  describe '#confident?' do
    it 'is false at default confidence' do
      expect(signal.confident?).to be false
    end

    it 'is true with high confidence' do
      high = described_class.new(modality: :visual, content: 'x', confidence: 0.8)
      expect(high.confident?).to be true
    end
  end

  describe '#confidence_label' do
    it 'returns a symbol' do
      expect(signal.confidence_label).to be_a(Symbol)
    end
  end

  describe '#to_h' do
    it 'includes all fields' do
      hash = signal.to_h
      expect(hash).to include(
        :id, :modality, :content, :confidence, :confidence_label,
        :salience, :effective_weight, :salient, :created_at
      )
    end
  end
end

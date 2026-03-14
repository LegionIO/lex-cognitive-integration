# lex-cognitive-integration

Multi-modal cognitive binding engine for brain-modeled agentic AI in the LegionIO ecosystem.

## What It Does

Models the binding of signals from different cognitive modalities (visual, auditory, semantic, proprioceptive, interoceptive, temporal, spatial, emotional, linguistic) into coherent integrated representations. Signals are registered individually; integration binds a set of them into a unified representation with a binding strength. Representations above 0.6 binding strength are considered coherent; below 0.3 they are fragmented. Passive decay reduces binding strength. Active reinforcement or disruption adjusts representations after formation.

## Usage

```ruby
require 'legion/extensions/cognitive_integration'

client = Legion::Extensions::CognitiveIntegration::Client.new

# Register signals from different modalities
visual = client.add_signal(modality: :visual, content: 'diagram of system architecture', domain: :engineering, quality: 0.8)
semantic = client.add_signal(modality: :semantic, content: 'microservice decomposition pattern', domain: :engineering, quality: 0.9)

# Bind them into an integrated representation
result = client.integrate(
  signal_ids: [visual[:signal_id], semantic[:signal_id]],
  binding_strength: 0.65
)
rep_id = result[:representation_id]

# Reinforce the binding
client.reinforce(representation_id: rep_id, amount: 0.1)
# => { success: true, binding_strength: 0.75 }

# Auto-integrate all high-quality signals
client.integrate_all_salient(quality_threshold: 0.7)

# Find coherent representations
client.coherent_representations(limit: 10)

# Status
client.status
# => { success: true, report: { signal_count: 2, representation_count: 2, ... } }
```

## Development

```bash
bundle install
bundle exec rspec
bundle exec rubocop
```

## License

MIT

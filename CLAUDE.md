# lex-cognitive-integration

**Level 3 Leaf Documentation**
- **Parent**: `/Users/miverso2/rubymine/legion/extensions-agentic/CLAUDE.md`
- **Gem**: `lex-cognitive-integration`

## Purpose

Models multi-modal cognitive binding — the process of unifying signals from different modalities (visual, auditory, semantic, proprioceptive, etc.) into coherent integrated representations. Signals are registered with a modality type. Integration binds a set of signals into an IntegratedRepresentation with a binding strength. Representations above the coherent threshold are considered stable; below the fragmented threshold they are degraded. Passive decay reduces binding strength over time. Disruption forcibly degrades a representation.

## Gem Info

| Field | Value |
|---|---|
| Gem name | `lex-cognitive-integration` |
| Version | `0.1.0` |
| Namespace | `Legion::Extensions::CognitiveIntegration` |
| Ruby | `>= 3.4` |
| License | MIT |
| GitHub | https://github.com/LegionIO/lex-cognitive-integration |

## File Structure

```
lib/legion/extensions/cognitive_integration/
  cognitive_integration.rb          # Top-level require
  version.rb                        # VERSION = '0.1.0'
  client.rb                         # Client class
  helpers/
    constants.rb                    # Modalities, binding thresholds, decay rate, binding/confidence/quality labels
    modal_signal.rb                 # ModalSignal value object
    integrated_representation.rb    # IntegratedRepresentation value object
    integration_engine.rb           # Engine: signals, representations, bind, decay, coherence
  runners/
    cognitive_integration.rb        # Runner module
```

## Key Constants

| Constant | Value | Meaning |
|---|---|---|
| `MAX_SIGNALS` | 500 | Signal store cap |
| `MAX_REPRESENTATIONS` | 200 | Representation cap |
| `MIN_SIGNALS_FOR_BINDING` | 2 | Minimum signals required to create a representation |
| `MODALITIES` | array | `[:visual, :auditory, :semantic, :proprioceptive, :interoceptive, :temporal, :spatial, :emotional, :linguistic]` |
| `DEFAULT_BINDING_STRENGTH` | 0.5 | Starting binding strength for new representations |
| `BINDING_DECAY_RATE` | 0.03 | Binding strength decrease per decay call |
| `COHERENT_THRESHOLD` | 0.6 | Binding strength above this = coherent |
| `FRAGMENTED_THRESHOLD` | 0.3 | Binding strength below this = fragmented |
| `BINDING_LABELS` | hash | `bound` (0.8+) through `unbound` |
| `CONFIDENCE_LABELS` | hash | Labels for representation confidence |
| `QUALITY_LABELS` | hash | Labels for signal quality |

## Helpers

### `ModalSignal`

A single-modality cognitive input.

- `initialize(modality:, content:, domain:, quality: 0.5, signal_id: nil)`
- `quality`, `modality`, `domain`
- `to_h`

### `IntegratedRepresentation`

A multi-modal binding of several signals.

- `initialize(signal_ids:, binding_strength: DEFAULT_BINDING_STRENGTH, representation_id: nil)`
- `reinforce!(amount)` — increases binding_strength, cap 1.0
- `disrupt!(amount)` — decreases binding_strength, floor 0.0
- `decay!(rate)` — decreases binding_strength by `BINDING_DECAY_RATE`
- `coherent?` — binding_strength >= `COHERENT_THRESHOLD`
- `fragmented?` — binding_strength < `FRAGMENTED_THRESHOLD`
- `binding_label`
- `to_h`

### `IntegrationEngine`

- `add_signal(modality:, content:, domain:, quality: 0.5)` — returns `{ added:, signal_id:, signal: }` or capacity error
- `remove_signal(signal_id:)` — removes from signal store
- `integrate(signal_ids:, binding_strength: DEFAULT_BINDING_STRENGTH)` — requires >= MIN_SIGNALS_FOR_BINDING; creates IntegratedRepresentation; returns `{ integrated:, representation_id:, representation: }`
- `integrate_by_modalities(modalities:)` — integrates all signals matching given modality list
- `integrate_all_salient(quality_threshold: 0.6)` — auto-integrates all signals above quality threshold
- `reinforce(representation_id:, amount: 0.1)` — strengthens binding
- `disrupt(representation_id:, amount: 0.1)` — weakens binding
- `decay_all!(rate: BINDING_DECAY_RATE)` — decays all representations
- `coherent_representations(limit: 20)` — filtered and sorted
- `fragmented_representations(limit: 20)` — filtered and sorted
- `signals_by_modality` — hash of modality -> signal array
- `integration_report` — full stats

## Runners

**Module**: `Legion::Extensions::CognitiveIntegration::Runners::CognitiveIntegration`

| Method | Key Args | Returns |
|---|---|---|
| `add_signal` | `modality:`, `content:`, `domain:`, `quality: 0.5` | `{ success:, signal_id:, signal: }` |
| `remove_signal` | `signal_id:` | `{ success:, removed: }` |
| `integrate` | `signal_ids:`, `binding_strength: DEFAULT_BINDING_STRENGTH` | `{ success:, representation_id:, representation: }` |
| `integrate_by_modalities` | `modalities:` | `{ success:, representation_id:, representation: }` |
| `integrate_all_salient` | `quality_threshold: 0.6` | `{ success:, representations: [...] }` |
| `reinforce` | `representation_id:`, `amount: 0.1` | `{ success:, binding_strength: }` |
| `disrupt` | `representation_id:`, `amount: 0.1` | `{ success:, binding_strength: }` |
| `decay` | — | `{ success:, decayed: N }` |
| `signals_by_modality` | — | `{ success:, modalities: }` |
| `coherent_representations` | `limit: 20` | `{ success:, representations: }` |
| `integration_report` | — | Full report hash |
| `status` | — | `{ success:, report: }` |

Private: `integration_engine` — memoized `IntegrationEngine`. Logs via `log_debug` helper.

## Integration Points

- **`lex-memory`**: Coherent integrated representations are prime candidates for memory trace storage. Fragmented representations could be stored at lower strength. `lex-memory`'s Hebbian linking can strengthen associations between signals that appear together in the same representation.
- **`lex-cognitive-hologram`**: Hologram reconstruction assembles fragments into a whole; integration binds multi-modal signals into a unified representation. Both model the process of assembling coherent wholes from parts.
- **`lex-emotion`**: Emotional signals (`:emotional` modality) can be integrated alongside semantic and linguistic signals to produce affectively grounded representations. `lex-emotion`'s valence can influence binding quality.

## Development Notes

- `integrate` requires at least `MIN_SIGNALS_FOR_BINDING` (2) signal IDs. Passing a single signal returns an error.
- `integrate_all_salient` groups signals by domain and integrates each domain's high-quality signals independently. This can produce many representations in one call.
- `decay_all!` operates on all representations regardless of coherence state. Coherent representations can decay into the fragmented range over time without periodic `reinforce` calls.
- In-memory only.

---

**Maintained By**: Matthew Iverson (@Esity)

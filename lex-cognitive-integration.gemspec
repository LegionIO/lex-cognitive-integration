# frozen_string_literal: true

require_relative 'lib/legion/extensions/cognitive_integration/version'

Gem::Specification.new do |spec|
  spec.name          = 'lex-cognitive-integration'
  spec.version       = Legion::Extensions::CognitiveIntegration::VERSION
  spec.authors       = ['Esity']
  spec.email         = ['matthewdiverson@gmail.com']

  spec.summary       = 'Cross-modal cognitive integration for LegionIO'
  spec.description   = 'Models convergence zones that bind information from different cognitive modalities ' \
                       'into unified multi-modal representations with binding strength and coherence tracking.'
  spec.homepage      = 'https://github.com/LegionIO/lex-cognitive-integration'
  spec.license       = 'MIT'

  spec.required_ruby_version = '>= 3.4'

  spec.metadata['homepage_uri']      = spec.homepage
  spec.metadata['source_code_uri']   = 'https://github.com/LegionIO/lex-cognitive-integration'
  spec.metadata['documentation_uri'] = 'https://github.com/LegionIO/lex-cognitive-integration/blob/master/README.md'
  spec.metadata['changelog_uri']     = 'https://github.com/LegionIO/lex-cognitive-integration/blob/master/CHANGELOG.md'
  spec.metadata['bug_tracker_uri']   = 'https://github.com/LegionIO/lex-cognitive-integration/issues'
  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.files = Dir.chdir(__dir__) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{\A(?:test|spec|features)/}) }
  end
  spec.require_paths = ['lib']
  spec.add_development_dependency 'legion-gaia'
end

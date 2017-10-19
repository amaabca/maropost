# frozen_string_literal: true

module Helpers
  module Fixtures
    PATH = File.join(
      Gem.loaded_specs['maropost'].full_gem_path,
      'spec',
      'fixtures'
    ).freeze

    def read_fixture(*path)
      File.read(File.join(PATH, *path)).gsub(/\s+/, '')
    end
  end
end

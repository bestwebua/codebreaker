require 'yaml'

module Codebreaker
  module Storage
    attr_reader :storage_path

    private

    def apply_external_path(external_path = false)
      yml_file = 'scores.yml'
      if external_path && !Dir.exist?(external_path)
        raise ArgumentError, 'Invalid external path.'
      end
      @storage_path =
      if external_path
        "#{external_path}/#{yml_file}"
      else
        File.expand_path("./data/#{yml_file}", File.dirname(__FILE__))
      end
    end

    def load_game_data
      YAML.load(File.open(storage_path, 'r')) rescue []
    end

    def prepare_storage_dir
      storage_dir = File.dirname(storage_path)
      Dir.mkdir(storage_dir) unless File.exist?(storage_dir)
    end

    def save_to_yml
      scores_to_save = scores | load_game_data
      File.open(storage_path, 'w') do |file|
        file.write(YAML.dump(scores_to_save))
      end
    end

    def erase_data_file
      File.delete(storage_path)
    end
  end
end

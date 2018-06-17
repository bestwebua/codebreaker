require 'yaml'

module Codebreaker
  module Storage
    private
    def load_game_data
      YAML.load(File.open(storage_path, 'r')) rescue []
    end

    def prepare_storage_dir
      storage_dir = File.dirname(storage_path)
      Dir.mkdir(storage_dir) unless File.exists?(storage_dir)
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

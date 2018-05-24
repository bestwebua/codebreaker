require 'yaml'

module Codebreaker
  class Localization
    attr_accessor :lang

    def initialize(app_type, lang = :en)
      @lang = lang
      select_application(app_type)
      candidates_to_load
      merge_localizations
    end

    def localization
      return localizations[:en] unless localizations[lang]
      localizations[lang]
    end

    private

    def select_application(app_type)
      raise 'Unknown application type.' unless %i[console game].include?(app_type)
      @app_dir = app_type.to_s
    end

    def candidates_to_load
      app_root = "#{File.expand_path(File.dirname(__FILE__))}"
      @ymls_paths = Dir.glob("#{app_root}/locale/#{@app_dir.to_s}/*.yml")
    end

    def localizations
      @localizations ||= Hash.new
    end

    def merge_localizations
      localizations
      loaded_ymls = @ymls_paths.map { |file| YAML.load(File.open(file, 'r')) }
      loaded_ymls.each { |loaded_yml| @localizations.update(loaded_yml) }
    end
  end
end

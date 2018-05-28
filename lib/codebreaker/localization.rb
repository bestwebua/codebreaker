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

    def localizations_dir
      File.expand_path('./locale/.', File.dirname(__FILE__))
    end

    def authorized_apps
      Dir.entries(localizations_dir).reject { |dir_name| dir_name.include?('.') }.map(&:to_sym)
    end

    def select_application(app_type)
      raise 'Unknown application type.' unless authorized_apps.include?(app_type)
      @app_dir = app_type.to_s
    end

    def candidates_to_load
      @ymls_paths = Dir.glob("#{localizations_dir}/#{@app_dir}/*.yml")
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

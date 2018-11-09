require 'spec_helper'

module Codebreaker
  RSpec.describe Localization do
    before(:context) do
      copied_dirs, dirname_pattern = [], %r{.+\/(.+)\z}

      locales_dir = File.expand_path('../../lib/codebreaker/locale', File.dirname(__FILE__)).to_s
      test_locales_dir = File.expand_path('./test_locale/.', File.dirname(__FILE__)).to_s

      Dir.glob("#{test_locales_dir}/*").each do |dir|
        FileUtils.cp_r(dir, locales_dir)
        copied_dirs << dir
      end

      copied_dirs.map! { |dir| dir[/#{dirname_pattern}/,1]  }

      @dirs_to_del = Dir.glob("#{locales_dir}/*").select do |file|
        copied_dirs.include?(file[/#{dirname_pattern}/,1])
      end
    end

    after(:context) do
      @dirs_to_del.each do |dir|
        FileUtils.remove_dir(dir)
      end
    end

    let(:localization)       { Localization.new(:test_app) }
    let(:localization_wrong) { Localization.new(:test_app, false, :eg) }

    describe '#new' do
      describe '#initialize' do
        describe 'without args' do
          specify { expect { subject }.to raise_error(ArgumentError) }
        end

        describe 'with args' do
          describe '1 argument' do
            context 'wrong app type' do
              let(:local_wrong_app) { Localization.new(:wrong_type) }

              specify { expect { local_wrong_app }.to raise_error(RuntimeError, 'Unknown application type.') }
            end

            context 'right app type' do
              specify { expect(localization).to be_an_instance_of(Localization) }
            end
          end

          describe '2 arguments' do
            let(:external_localization) { Localization.new(:test_app, external_path) }

            context 'right external path' do
              let(:external_path) { File.expand_path('./test_locale/.', File.dirname(__FILE__)).to_s }

              specify { expect(external_localization).to be_an_instance_of(Localization) }
            end

            context 'wrong external path' do
              let(:external_path) { 'some_cool_path' }

              specify { expect { external_localization }.to raise_error(ArgumentError, 'Invalid external path.') }
            end
          end

          describe '3 arguments' do
            context 'when wrong app type' do
              let(:local_wrong_app) { Localization.new(:wrong_type, false, :ru) }

              specify { expect { local_wrong_app }.to raise_error(RuntimeError, 'Unknown application type.') }
            end

            context 'when wrong lang' do
              specify { expect(localization_wrong).to be_an_instance_of(Localization) }
            end
          end
        end
      end

      describe '#select_application' do
        context 'create instance var with app type' do
          specify { expect(localization.instance_variable_get(:@app_dir)).to eq('test_app') }
        end
      end

      describe '#candidates_to_load' do
        context 'create instance var with file list' do
          specify { expect(localization.instance_variable_get(:@ymls_paths)).to be_an_instance_of(Array) }
        end
      end

      describe '#merge_localizations' do
        context 'create instance var with localizations' do
          specify { expect(localization.instance_variable_get(:@localizations)).to be_an_instance_of(Hash) }
        end
      end
    end

    describe '#localization' do
      context 'returns default localization if no localization found' do
        let(:default_localization) { localization_wrong.instance_variable_get(:@localizations)[:en] }

        specify { expect(localization_wrong.localization).to be_an_instance_of(Hash) }

        it 'equal english localization' do
          expect(localization_wrong.localization).to eq(default_localization)
        end
      end

      context 'returns the requested localization if found' do
        let(:localization_ru)        { Localization.new(:test_app, false, :ru) }
        let(:requested_localization) { localization_ru.instance_variable_get(:@localizations)[:ru] }

        it 'equal requested localization' do
          expect(localization_ru.localization).to eq(requested_localization)
        end
      end
    end

    describe '#all' do
      specify { expect(localization.all).to be_an_instance_of(Array) }
      specify { expect(localization.all).to include(:en, :ru) }
    end

    describe '#lang' do
      context 'when language was not passed' do
        specify { expect(localization.lang).to eq(:en) }
      end

      context 'can be changed' do
        specify { expect(localization.lang = :ru).to eq(:ru) }
      end
    end

    describe 'test_app localization' do
      context 'English' do
        specify { expect(localization.localization['info']).to eq('English localization of test app.') }
      end

      context 'Russian' do
        before { localization.lang = :ru }
        specify { expect(localization.localization['info']).to eq('Русская локализация тестового приложения.') }
      end
    end
  end
end

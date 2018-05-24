require 'spec_helper'

module Codebreaker
  RSpec.describe Localization do
    let(:localization) { Localization.new(:game) }

    describe '#new' do
      describe '#initialize' do
        describe 'without args' do
          specify { expect { subject }.to raise_error(ArgumentError) }
        end

        describe 'with args' do
          describe '1 argument' do
            context 'when wrong app type' do
              let(:local_wrong_app) { Localization.new(:wrong_type) }
              specify { expect { local_wrong_app }.to raise_error(RuntimeError, 'Unknown application type.') }
            end
            
            context 'when right app type' do
              specify { expect(localization).to be_an_instance_of(Localization) }
            end
          end

          describe '2 arguments' do
            context 'when wrong app type' do
              let(:local_wrong_app) { Localization.new(:wrong_type, :ru) }
              specify { expect { local_wrong_app }.to raise_error(RuntimeError, 'Unknown application type.') }
            end

            context 'when wrong lang' do
              let(:local_wrong_lang) { Localization.new(:console, :eg) }
              specify { expect(local_wrong_lang).to be_an_instance_of(Localization) }
            end
          end
        end
      end

      describe '#select_application' do
        context 'should create instance var with app type' do
          specify { expect(localization.instance_variable_get(:@app_dir)).to eq('game') }
        end
      end

      describe '#candidates_to_load' do
        context 'should create instance var with file list' do
          specify { expect(localization.instance_variable_get(:@ymls_paths)).to be_an_instance_of(Array) }
        end
      end
    end

    describe '#localization' do
      it 'localization selector'
    end
  end
end
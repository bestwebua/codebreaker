require 'spec_helper'

module Codebreaker
  RSpec.describe Score do
    describe '#initialize' do
      context 'new object' do
        it 'be child of Struct' do
          expect(subject.class.superclass).to eq(Struct)
        end
      end

      context 'when block passed' do
        let(:with_block) do
          Score.new do |object|
            object.date = :a
            object.player_name = :b
            object.winner = :c
            object.level = :d
            object.score = :e
          end
        end

        it 'all passed values should be established' do
          expect(with_block.values).to eq(%i[a b c d e])
        end
      end
    end
  end
end

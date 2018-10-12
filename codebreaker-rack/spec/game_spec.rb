require_relative "spec_helper"

module Codebreaker_garage
  RSpec.describe Game do

    describe '#initialize' do
      it 'generates secret code' do
        expect(subject.instance_variable_get(:@generated_code)).not_to be_empty
      end

      it 'saves secret code with digits from 1 to 6' do
        expect(subject.instance_variable_get(:@generated_code)).to match([1..6, 1..6, 1..6, 1..6])
      end
    end

    describe '#has_attempts?' do
      it 'checks if attemts are left' do
        subject.instance_variable_set(:@attempts, 0)
        expect(subject.has_attempts?).to eq(false)
      end
    end

    describe '#statistics' do
      it 'it returns the statistics of game' do
        expect(subject.statistics).to be_kind_of(Hash)
        expect(subject.statistics[:secret_code]).to match(/[1-6]+/)
        expect(subject.statistics[:attempts]).to eq(9)
        expect(subject.statistics[:hints]).to eq(3)
        expect(subject.statistics[:user_attempts_left]).to match(0..9)
        expect(subject.statistics[:user_hints_left]).to match(0..3)
      end
    end

    describe '#hint' do
      it 'returns warning message if there are no hints' do
        subject.instance_variable_set(:@hints, 0)
        expect(subject.receive_hint).to eq("You have no hints.")
      end

      it 'if hint is used, quantity of hints declines' do
        expect { subject.receive_hint }.to change{ subject.hints }.by(-1)
      end

      it 'shows a random digit from generated code' do
        expect(subject.instance_variable_get(:@generated_code)).to include(subject.receive_hint)
      end

    end

    describe "#generate_code" do
      it 'returns 4 digits' do
        expect(subject.send(:generate_code).length).to eq(4)
      end
    end

    describe "#guesser" do
      let(:game) {Game.new}
      [
        [[1,2,3,4], [1,2,3,4], '++++'], [[5,1,4,3], [4,1,5,3], '++--'], [[5,5,2,3], [5,1,5,5], '+-'],
        [[6,2,3,5], [2,3,6,5], '+---'], [[1,2,2,1], [2,1,1,2], '----'], [[1,2,3,4], [1,2,3,5], '+++'],
        [[1,2,3,4], [6,2,5,4], '++'], [[1,2,3,4], [4,4,4,4], '+'], [[1,2,3,4], [4,3,2,6], '---'],
        [[1,2,3,4], [3,5,2,5], '--'], [[1,2,3,4], [2,5,5,2], '-'], [[1,2,3,4], [4,2,5,5], '+-'],
        [[1,2,3,4], [1,5,2,4], '++-'], [[1,2,3,4], [5,4,3,1], '+--'], [[1,2,3,4], [6,6,6,6], ''],
        [[1,1,1,5], [1,2,3,1], '+-'], [[1,2,3,1], [1,1,1,1], '++']
      ].each do |item|
        it "Secret code is #{item[0]}, guessed is #{item[1]}, have to return #{item[2]}" do
          subject.instance_variable_set(:@generated_code, item[0])
          expect(subject.guesser(item[1])).to eq(item[2])
        end
      end

      it 'if attempt is used, quantity of attempts declines' do
        subject.instance_variable_set(:@generated_code, [1,2,3,4])
        expect { subject.guesser([4,3,2,1]) }.to change{ subject.attempts }.by(-1)
      end

    end

  end
end

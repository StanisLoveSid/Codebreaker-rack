require 'spec_helper'

APP = Rack::Builder.parse_file('config.ru').first

module Codebreaker_garage

  RSpec.describe Racker do

    include Rack::Test::Methods

    def app
      APP
    end

    def session
      last_request.env['rack.session']
    end

    it 'says that page is not found' do
      get '/page3000'
      expect(last_response.status).to eql(404)
    end

    before { get '/' }

    context "/ requests" do
      it 'returns successful response' do
        expect(last_response.status).to eql(200)
      end

      it 'shows index page' do
        expect(last_response.body).to include('Welcome to codebreaker')
      end

      it 'creates new session' do
        expect(session).to include(:game)
      end
    end

    context "'/start' requests" do
      context 'user entered the name' do
        before { get '/start' }

        it 'returns 200 response' do
          expect(last_response.status).to eql(200)
        end

        it 'shows index page' do
          expect(last_response.body).to include('Make a guess.')
        end
      end

      context "/make_guess request" do
        it 'returns 302 response' do
          get '/make_guess'
          expect(last_response.status).to eql(302)
        end

        it 'calls guesser' do
          expect(session[:game]).to receive(:guesser)
          get '/make_guess'
        end
      end

      context "hint request" do
        it 'shows hint' do
          expect(session[:game]).to receive(:hint)
        end
      end

      context "/game_over" do

        before { allow_any_instance_of(Codebreaker_garage::Game).to receive(:win) { true } }

        it ' if user has won, returns 200 response' do
          get '/game_over'
          expect(last_response.status).to eql(200)
        end

        it 'shows game_over page' do
          get '/game_over'
          expect(last_response.body).to include('Your score is')
        end

        it 'if user has lost, returns 200 response ' do
          allow_any_instance_of(Codebreaker_garage::Game).to receive(:win) { false }
          session[:game].instance_variable_set(:@attempts, 0)
          get '/game_over'
          expect(last_response.status).to eql(200)
        end
      end

      context '/save_score' do
        it 'saves scores' do
          session[:username].instance_variable_get("name")
          expect(session[:game]).to receive(:save)
          expect(YAML).to receive(:dump)
          get '/start'
        end
      end

      context 'score_table' do
        before { get '/score_table' }

        it 'returns successful response' do
          expect(last_response.status).to eql(200)
        end

        it 'shows score_table page' do
          expect(last_response.body).to include('Name Victory Attempts Hints')
        end

        it 'loads scores' do
          expect(YAML).to receive(:load_stream)
        end

      end

    end
  end
end

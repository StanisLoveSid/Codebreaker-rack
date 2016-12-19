$LOAD_PATH << File.dirname(__FILE__)
require 'erb'
require 'game'
require 'yaml'
require 'psych'

class Racker
  include Codebreaker_garage

  def self.call(env)
    new(env).response.finish
  end

  def initialize(env)
    @request = Rack::Request.new(env)
  end

  def response
    case @request.path
    when "/" then Rack::Response.new(render("index.html.erb"))
    when "/start" then game_start
    when "/make_guess"  then make_guess
    when "/save_score" then save_score
    when "/game_over" then game_over
    when "/score_table" then Rack::Response.new(render("score_table.html.erb"))
    else
      Rack::Response.new("Not Found", 404)
    end
  end

  def game_start
    @request.session.clear
    @request.session[:game] = Game.new
    @request.session[:game].start
    redirect_to('/')
  end

  def game_over
    Rack::Response.new(render("game_over.html.erb"))
  end

  def make_guess
    if game.attempts > 0
      if (@request.params['guess'] == 'hint') && (game.hints > 0)
        @request.session[:hint] = game.hint
      else
        @request.session[:guess] = @request.params['guess']
        @request.session[:mark] = game.guesser(guess)
      end
      game.win ? redirect_to('/game_over') : redirect_to('/')
    else
      redirect_to('/game_over')
    end
  end

  def game
    @request.session[:game]
  end

  def guess
    @request.session[:guess]
  end

  def mark
    @request.session[:mark]
  end

  def hint
    @request.session[:hint]
  end

  def hints_left
    Game::HINTS - game.hints
  end

  def attempts_left
    Game::ATTEMPTS - game.attempts
  end

  def save_score
    username = @request.params['username']
    @request.session[:username] = username
    save(game.statistics(username))
    redirect_to('/start')
  end

  def render(template)
    path = File.expand_path("../../views/#{template}", __FILE__)
    ERB.new(File.read(path)).result(binding)
  end

  private

  def save(data)
    File.open("score.yml", "a") { |file| file << data.to_yaml }
  end

  def load(filename)
    Psych.load_stream(File.read(filename))
  end

  def redirect_to(path)
    Rack::Response.new { |response| response.redirect(path) }
  end

end

module Codebreaker_garage
  class Game
    attr_accessor :attempts, :win, :generated_code, :hints

    HINTS = 3
    ATTEMPTS = 9

    def initialize
      @generated_code = []
      @attempts = ATTEMPTS
      @hints = HINTS
      @win = false
    end

    def start
      @generated_code = (1..4).map { rand(1..6) }
    end

    def guesser(guessed_code)
      return "You have to use 4 digits from range 1..6" if (guessed_code == "") || !guessed_code.match(/^[1-6]{4}$/)
      @attempts -= 1
      converted = guessed_code.split('').map(&:to_i)
      result = ""
      if @generated_code == converted
        @win = true
        return "++++"
      end
      associative_array = @generated_code.zip(converted)
      associative_array.each do |array|
        next unless array[0] == array[1]
        result << "+"
        array[0] = array[1] = nil
      end
      not_exact_match(associative_array, result)
    end

    def not_exact_match(associative_array, result)
      associative_array.reject! {|element| element == [nil, nil]}
      transposed = associative_array.transpose
      transposed[0].each do |digit|
        next unless transposed[1].include?(digit)
        result << '-'
        transposed[1][transposed[1].find_index(digit)] = nil
      end
      result
    end

    def hint
      @hints -= 1
      machine_codebreaker = (1..6).to_a
      hint = machine_codebreaker.repeated_permutation(4).to_a
      hint.select! {|code| code == @generated_code }
      hint.flatten![rand(4)]
    end

    def statistics(username)
      {
        name: username,
        victory: @win,
        user_attempts_left: ATTEMPTS - @attempts,
        user_hints_left: HINTS - @hints,
        time: Time.now,
        secret_code: @generated_code.to_s
      }
    end

  end
end

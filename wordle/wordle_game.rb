require 'httparty'

class WordleGame
    GREEN_FONT = "\e[32m"  
    YELLOW_FONT = "\e[33m" 
    RED_FONT = "\e[31m"
    BLUE_FONT = "\e[34m"
    MAGENTA_FONT = "\e[95m"  
    BOLD_FONT = "\e[1m"  
    RESET_FONT_COLOR = "\e[0m"
    SPELL_CHECK_URL = "https://api.languagetoolplus.com/v2/check"
    HINT_URL = "https://api.dictionaryapi.dev/api/v2/entries/en/"

    def initialize
        @word_list = ["apple", "brick", "charm", "clown", "dream", "eagle", "frame", "grape", "heart", "laugh", "maple", "niche", "olive", "peach", "quilt", "robot", "smile", "tiger", "unity", "video", "watch", "zebra", "blaze", "chair", "dance", "equid", "foggy", "ghost", "honey", "ideal", "joint", "knife", "lemon", "merry", "night", "ocean", "plant", "quick", "raini", "shine", "train", "urban", "vouch", "waste", "yield", "ample", "berry", "clean", "drive", "event", "faith", "great", "honor", "image", "jolly", "knock", "learn", "metal", "noble", "other", "power", "quiet", "royal", "stone", "taste", "upper", "visit", "world", "yield", "angel", "boast", "chase", "equal", "fancy", "genre", "happy", "index", "joker", "kites", "lemon", "model", "nicey", "onyx", "place", "quiet", "right", "salsa", "track", "unique", "venue", "write", "x-ray", "yacht", "zesty", "basic", "crisp", "dryly", "eager", "fetch", "grace"]
        @user_needs_a_hint = true
    end

    def start_wordle_game
        display_game_rules
        @player_name = get_player_name
        execute_turns
    end

    def execute_turns
        loop do
            new_game_state
            wordle_game_rounds
            break unless user_opts_replay?
        end
        puts "#{BLUE_FONT}Thanks for playing! Goodbye, have a great day!#{RESET_FONT_COLOR}"
    end

    def wordle_game_rounds
        while @turns_left > 0
            player_guess = get_player_guess
            next unless valid_guess?(player_guess)
            
            evaluate_user_guess(player_guess)
            display_guess_feedback(player_guess)
            
            if correct_word_guessed?
                puts "\n#{BLUE_FONT}Congratulations! You guessed the word: #{@target_word}!#{RESET_FONT_COLOR}"
                return
            end
            
            display_additional_feedback
        end
        puts "\n#{RED_FONT}You lose! The correct word was: #{@target_word}.#{RESET_FONT_COLOR}"
    end

    def get_player_name
        puts "\nWelcome to Wordle! What's your name?"
        name = gets.chomp
        puts "\nHi #{MAGENTA_FONT}#{name}#{RESET_FONT_COLOR}! Let's start the game!!"
        name
    end

    def get_player_guess
        puts "Please enter a five-letter word:"
        gets.chomp
    end

    def valid_guess?(player_guess)
        if !valid_length?(player_guess)
            puts "#{player_guess} is not a five-letter word. Please try again."
            return false
        end

        if invalid_word?(player_guess)
            puts "This is not a valid word. Please try again."
            return false
        end
        true
    end

    def correct_word_guessed?
        @correct_positions.compact.length == 5
    end

    def user_opts_replay?
        puts "Do you want to play again? (yes/no)"
        gets.chomp.strip.downcase == 'yes'
    end

    def valid_length?(word)
        word.length == 5
    end

    def invalid_word?(word)
        response = HTTParty.post(SPELL_CHECK_URL, {
          body: {
            text: word,
            language: "en-US"
          },
          headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
        })
    
        response.success? && !response.parsed_response["matches"].empty?
    end

    def evaluate_user_guess(player_guess)
        reset_round_feedback
        current_misplaced_letters = []
        
        player_guess.chars.each_with_index do |letter, index|
            determine_letter_position(letter, index, current_misplaced_letters)
        end

        # Remove any misplaced letters that have been guessed correctly (green)
        @misplaced_letters -= @correct_positions.compact
        @misplaced_letters.uniq!
        @misplaced_letters.concat(current_misplaced_letters).uniq!
    end

    def reset_round_feedback
        @correct_positions = [nil] * 5
    end

    def determine_letter_position(letter, index, current_misplaced_letters)
        if @target_word[index] == letter
            @correct_positions[index] = letter
        elsif @target_word.include?(letter)
            handle_misplaced_letter(letter, current_misplaced_letters)
        else
            @incorrect_letters << letter unless @incorrect_letters.include?(letter)
        end
    end

    def handle_misplaced_letter(letter, current_misplaced_letters)
        target_letter_count = @target_word.count(letter) - @correct_positions.count(letter)
        guessed_letter_count = current_misplaced_letters.count(letter)
        current_misplaced_letters << letter if guessed_letter_count < target_letter_count
    end

    def display_guess_feedback(player_guess)
        update_best_guess(player_guess)
        puts "\n#{GREEN_FONT}Best guess so far: #{display_word(@best_guess)}#{RESET_FONT_COLOR}"
        puts "#{GREEN_FONT}Correct letters in the correct position: #{display_word(@correct_positions)}#{RESET_FONT_COLOR}"
    end

    def display_additional_feedback
        puts "#{YELLOW_FONT}Correct letters but in the wrong position: #{@misplaced_letters.uniq.join(", ")}#{RESET_FONT_COLOR}"
        puts "#{RED_FONT}Incorrect letters: #{@incorrect_letters.uniq.join(", ")}#{RESET_FONT_COLOR}"
        @turns_left -= 1
    end

    def update_best_guess(player_guess)
        current_correct_count = @correct_positions.compact.length
        best_correct_count = @best_guess.compact.length
        @best_guess = @correct_positions.dup if current_correct_count >= best_correct_count
    end

    def display_word(word_array)
        word_array.map { |ch| ch.nil? ? "_" : ch }.join(" ")
    end

    def get_word_hint(word)
        response = HTTParty.get(HINT_URL + word)
        
        if response.success?
            definition = response.parsed_response.dig(0, 'meanings', 0, 'definitions', 0, 'definition')
            puts "#{BLUE_FONT}Hint: #{definition}#{RESET_FONT_COLOR}" if definition
        else
            puts "Error fetching hint."
        end
    end

    def display_game_rules
        rules = <<~RULES
        #{BOLD_FONT}Wordle Game Rules:#{RESET_FONT_COLOR}
        1. #{BOLD_FONT}You have 6 attempts to guess the correct 5-letter word.#{RESET_FONT_COLOR}
        2. #{BOLD_FONT}After each guess, the letters in your guess will be colored:#{RESET_FONT_COLOR}
        - #{GREEN_FONT}#{BOLD_FONT}Green#{RESET_FONT_COLOR}: Correct letter in the correct position.
        - #{YELLOW_FONT}#{BOLD_FONT}Yellow#{RESET_FONT_COLOR}: Correct letter in the wrong position.
        - #{RED_FONT}#{BOLD_FONT}Red#{RESET_FONT_COLOR}: Incorrect letter not in the word.
        3. #{BOLD_FONT}Use the feedback from your guesses to improve your next guess.#{RESET_FONT_COLOR}
        4. #{BOLD_FONT}Good luck!#{RESET_FONT_COLOR}
        RULES

        puts "\n#{rules}"
    end

    def new_game_state
        @turns_left = 6
        @correct_positions = [nil] * 5
        @best_guess = [nil] * 5
        @misplaced_letters = []
        @incorrect_letters = []
        @target_word = @word_list.sample
    end
end

wordle = WordleGame.new
wordle.start_wordle_game

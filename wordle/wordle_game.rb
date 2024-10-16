require 'httparty'

class WordleGame
    GREEN = "\e[32m"  
    YELLOW = "\e[33m" 
    RED = "\e[31m"
    BLUE = "\e[34m"
    MAGENTA = "\e[95m"  
    BOLD = "\e[1m"  
    RESET = "\e[0m"
    SPELL_CHECK_URL = "https://api.languagetoolplus.com/v2/check"
    HINT_URL = "https://api.dictionaryapi.dev/api/v2/entries/en/"

    def initialize
        @word_list = ["apple", "brick", "charm", "clown", "dream", "eagle", "frame", "grape", "heart", "laugh", "maple", "niche", "olive", "peach", "quilt", "robot", "smile", "tiger", "unity", "video", "watch", "zebra", "blaze", "chair", "dance", "equid", "foggy", "ghost", "honey", "ideal", "joint", "knife", "lemon", "merry", "night", "ocean", "plant", "quick", "raini", "shine", "train", "urban", "vouch", "waste", "yield", "ample", "berry", "clean", "drive", "event", "faith", "great", "honor", "image", "jolly", "knock", "learn", "metal", "noble", "other", "power", "quiet", "royal", "stone", "taste", "upper", "visit", "world", "yield", "angel", "boast", "chase", "equal", "fancy", "genre", "happy", "index", "joker", "kites", "lemon", "model", "nicey", "onyx", "place", "quiet", "right", "salsa", "track", "unique", "venue", "write", "x-ray", "yacht", "zesty", "basic", "crisp", "dryly", "eager", "fetch", "grace"]
        @hint_needed = true
    end

    def start_game
        display_rules
        @player_name = get_player_name
        execute_turns
    end

    def execute_turns
        loop do
            new_game
            game_rounds
            break unless play_again?
        end
        puts "#{BLUE}Thanks for playing! Goodbye, have a great day!#{RESET}"
    end

    def game_rounds
        while @turns_left > 0
            player_guess = get_player_guess
            next unless valid_guess?(player_guess)
            
            process_user_guess(player_guess)
            display_guess_feedback(player_guess)
            
            if correct_word_guessed?
                puts "\n#{BLUE}Congratulations! You guessed the word: #{@target_word}!#{RESET}"
                return
            end
            
            display_additional_feedback
            # handle_hint_request
        end
        puts "\n#{RED}You lose! The correct word was: #{@target_word}.#{RESET}"
    end

    def get_player_name
        puts "\nWelcome to Wordle! What's your name?"
        name = gets.chomp
        puts "\nHi #{MAGENTA}#{name}#{RESET}! Let's start the game!!"
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

    # def handle_hint_request
    #     return unless @turns_left <= 3 && @hint_needed

    #     puts "You have #{@turns_left} turns left. Do you want a hint? (yes/no)"
    #     want_hint = gets.chomp.strip.downcase
    #     if want_hint == 'yes'
    #         get_word_hint(@target_word)
    #         @hint_needed = false
    #     end
    # end

    def play_again?
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

    def process_user_guess(player_guess)
        reset_round_feedback
        current_misplaced_letters = []
        
        player_guess.chars.each_with_index do |letter, index|
            process_letter(letter, index, current_misplaced_letters)
        end

        @misplaced_letters.concat(current_misplaced_letters).uniq!
    end

    def reset_round_feedback
        @correct_positions = [nil] * 5
    end

    def process_letter(letter, index, current_misplaced_letters)
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
        puts "\n#{GREEN}Best guess so far: #{display_word(@best_guess)}#{RESET}"
        puts "#{GREEN}Correct letters in the correct position: #{display_word(@correct_positions)}#{RESET}"
    end

    def display_additional_feedback
        puts "#{YELLOW}Correct letters but in the wrong position: #{@misplaced_letters.uniq.join(", ")}#{RESET}"
        puts "#{RED}Incorrect letters: #{@incorrect_letters.uniq.join(", ")}#{RESET}"
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
            puts "#{BLUE}Hint: #{definition}#{RESET}" if definition
        else
            puts "Error fetching hint."
        end
    end

    def display_rules
        rules = <<~RULES
        #{BOLD}Wordle Game Rules:#{RESET}
        1. #{BOLD}You have 6 attempts to guess the correct 5-letter word.#{RESET}
        2. #{BOLD}After each guess, the letters in your guess will be colored:#{RESET}
        - #{GREEN}#{BOLD}Green#{RESET}: Correct letter in the correct position.
        - #{YELLOW}#{BOLD}Yellow#{RESET}: Correct letter in the wrong position.
        - #{RED}#{BOLD}Red#{RESET}: Incorrect letter not in the word.
        3. #{BOLD}Use the feedback from your guesses to improve your next guess.#{RESET}
        4. #{BOLD}Good luck!#{RESET}
        RULES

        puts "\n#{rules}"
    end

    def new_game
        @turns_left = 6
        @correct_positions = [nil] * 5
        @best_guess = [nil] * 5
        @misplaced_letters = []
        @incorrect_letters = []
        @target_word = @word_list.sample
    end
end

wordle = WordleGame.new
wordle.start_game

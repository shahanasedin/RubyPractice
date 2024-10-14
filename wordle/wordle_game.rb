require 'httparty'

class Game
    GREEN = "\e[32m"  
    YELLOW = "\e[33m" 
    RED = "\e[31m"
    BLUE = "\e[34m"
    MAGENTA = "\e[95m"  
    BOLD = "\e[1m"  
    RESET = "\e[0m"

    def initialize
        @words = File.readlines('D:\ruby\Wordle\words.txt').map(&:strip)
        @hint_needed = true
    end

    def new_game_state
        @turns = 6
        @green = [nil] * 5 # Current correct letters at correct position
        @best_green = [nil] * 5 # Overall Best Guess
        @yellow = [] # Correct letters but in the wrong position
        @red = [] # Wrong letters
        @target = @words.sample
    end
    
    def start
        display_rules
        puts "\nWelcome to the Wordle game! What's your name?"
        @user_name = gets.chomp
        puts "\nHi #{MAGENTA}#{@user_name}#{RESET}! Lets start the game!!"

        loop do
            new_game_state
            puts "You have #{@turns} chances to guess the word."
            puts "\nPlease enter a five-letter word:"
            guess
            puts "\nDo you want to play the game again? (yes / no)"
            choice = gets.chomp.strip.downcase
            if choice == "no"
                puts "#{BLUE}Thanks for playing! Bye , Have a good day#{RESET}"
                break
            end
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

    def guess
        until @turns == 0
            user_word = gets.chomp
            
            if user_word.length != 5
                puts "\n#{user_word} is not a five-letter word. Please try again."
                next
            end

            if check_spelling(user_word)
                puts "\nThis is not a valid word. Please try again."
                next
            end  

            process_guess(user_word)

            update_best_green(user_word) 
            puts "\n#{GREEN}Your best guess so far: #{display(@best_green)} #{RESET}"
            puts "\n#{GREEN}Correct letters in the correct position: #{display(@green)}#{RESET}"

            if @green.compact.length == 5
                puts "\nCongratulations! You win! You guessed #{BLUE}#{@target}#{RESET}"
                return
            end

            puts "\n#{YELLOW}Correct letters but in the wrong position: #{@yellow.uniq.join(", ")}#{RESET}"
            puts "\n#{RED}Letters not in the word: #{@red.uniq.join(", ")}#{RESET}"

            @turns -= 1

            if @turns <= 3 && @hint_needed
                puts "\nYou have only #{@turns} turns left. Do you want a hint (yes/no)?"
                choice = gets.chomp.strip.downcase
                if choice == "yes"
                    get_word_definition(@target)
                    @hint_needed = false
                end
            end

            if @turns > 0
                puts "\nYou have #{@turns} more chances to guess the word. \nPlease enter a five-letter word:"
            else
                puts "\nYou lose. The correct answer is #{BLUE}#{@target}.#{RESET}"
            end
        end
    end

    def process_guess(user_word)
        @green = [nil] * 5
        current_yellow_letters = []

        user_word.chars.each_with_index do |letter, index|
            if @target[index] == letter
                @green[index] = letter 
                @yellow.delete(letter) if @yellow.include?(letter)
            elsif @target.include?(letter)
                required_count = @target.count(letter) - @green.count(letter)
                current_count = current_yellow_letters.count(letter)
                current_yellow_letters << letter if current_count < required_count
            else
                @red << letter unless @red.include?(letter)
            end
        end
        @yellow.concat(current_yellow_letters).uniq!
    end

    def update_best_green(user_word)
        current_green_count = @green.compact.length
        best_green_count = @best_green.compact.length

        if current_green_count >= best_green_count
            @best_green = @green.dup 
        end
    end

    def check_spelling(word)
        response = HTTParty.post("https://api.languagetoolplus.com/v2/check", {
          body: {
            text: word,
            language: "en-US"
          },
          headers: { 'Content-Type' => 'application/x-www-form-urlencoded' }
        })
    
        if response.success?
            matches = response.parsed_response["matches"]
            result = (matches.empty?) ? false : true
        else
            puts "Error: #{response.code}"
            return false
        end
    end    

    def display(green)
        green.map { |ch| ch.nil? ? "_" : ch }.join(" ")
    end

    def get_word_definition(word)
        response = HTTParty.get("https://api.dictionaryapi.dev/api/v2/entries/en/#{word}")
        
        if response.success?
            definitions = response.parsed_response
            if definitions.is_a?(Array) && definitions.any?
                word_info = definitions.sample
                first_definition = word_info['meanings'].first['definitions'].first['definition']
                puts "#{BLUE}#{first_definition}#{RESET}"
            else
                puts "No definitions found for '#{word}'."
            end
        else
            puts "Error fetching definitions: #{response.code}."
        end
    end
end

game1 = Game.new
game1.start

require 'net/http'
require 'json'

class SpellChecker
    BASE_URL = "https://api.datamuse.com"

    def valid_word?(word)
        uri = URI("#{BASE_URL}/words?sp=#{word}")
        response = Net::HTTP.get_response(uri)
        if response.is_a?(Net::HTTPSuccess)
        words = JSON.parse(response.body)
        !words.empty?
        else
        puts "Error contacting spell checker API."
        false
        end
    end
end

def start
        loop do
            play_round
            puts "Do you want to play again? (yes/no)"
            replay_input = gets.chomp.downcase
            break unless replay_input == "yes"
        end
        puts "Thanks for playing! Goodbye!"
    end

class Game
    GREEN = "\e[32m"  
    YELLOW = "\e[33m" 
    RED = "\e[31m"
    BLUE = "\e[34m"    
    RESET = "\e[0m"   
    def initialize
        @turns = 6
        @green = [nil] * 5 # Current correct letters at correct position
        @best_green = [nil] * 5 # Best correct letters at correct position
        @yellow = [] # Correct letters but in the wrong position
        @red = [] # Wrong letters
        words = File.readlines('D:\ruby\Wordle\words.txt').map(&:strip)
        @target = words.sample
        @spell_checker = SpellChecker.new 
    end
    
    def start
        display_rules
        puts "\nWelcome to the Wordle game! What's your name?"
        user_name = gets.chomp
        puts "Hi #{user_name}! You have #{@turns} chances to guess the word."
        puts "\nPlease enter a five-letter word:"
        guess
    end

    def display_rules
        rules = <<-RULES
        Wordle Game Rules:
        
        1. You have 6 attempts to guess the correct 5-letter word.
        2. After each guess, the letters in your guess will be colored:
           - #{GREEN}Green#{RESET}: Correct letter in the correct position.
           - #{YELLOW}Yellow#{RESET}: Correct letter in the wrong position.
           - #{RED}Red#{RESET}: Incorrect letter not in the word.
        3. Use the feedback from your guesses to improve your next guess.
        4. Good luck!
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

        unless @spell_checker.valid_word?(user_word)
            puts "\nThis is not a valid word. Please try again."
            next
        end  

        process_guess(user_word)

        
        update_best_green(user_word) 
        puts "\n#{GREEN}Your best guess so far: #{display(@best_green)} #{RESET}"
        puts "#{GREEN}Correct letters in the correct position: #{display(@green)}#{RESET}"

        if @green.compact.length == 5
            puts "\nCongratulations! You win! You guessed #{BLUE}#{@target}#{RESET}"
            return
        end

        puts "\n#{YELLOW}Correct letters but in the wrong position: #{@yellow.uniq.join(", ")}#{RESET}"
        puts "\n#{RED}Letters not in the word: #{@red.uniq.join(", ")}#{RESET}"

        @turns -= 1
        if @turns > 0
            puts "\nYou have #{@turns} more chances to guess the word. \nPlease enter a five-letter word:"
        else
            puts "\nYou lose. The correct word was #{BLUE}#{@target}.#{RESET}"
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

        if current_green_count > best_green_count
        @best_green = @green.dup 
        end
    end

    def display(green)
        green.map { |ch| ch.nil? ? "_" : ch }.join(" ")
    end
end

game1 = Game.new
game1.start

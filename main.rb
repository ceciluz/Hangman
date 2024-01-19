require 'json'

class Game 

    ATTEMPTS_MAX = 5 

    def initialize
        start_new_game
    end

    def select_random_word 
        words = File.readlines('google-10000-english-no-swears.txt', chomp: true)
        valid_word = words.select {|word| word.chars.uniq.length <= 5 && word.length >= 5}
        random_word  = valid_word.sample     
        return random_word
    end 

    def guess 
        puts "Your guess: "
        letter = gets.chomp.downcase
    end

    def letters_guessed (letter, random_word)
        
        if random_word.include?(letter)
            @letters_guessed_right.push(letter)

        else 
            @letters_guessed_wrong.push(letter) 
        end
    end

    def winner? (secret_word)
        secret_word.chars.all? { |letter| @letters_guessed_right.include?(letter) }
    end

    def display(random_word)
        display = random_word.chars.map do |char|
            if @letters_guessed_right.include?(char)
                char
            else 
                "_"
            end
        end.join(" ")
        puts display
    end

    def start_new_game
        @letters_guessed_right = []
        @letters_guessed_wrong = []
        @secret_word = select_random_word
        @attempts = 0
        @victories =0
        @looses = 0
    end

    def to_json 
        {
            victories: @victories,
            losses: @looses
    }.to_json
    end

    def from_json(json_data)
        data = JSON.parse(json_data)
        @victories = data['victories'] || 0
        @looses = data['losses'] || 0
    end

    def save_game(player_name)
        File.open("#{player_name}_hangman_game.json", 'w') do |file|
        file.puts to_json
        end
    end

    def load_game(player_name)
        json_data = File.read("#{player_name}_hangman_game.json")
        from_json(json_data)
        puts "Victories: #{@victories} | Losses: #{@looses}"
      rescue Errno::ENOENT
        puts "No saved game found for #{player_name}. Starting a new game."
        start_new_game

    end


    def play_hangman (player_name)

        puts "Do you want to start a new game or load a saved game? (new/load)"
        choice = gets.chomp.downcase
    
        case choice
        when 'new'
          start_new_game
        when 'load'
          load_game(player_name)
        else
          puts "Invalid choice. Starting a new game."
          start_new_game
        end

        
        
        while (@attempts <= ATTEMPTS_MAX && winner?(@secret_word) == false)
          letter = guess
          letters_guessed(letter, @secret_word)
          display(@secret_word)
          @attempts +=1  
        end

        if winner?(@secret_word)
            puts "You win!"
            @victories += 1
        else
            puts "You lose"
            @looses += 1
        end
        
        puts "Do you want to save the game for later? (yes/no)"
        save_choice = gets.chomp.downcase

        if save_choice == 'yes'
        save_game(player_name)
        puts "Game saved. You can continue later."
        else
        puts "Game not saved. Thanks for playing!"
        end
  end
        

end

Game = Game.new

puts "Enter your name: "

player_name = gets.chomp.downcase

Game.play_hangman(player_name)

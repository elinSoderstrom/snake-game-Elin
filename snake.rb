require 'ruby2d'          #Including ruby2d library that enables graphical operations
set background: '#325a64'  #setting background color of the window
set fps_cap: 12.5         #setting frame-rate to 12.5 frames per second


GRID_SIZE = 20                         #defining the grid size in number of grid cells by width and height                    
GRID_WIDTH = Window.width / GRID_SIZE   #Calculating the width of each grid cell by dividing the total window height by the number of grid cells 
GRID_HEIGHT = Window.height / GRID_SIZE  #Calculating the height of each grid cell by dividing the total window width by the number of grid cells  

$highscore = 0    #initializing a global variabel where the high score can be stored and setting it to zero


class Snake                #Creating the Snake class to represent my snake in the game
    attr_writer :direction  #Creating the method direction which helps with changing the snakes direction based on user input
    
    def initialize  # defining the method "initialize" which initializes attributes such as the snakes position, direction and if its growing or not

        @positions= [[2, 0], [2, 1], [2, 2], [2, 3]]  #setting the start-coordinates for the different parts of the snake's body
        @direction= 'down'
        @growing = false

    end

    def draw    #defining the method "draw" that creates squares for each position of the snake's body

        @positions.each do |position|
            Square.new(x: position[0] * GRID_SIZE, y: position[1] * GRID_SIZE, size: GRID_SIZE - 1, color: '#68d0bd' )
        end

    end

    def move #defining a method to move the snake's body based on its direction

        if !@growing #telling the program that as long as @growing is not true, the tail should be removed (shifted) to remain it's length
            @positions.shift
        end
        
        case @direction #determing the new position of the snake's head based on its direction
        when 'down'
          @positions.push(new_coordinates(head[0], head[1] + 1))
        when 'up'
            @positions.push(new_coordinates(head[0], head[1] - 1))
        when 'left'
            @positions.push(new_coordinates(head[0] - 1, head[1]))
        when 'right'
            @positions.push(new_coordinates(head[0] + 1, head[1]))
        end

        @growing = false   #reseting the growing once it has moved one step

    end

    def can_change_direction_to?(new_direction)  #Creating a method that stops the snake from directly changing to the opposite direction

        case @direction  
        when 'up' then new_direction != 'down'
        when 'down' then new_direction != 'up'
        when 'right' then new_direction != 'left'
        when 'left' then new_direction != 'right'
        end

    end  

    def x  #Creating a method for the x-coordinate of the snake's head
        head[0]
    end

    def y  #Creating a method for the y-coordinate of the snake's head
        head[1]
    end


    def grow    #Method that signals that the snake should grow in the next frame
        @growing = true
    end

    def hit_itself?                                   #Creating a method that checks if the snake has collided with itself
        @positions.uniq.length != @positions.length     #Checks if any of the snake has any positions that aren't unique, which would mean that the length of the array of unique positions would be the same as the length of the snake
    end

    def head    #creating a method for the snake's head, giving it the coordinates of the last element in @positions
        @positions.last
    end

    private

    def new_coordinates(x, y)   #Method that helps with creating new coordinated for the snake
        [x , y]
    end

   
    

end



class Game #creating teh game class that handles all of the motorics of the game
    def initialize #method that initializes all the variables for the game class
        @score = 0  #creating an empty variable to hold the current score, and setting it to zero
        @apple_x = rand(GRID_WIDTH) #we are giving the apple random coordinates inside of the grid-system
        @apple_y = rand(GRID_HEIGHT) # -||-||
        @finished = false   #initialising the @finished variable and giving it the value false, sinvce the game isn't finished yet.
    end

    def draw   #a method that draws out the game elements on the screen

        unless finished?    #if the game isn't finished, a red square (representing the apple), on the new coordinates for the apple
            Square.new(x: @apple_x * GRID_SIZE, y: @apple_y * GRID_SIZE, size: GRID_SIZE, color: 'red' )
        end

        Text.new(text_message, color: 'white', x: 10, y:10, size: 25 )  #writing out the score in the top left corner
        Text.new("High score: #{$highscore}", color: 'white', x:10, y: 440, size: 25) #writing out the high score in the bottom left corner

    end

    def snake_hit_apple?(x, y)   #defining a method that checks if the snake has hit the apple   
        @apple_x == x && @apple_y == y  #if the snakes x-value and y-value equals the apple's x- and y-value, the snake has hit the apple
    end

    def snake_hit_border?(x, y)     #defining method that checks if the snake has hit the border of the game
        x == GRID_WIDTH || y == GRID_HEIGHT || x == -1 || y == -1     
    end


    def record_hit  #defining a method for recording a hit (hitting an apple)
        @score += 1                     #Incrementing the score with 1
        @apple_x = rand(GRID_WIDTH)     #Giving the apple new coordinates
        @apple_y = rand(GRID_HEIGHT)    #-||-||-
        if @score > $highscore          #Incrementing the highscore with one if the current score is higher than the recent high score
            $highscore = @score
        end
    end

    def finish  #defining the method "finish" setting the variable @finished to true
        @finished = true
    end


    def finished? #method for checking if the game is finished
        @finished
    end

    private

    def text_message    #generating a text message based on the state of the game

        if finished?
            
             "You're score was: #{@score}. PRESS 'R' TO RESTART"
        else 
            "Score: #{@score}"
        end

    end

end


snake = Snake.new   #Instantiate a new snake
game = Game.new     #Instantiate a new game

update do   #updating the game loop and rendering the elements on the screen
    clear



    unless game.finished?   #if the game is not finished, move and draw the snake
        snake.move
        snake.draw
    end
    
    game.draw #draw the game elements

    if game.snake_hit_apple?(snake.x, snake.y)  #If statement checks if the snake has hit the apple, records the hit, and makes the snake grow.
        game.record_hit
        snake.grow
    end

    if snake.hit_itself?    #if-statement that checks if the snake has hit itself, in that case finish the game
        game.finish
    end

    if game.snake_hit_border?(snake.x, snake.y)     #if-statement that checks if the snake has hit the border, in that case finish the game
        game.finish
    end
end


on :key_down do |event|     #Event-handling-block for key-down events
    if ['up', 'down', 'left', 'right'].include?(event.key)
        if snake.can_change_direction_to?(event.key)
            snake.direction = event.key
        end
    elsif event.key == 'r'  #Restarting the game if the 'r' key is pressed down
        snake = Snake.new   #A new snake is getting created
        game = Game.new     #A new game is getting created
    end

end

show    #display the window


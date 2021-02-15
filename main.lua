push = require 'push'

Class = require 'class'

require 'Paddle'
require 'Ball'


WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720

VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200
winningScore = 2


function love.load()

    love.window.setTitle("Pwn the Pong!")
    love.graphics.setDefaultFilter('nearest', 'nearest')
    smallFont = love.graphics.newFont('fonts/font.ttf', 16)
    scoreFont = love.graphics.newFont('fonts/font.ttf', 32)
    math.randomseed(os.time())

    love.graphics.setFont(smallFont)
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false, 
        resizable = false, 
        vsync = true})   

    -- Sounds

    sounds={
        ['hitSound'] = love.audio.newSource("sounds/oof.mp3", "static"),
        ['pwnSound'] = love.audio.newSource("sounds/echo.mp3", "static"),
        ['wallCollisionSound'] = love.audio.newSource("sounds/foo.mp3", "static"),
        ['winSound'] = love.audio.newSource("sounds/win.mp3", "stream"),
        ['bgMusic'] = love.audio.newSource("sounds/bgMusic.mp3", "stream")
    }
    
    -- Background
    
    bg = love.graphics.newImage("images/bg.jpg")

    -- Players initial position

    player1 = Paddle(10, VIRTUAL_HEIGHT/2, 5, 20)    
    player2 = Paddle(VIRTUAL_WIDTH-10, VIRTUAL_HEIGHT/2, 5, 20)

    -- Ball initial position

    ball = Ball(VIRTUAL_WIDTH / 2 - 3.5, VIRTUAL_HEIGHT / 2-2, 4, 4)

    -- Scores
    player1Score = 0
    player2Score = 0

    -- First turn

    servingPlayer = 1

    -- Initial Game State

    gameState = 'start';

    -- Speed
    
    iAmSpeed = math.random(10, 150) * 2

    --  Text Test

    goingDown = false
    scaleX = 0.5
    scaleY = 0.5


end



function love.update(dt)

    if goingDown then
        scaleX = scaleX - dt
        scaleY = scaleY - dt
        if scaleX < 0.5 then
            goingDown = false
        end
     else
        scaleX = scaleX + dt
        scaleY = scaleY + dt
        if scaleX > 1.5 then
            goingDown = true
        end
     end

    if gameState == 'serve' then
        if servingPlayer == 1 then
            ball.dx = math.random(-140, 200)*2
        else
            ball.dx = -math.random(-140, 200)*2
        end
        ball.dy = math.random(-50, 50)*3


    elseif gameState == 'play' then
        if ball.y <= 0 then
            sounds.wallCollisionSound:play()
            ball.y = 0
            ball.dy = -ball.dy
        end

        if ball.y >= VIRTUAL_HEIGHT - 4 then
            sounds.wallCollisionSound:play()
            ball.y = VIRTUAL_HEIGHT - 4
            ball.dy = -ball.dy
        end


        if ball:collides(player1) then
            ball.dx = -ball.dx * 2.04
            ball.x = player1.x + 5
            sounds.hitSound:play() -- Player collision sound

            if ball.dy < 0 then
                ball.dy = -iAmSpeed
                sounds.hitSound:play() -- Player collision sound
            else
                ball.dy = iAmSpeed
                sounds.hitSound:play() -- Player collision sound   
            end
        end

        if ball:collides(player2) then
            ball.dx = -ball.dx * 2.04
            ball.x = player2.x - 4
            sounds.hitSound:play() -- Player collision sound

            if ball.dy < 0 then
                ball.dy = -iAmSpeed
                sounds.hitSound:play() -- Player collision sound
            else
                ball.dy = iAmSpeed
                sounds.hitSound:play()  -- Player collision sound
            end
        end
    end


    if ball.x < 0 then -- SERVE
        sounds.pwnSound:play()
        player2Score = player2Score + 1
        servingPlayer = 1
        ball:reset()
        if player2Score == winningScore then
            winningPlayer = 2
            gameState = 'done'
        else
            gameState = 'serve'
        end
    end

    if ball.x > VIRTUAL_WIDTH then
        sounds.pwnSound:play() -- Gol sound
        player1Score = player1Score + 1
        servingPlayer = 2
        ball:reset()
        if player1Score == winningScore then
            winningPlayer = 1
            gameState = 'done'
        else
            gameState = 'serve'
        end
    end



    if love.keyboard.isDown('w') then
        player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('s') then
        player1.dy = PADDLE_SPEED
    else
        player1.dy = 0
    end

    if love.keyboard.isDown('up') then
        player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown('down') then
        player2.dy = PADDLE_SPEED
    else
        player2.dy = 0
    end

    if gameState == 'play' then
        ball:update(dt)
    end

    player1:update(dt)
    player2:update(dt)

end


function love.keypressed(key)
    if key == 'escape' then
        love.event.quit()
    elseif key == 'enter' or key == 'return' then
        love.audio.stop()
        if gameState == 'start' then
            gameState = 'serve' -- SERVE
        elseif gameState == 'serve' then
            gameState = 'play'
        elseif gameState == 'done' then
            gameState = 'serve'
            ball:reset()
            player1Score = 0
            player2Score = 0

            if winninPlayer == 1 then
                savingPlayer = 2
            else
                servingPlayer = 1
            end
        else
            gameState = 'start'
            ball:reset()
        end
    end 
end

function love.draw()
    love.graphics.draw(bg, 0, 0, 0, 0.75)
    push:apply("start")

    love.graphics.setFont(smallFont)

    if gameState == 'start' then
        love.audio.stop()
        -- sounds.bgMusic:play()
        -- sounds.bgMusic:setLooping(true)
        love.graphics.setColor( 0, 255, 0)
        love.graphics.printf('Press to enter to PWN the pong', 0, 20, VIRTUAL_WIDTH + 17, 'center')
    elseif gameState == 'serve' then
        love.graphics.setColor( 0, 255, 0)
        love.graphics.printf("Player ".. tostring(servingPlayer).."'s serve", 0, 10, VIRTUAL_WIDTH + 18, 'center')
        love.graphics.printf('Press enter to serve', 0, 95, VIRTUAL_WIDTH + 18, 'center')
        --[[ love.graphics.push()
        love.graphics.scale(scaleX, scaleY)
        love.graphics.printf('Press enter to serve', 0, 95, VIRTUAL_WIDTH + 18, 'center')
        love.graphics.pop()]]
    --elseif gamestate == 'play' then
    elseif gameState == 'done' then
        sounds.winSound:play() -- Win Sound
        love.graphics.setColor( 0, 255, 0)
        love.graphics.printf("Player ".. tostring(servingPlayer).." wins!", 0, 10, VIRTUAL_WIDTH + 18, 'center')
        love.graphics.printf('Press enter to restart', 0, 95, VIRTUAL_WIDTH + 18, 'center')
        --[[ love.graphics.push()
        love.graphics.scale(scaleX, scaleY)
        love.graphics.printf('Press enter to restart', 0, 95, VIRTUAL_WIDTH + 18, 'center')
        love.graphics.pop() ]]
    end
        

    love.graphics.setFont(scoreFont)
    love.graphics.setColor( 0, 255, 0)
    love.graphics.print(tostring(player1Score), VIRTUAL_WIDTH / 2 - 60, VIRTUAL_HEIGHT / 4)
    love.graphics.print(tostring(player2Score), VIRTUAL_WIDTH / 2 + 40, VIRTUAL_HEIGHT / 4)


   
    drawDottedLine(10,11)
    player1:render()
    player2:render()
    ball:render()
    push:apply("end")

end

function drawDottedLine(line_height, gap_height)
    for y = 0, VIRTUAL_HEIGHT, line_height + gap_height do
        love.graphics.line(VIRTUAL_WIDTH / 2 - 2, y , VIRTUAL_WIDTH / 2 - 2, y + line_height)
    end
end

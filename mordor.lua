local composer = require( "composer" )
local scene = composer.newScene()

-- iniciando a física do jogo --
local physics = require("physics")
physics.start()
--physics.setDrawMode("hybrid")

mordormusic = audio.loadSound( "soundtrack/mordor.wav" )
audio.play( mordormusic, {channel=6, loops=-1} )

local function gotoDeath()
    composer.gotoScene( "gameover", { time=1000, effect="crossFade"} )
    audio.stop(6)
end

-- resetar atk da esquerda --
local function releaseAtkLeft()
    atkiconLeft:addEventListener( "tap", atkLeft )
end
    
-- resetar atk da direita --
local function releaseAtkRight()
    atkiconRight:addEventListener( "tap", atkRight )
end

-- função pra atacar pra esquerda --
function atkLeft()
    system.setTapDelay(10)
    display.remove(char)
    char = display.newImageRect ( "Sprites/archerLeft.png", 50, 60)
    char.x = display.contentCenterX
    char.y = display.contentCenterY+50
    physics.addBody (char, "static", { isSensor=false })
    char.myName = "char"

    arrowLeft = display.newImageRect ( "Sprites/arrowLeft.png", 50, 5)
    arrowLeft.x = display.contentCenterX-40
    arrowLeft.y = display.contentCenterY+40
    physics.addBody (arrowLeft, "dynamic", { bounce = 0 })
    arrowLeft:setLinearVelocity(-500, 0)
    arrowLeft.gravityScale = 0
    arrowLeft.myName = "arrowLeft"

    atkiconLeft:removeEventListener( "tap", atkLeft)
    timer.performWithDelay(170,releaseAtkLeft)
end

-- função para atacar pra direita --
function atkRight()
    system.setTapDelay(10)
    display.remove(char)
    char = display.newImageRect ( "Sprites/archerRight.png", 50, 60)
    char.x = display.contentCenterX
    char.y = display.contentCenterY+50
    physics.addBody (char, "static", { isSensor=false })
    char.myName = "char"

    arrowRight = display.newImageRect ( "Sprites/arrowRight.png", 50, 5)
    arrowRight.x = display.contentCenterX+40
    arrowRight.y = display.contentCenterY+40
    physics.addBody (arrowRight, "dynamic", { bounce = 0 })
    arrowRight:setLinearVelocity(500, 0)
    arrowRight.gravityScale = 0
    arrowRight.myName = "arrowRight"

    atkiconRight:removeEventListener( "tap", atkRight)
    timer.performWithDelay(170,releaseAtkRight)
end

-- restaurar personagem -- 
local function restoreChar()
    char.isBodyActive = false
    char.x = display.contentCenterX
    char.y = display.contentCenterY+50

    transition.to( char, { alpha=1, time=70,
        onComplete = function()
        char.isBodyActive = true
        died = false
    end
    } )
end

-- inciar o spawn dos monstros --
local spawnTimer
local spawnedObjects = {}
math.randomseed( os.time() )

-- parametros de spawn --
local spawnParams = {
    xMin = 0,
    xMax = 120,
    yMin = 210,
    yMax = 210,
    spawnTime = 250,
    spawnOnTimer = 1,
    spawnInitial = 1
}

-- função de spawn --
local function spawnItem( bounds )
    local position = math.random (4)
    if (position == 1) then 
        monster = display.newImageRect ( "Sprites/monster1L.png", 65, 65)
        physics.addBody (monster, "dynamic", { bounce = 0 })
        monster.x = -100
        monster.y = 210
        monster:setLinearVelocity(130, 0)
        monster.myName = "monster"
        spawnedObjects[#spawnedObjects+1] = monster
    elseif (position == 2) then
        monster = display.newImageRect ( "Sprites/monster1R.png", 65, 65)
        physics.addBody (monster, "dynamic", { bounce = 0 })
        monster.x = 525
        monster.y = 210
        monster:setLinearVelocity(-130, 0)
        monster.myName = "monster"
        spawnedObjects[#spawnedObjects+1] = monster
    elseif (position == 3) then
        monster = display.newImageRect ( "Sprites/monster2L.png", 30, 45)
        physics.addBody (monster, "dynamic", { bounce = 0 })
        monster.x = -85
        monster.y = 210
        monster:setLinearVelocity(130, 0)
        monster.myName = "monster"
        spawnedObjects[#spawnedObjects+1] = monster
    else 
        monster = display.newImageRect ( "Sprites/monster2R.png", 30, 45)
        physics.addBody (monster, "dynamic", { bounce = 0 })
        monster.x = 550
        monster.y = 210
        monster:setLinearVelocity(-130, 0)
        monster.myName = "monster"
        spawnedObjects[#spawnedObjects+1] = monster
    end
end

-- função de controle para startar e parar o spawn --
local function spawnController( action, params )
    if ( spawnTimer and ( action == "start" or action == "stop" ) ) then
        timer.cancel( spawnTimer )
    end

    if ( action == "start" ) then
        local spawnBounds = {}
        spawnBounds.xMin = params.xMin or 0
        spawnBounds.xMax = params.xMax or display.contentWidth
        spawnBounds.yMin = params.yMin or 0
        spawnBounds.yMax = params.yMax or display.contentHeight

        local spawnTime = params.spawnTime or 1000
        local spawnOnTimer = params.spawnOnTimer or 50
        local spawnInitial = params.spawnInitial or 0

        if ( spawnInitial > 0 ) then
            for n = 1,spawnInitial do
                spawnItem( spawnBounds )
            end
        end

        if ( spawnOnTimer > 0 ) then
            spawnTimer = timer.performWithDelay( spawnTime,
                function() spawnItem( spawnBounds ); end,
            -1 )
        end

       elseif ( action == "pause" ) then
           timer.pause( spawnTimer )
   
       elseif ( action == "resume" ) then
           timer.resume( spawnTimer )
       end
   end

   spawnController( "start", spawnParams )

-- colisão --
local function onCollision ( event )
    if ( event.phase == "began" ) then
        local obj1 = event.object1
        local obj2 = event.object2

        if ( ( obj1.myName == "arrowLeft" and obj2.myName == "monster" ) or
            ( obj1.myName == "monster" and obj2.myName == "arrowLeft" ) or
            ( obj1.myName == "arrowRight" and obj2.myName == "monster" ) or
            ( obj1.myName == "monster" and obj2.myName == "arrowRight" ) )
        then
            display.remove ( obj1 )
            display.remove ( obj2 )
            score = score + 1
            scoreText.text = "Pontos    " .. score
            for i = #spawnedObjects, 1, -1 do
                if ( spawnedObjects[i] == obj1 or spawnedObjects[i] == obj2 ) then
                    table.remove( spawnedObjects, i )
                    break
                end
            end

        elseif 
            ( ( obj1.myName == "char" and obj2.myName == "monster" ) or 
            (obj1.myName == "monster" and obj2.myName == "char" ) )
        then 
            if ( died == false ) then
                died = true
                char.alpha = 1
                timer.performWithDelay( 1000, restoreChar )
                lives = lives - 1
                display.remove(live)
                
                for i = #spawnedObjects, 1, -1 do
                    display.remove( spawnedObjects[i] )
                    table.remove( spawnedObjects, i )
                end
            
                if (lives == 2) then
                    live = display.newImageRect( "Sprites/live2.png", 66, 30)
                    live.x = display.contentCenterX
                    live.y = display.contentCenterY-135
                    live.myName = "live" 
                elseif (lives == 1) then
                    live = display.newImageRect( "Sprites/live1.png", 33, 30)
                    live.x = display.contentCenterX
                    live.y = display.contentCenterY-135
                    live.myName = "live"
                else
                    -- vidas zeraram --
                    spawnController( "stop", spawnParams )
                    display.remove(char)
                    display.remove(live)
                    atkiconLeft:removeEventListener( "tap", atkLeft)
                    atkiconRight:removeEventListener( "tap", atkRight)
                    gotoDeath()
                end
            end
        end
    end
end

--Desistir do jogo
local function quit()
    for i = #spawnedObjects, 1, -1 do
        display.remove( spawnedObjects[i] )
        table.remove( spawnedObjects, i )
    end
    spawnController( "stop", spawnParams )
    display.remove(char)
    display.remove(live)
    atkiconLeft:removeEventListener( "tap", atkLeft)
    atkiconRight:removeEventListener( "tap", atkRight)
    gotoDeath()
end

Runtime:addEventListener( "collision", onCollision )


composer.recycleOnSceneChange = true;
function scene:create ( event )
    sceneGroup = self.view
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
            
    -- variáveis necessárias --
    lives = 3
    score = 0
    died = false
    livesText = 0
    scoreText = 0

    -- fundo da fase --
    background = display.newImageRect( "Sprites/mordorBG.png", 640, 320)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    -- pontuação -- 
    scoreText = display.newText( "Pontos    " .. score, 240, 280, "Kingdom Hearts", 40 )

    -- botao de desistir --
    quitbutton = display.newImageRect("Sprites/quit.png", 80, 35 )
    quitbutton.x = display.contentCenterX+240
    quitbutton.y = display.contentCenterY-140
    quitbutton.alpha = 0.7
    quitbutton.myName = "quit"
    physics.addBody (quitbutton, "static", {radius=35} )

    -- icone para atacar para a esquerda --
    atkiconLeft = display.newImageRect( "Sprites/atkiconLeft2.png", 65, 65 )
    atkiconLeft.x = display.contentCenterX-230
    atkiconLeft.y = display.contentCenterY+120
    atkiconLeft.alpha = 0.7
    atkiconLeft.myName = "atkiconLeft"
    physics.addBody (atkiconLeft, "static", { radius=35 })

    -- icone para atacar para a direita --
    atkiconRight = display.newImageRect( "Sprites/atkiconRight2.png", 65, 65 )
    atkiconRight.x = display.contentCenterX+230
    atkiconRight.y = display.contentCenterY+120
    atkiconRight.alpha = 0.7
    physics.addBody (atkiconRight, "static", { radius=35 })

    atkiconLeft:addEventListener( "tap", atkLeft )
    atkiconRight:addEventListener( "tap", atkRight )
    quitbutton:addEventListener( "tap", quit )

    -- personagem --
    char = display.newImageRect ( "Sprites/archerLeft.png", 50, 60)
    char.x = display.contentCenterX
    char.y = display.contentCenterY+50
    physics.addBody (char, "static", { isSensor=false })
    char.myName = "char"

    -- barra de vida --
    live = display.newImageRect( "Sprites/live3.png", 99, 30)
    live.x = display.contentCenterX
    live.y = display.contentCenterY-135
    live.myName = "live"

    -- chão da fase (eixo x, eixo y, largura, altura)--
    floor = display.newRect (180, 240, 720, 1)
    floor:setFillColor (0.2, 0.8, 0.5)
    floor.alpha = 0.0
    floor.name = "Floor"
    physics.addBody (floor, "static")

    sceneGroup:insert(background)
    sceneGroup:insert(atkiconLeft)
    sceneGroup:insert(atkiconRight)
    sceneGroup:insert(char)
    sceneGroup:insert(live)
    sceneGroup:insert(floor)
    sceneGroup:insert(quitbutton)
    elseif ( phase == "did" ) then
    end
end

function scene:hide( event )
    local sceneGroup = self.view
    local phase = event.phase
    if ( phase == "will" ) then
    elseif ( phase == "did" ) then
    end
end

function scene:destroy( event )
    local sceneGroup = self.view
    atkiconLeft:removeSelf()
    atkiconLeft = nil
    atkiconRight:removeSelf()
    atkiconRight = nil
    quitbutton:removeSelf()
    quitbutton = nil
    floor:removeSelf()
    floor = nil
    Runtime:removeEventListener( "collision", onCollision )
end
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene
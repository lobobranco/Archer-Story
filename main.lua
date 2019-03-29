-- iniciando a física do jogo --
local physics = require("physics")
physics.start()
--physics.setDrawMode("hybrid")

-- variáveis necessárias --
local lives = 3
local score = 0
local died = false
local livesText
local scoreText

 -- fundo da fase --
local background = display.newImageRect( "Sprites/mordorBG.png", 640, 320)
background.x = display.contentCenterX
background.y = display.contentCenterY

-- pontuação -- 
scoreText = display.newText( "Score    " .. score, 240, 290, "Kingdom Hearts", 72 )

-- icone para atacar para a esquerda --
local atkiconLeft = display.newImageRect( "Sprites/atkiconLeft.png", 65, 65 )
atkiconLeft.x = display.contentCenterX-230
atkiconLeft.y = display.contentCenterY+120
atkiconLeft.alpha = 0.7
physics.addBody (atkiconLeft, "static", { radius=35 })

-- icone para atacar para a direita --
local atkiconRight = display.newImageRect( "Sprites/atkiconRight.png", 65, 65 )
atkiconRight.x = display.contentCenterX+230
atkiconRight.y = display.contentCenterY+120
atkiconRight.alpha = 0.7
physics.addBody (atkiconRight, "static", { radius=35 })

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
local floor = display.newRect (180, 240, 720, 1)
floor:setFillColor (0.2, 0.8, 0.5)
floor.alpha = 0.0
floor.name = "Floor"
physics.addBody (floor, "static")

 -- função pra atacar pra esquerda --
local function atkLeft()
    display.remove(char)
    char = display.newImageRect ( "Sprites/archerLeft.png", 50, 60)
    char.x = display.contentCenterX
    char.y = display.contentCenterY+50
    physics.addBody (char, "static", { isSensor=false })
    char.myName = "char"

    local arrowLeft = display.newImageRect ( "Sprites/arrowLeft.png", 50, 5)
    arrowLeft.x = display.contentCenterX-40
    arrowLeft.y = display.contentCenterY+40
    physics.addBody (arrowLeft, "dynamic", { bounce = 0 })
    arrowLeft:setLinearVelocity(-500, 0)
    arrowLeft.gravityScale = 0
    arrowLeft.myName = "arrowLeft"
end

-- função para atacar pra direita --
local function atkRight()
    display.remove(char)
    char = display.newImageRect ( "Sprites/archerRight.png", 50, 60)
    char.x = display.contentCenterX
    char.y = display.contentCenterY+50
    physics.addBody (char, "static", { isSensor=false })
    char.myName = "char"

    local arrowRight = display.newImageRect ( "Sprites/arrowRight.png", 50, 5)
    arrowRight.x = display.contentCenterX+40
    arrowRight.y = display.contentCenterY+40
    physics.addBody (arrowRight, "dynamic", { bounce = 0 })
    arrowRight:setLinearVelocity(500, 0)
    arrowRight.gravityScale = 0
    arrowRight.myName = "arrowRight"
end

atkiconRight:addEventListener( "tap", atkRight )
atkiconLeft:addEventListener( "tap", atkLeft )

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
    spawnTime = 350,
    spawnOnTimer = 1,
    spawnInitial = 1
}

-- função de spawn --
local function spawnItem( bounds )
    local position = math.random (4)
    print(position)
    if (position == 1) then 
        local monster = display.newImageRect ( "Sprites/monster1L.png", 65, 65)
        physics.addBody (monster, "dynamic", { bounce = 0 })
        monster.x = -100
        monster.y = 210
        monster:setLinearVelocity(130, 0)
        monster.myName = "monster"
        spawnedObjects[#spawnedObjects+1] = monster
    elseif (position == 2) then
        local monster = display.newImageRect ( "Sprites/monster1R.png", 65, 65)
        physics.addBody (monster, "dynamic", { bounce = 0 })
        monster.x = 525
        monster.y = 210
        monster:setLinearVelocity(-130, 0)
        monster.myName = "monster"
        spawnedObjects[#spawnedObjects+1] = monster
    elseif (position == 3) then
        local monster = display.newImageRect ( "Sprites/monster2L.png", 30, 45)
        physics.addBody (monster, "dynamic", { bounce = 0 })
        monster.x = -85
        monster.y = 210
        monster:setLinearVelocity(130, 0)
        monster.myName = "monster"
        spawnedObjects[#spawnedObjects+1] = monster
    else 
        local monster = display.newImageRect ( "Sprites/monster2R.png", 30, 45)
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
    -- Cancel timer on "start" or "stop", if it exists
    if ( spawnTimer and ( action == "start" or action == "stop" ) ) then
        timer.cancel( spawnTimer )
    end
 
    -- Start spawning
    if ( action == "start" ) then
 
        -- Gather/set spawning bounds
        local spawnBounds = {}
        spawnBounds.xMin = params.xMin or 0
        spawnBounds.xMax = params.xMax or display.contentWidth
        spawnBounds.yMin = params.yMin or 0
        spawnBounds.yMax = params.yMax or display.contentHeight
 
        -- Gather/set other spawning params
        local spawnTime = params.spawnTime or 1000
        local spawnOnTimer = params.spawnOnTimer or 50
        local spawnInitial = params.spawnInitial or 0
 
        -- If "spawnInitial" is greater than 0, spawn that many item(s) instantly
        if ( spawnInitial > 0 ) then
            for n = 1,spawnInitial do
                spawnItem( spawnBounds )
            end
        end
 
        -- Start repeating timer to spawn items
        if ( spawnOnTimer > 0 ) then
            spawnTimer = timer.performWithDelay( spawnTime,
                function() spawnItem( spawnBounds ); end,
            -1 )
        end
 
    -- Pause spawning
    elseif ( action == "pause" ) then
        timer.pause( spawnTimer )
 
    -- Resume spawning
    elseif ( action == "resume" ) then
        timer.resume( spawnTimer )
    end
end

spawnController( "start", spawnParams )

-- restaurar personagem -- 
local function restoreChar()

	char.isBodyActive = false
    char.x = display.contentCenterX
    char.y = display.contentCenterY+50

	-- Fade in the ship
	transition.to( char, { alpha=1, time=70,
		onComplete = function()
			char.isBodyActive = true
			died = false
		end
	} )
end

-- colisão --

local function onCollision ( event )
    if ( event.phase == "began" ) then
        local obj1 = event.object1
        local obj2 = event.object2
        print(obj2.myName)
 
        if ( ( obj1.myName == "arrowLeft" and obj2.myName == "monster" ) or
             ( obj1.myName == "monster" and obj2.myName == "arrowLeft" ) or
             ( obj1.myName == "arrowRight" and obj2.myName == "monster" ) or
             ( obj1.myName == "monster" and obj2.myName == "arrowRight" ) )
        then
            display.remove ( obj1 )
            display.remove ( obj2 )
            score = score + 1
			scoreText.text = "Score    " .. score
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
                    spawnController( "stop", spawnParams )
                    display.remove(char)
                end
            end
        end
    end
end

Runtime:addEventListener( "collision", onCollision )
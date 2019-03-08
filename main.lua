-- iniciando a física do jogo --
local physics = require("physics")
physics.start()

 -- fundo da fase --
local background = display.newImageRect( "Sprites/mordorbd.png", 640, 320)
background.x = display.contentCenterX
background.y = display.contentCenterY

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
local char = display.newImageRect ( "Sprites/char.png", 50, 70)
char.x = display.contentCenterX
char.y = display.contentCenterY+30
physics.addBody (char, "dynamic")

-- chão da fase (eixo x, eixo y, largura, altura)--
local floor = display.newRect (180, 240, 720, 1)
floor:setFillColor (0.2, 0.8, 0.5)
floor.alpha = 0.0
floor.name = "Floor"
physics.addBody (floor, "static")

 -- função pra atacar pra esquerda --
local function atkLeft()
    char.x = char.x+40
end

 -- função pra retorno da esquerda --
local function atkLeftR()
    char.x = char.x-40
    timer.performWithDelay( 200, atkLeft )
end

-- função para atacar pra direita --
local function atkRight()
    char.x = char.x-40
end

 -- função pra retorno da direita --
local function atkRightR()
    char.x = char.x+40
    timer.performWithDelay( 200, atkRight )
end

atkiconRight:addEventListener( "tap", atkRightR )
atkiconLeft:addEventListener( "tap", atkLeftR )

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
    spawnTime = 800,
    spawnOnTimer = 1,
    spawnInitial = 1
}

-- função de spawn --
local function spawnItem( bounds )
    local position = math.random (2)
    print(position)
    if (position == 1) then 
        local item = display.newImageRect ( "Sprites/monster.png", 50, 50)
        physics.addBody (item, "dynamic", { radius = 25, bounce = 0 })
        item.x = -100
        item.y = 210
        item:setLinearVelocity(50, 0)
    else
        local item = display.newImageRect ( "Sprites/monster2.png", 50, 50)
        physics.addBody (item, "dynamic", { radius = 25, bounce = 0 })
        item.x = 495
        item.y = 210
        item:setLinearVelocity(-50, 0)
    end
    spawnedObjects[#spawnedObjects+1] = item
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
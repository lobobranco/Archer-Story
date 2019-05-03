local composer = require( "composer" )
local scene = composer.newScene()

local physics = require("physics")
physics.start()

local function gotoMenu()
    composer.gotoScene( "mainmenu", { time=150, effect="crossFade"} )
end

local function gotoEasy()
    composer.gotoScene( "easy", { time=150, effect="crossFade"} )
    audio.stop(1)
end

local function gotoNormal()
    composer.gotoScene( "normal", { time=150, effect="crossFade"} )
    audio.stop(1)
end

local function gotoHard()
    composer.gotoScene( "hard", { time=150, effect="crossFade"} )
    audio.stop(1)
end

local function gotoMordor()
    composer.gotoScene( "mordor", { time=150, effect="crossFade"} )
    audio.stop(1)
end

-- funções do composer --
composer.recycleOnSceneChange = true;
function scene:create ( event )
    sceneGroup = self.view
    
    background = display.newImageRect( "Sprites/levelmenu.png", 570, 320)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    -- botão para voltar --
    back = display.newRect( -20, 22, 42, 42 )
    back.alpha = 0.01

    --botão para jogar o modo fácil --
    easy = display.newRect( 66, 240, 120, 105 )
    easy.alpha = 0.01

    --botão para jogar o modo normal --
    normal = display.newRect( 185, 240, 120, 105 )
    normal.alpha = 0.01

    --botão para jogar o modo difícil --
    hard = display.newRect( 305, 240, 120, 105 )
    hard.alpha = 0.01

    --botão para jogar o modo MORDOR --
    mordor = display.newRect(425, 240, 120, 105 )
    mordor.alpha = 0.01

    sceneGroup:insert(background)
    sceneGroup:insert(back)
    sceneGroup:insert(easy)
    sceneGroup:insert(normal)
    sceneGroup:insert(hard)
    sceneGroup:insert(mordor)
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        back:addEventListener( "tap", gotoMenu )
        easy:addEventListener( "tap", gotoEasy )
        normal:addEventListener( "tap", gotoNormal )
        hard:addEventListener( "tap", gotoHard )
        mordor:addEventListener( "tap", gotoMordor )
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
end
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
return scene
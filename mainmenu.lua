local composer = require( "composer" )
local scene = composer.newScene()
local physics = require("physics")
physics.start()

local function gotoLevel()
    composer.gotoScene( "levelmenu", { time=150, effect="crossFade"} )
end

local function gotoCredits()
    composer.gotoScene( "creditsmenu", { time=150, effect="crossFade"} )
end

local function gotoTutorial()
    composer.gotoScene( "tutorialmenu", { time=150, effect="crossFade"} )
end

local function gotoExit()
    os.exit()    
end

-- funções do composer --
composer.recycleOnSceneChange = true;
function scene:create ( event )
    sceneGroup = self.view
    background = display.newImageRect( "Sprites/mainmenu.png", 570, 320)
    background.x = display.contentCenterX
    background.y = display.contentCenterY

    -- botão para iniciar game -- 
    start = display.newRect( 57, 235, 110, 45 )
    start.alpha = 0.01

    -- botão para abrir tutorial --
    tutorial = display.newRect( 183, 235, 110, 45 )
    tutorial.alpha = 0.01

    -- botão de créditos --
    credits = display.newRect( 305, 235, 110, 45 )
    credits.alpha = 0.01

    -- botão para fechar o jogo --
    exit = display.newRect(425, 235, 110, 45)
    exit.alpha = 0.01

    sceneGroup:insert(background)
    sceneGroup:insert(start)
    sceneGroup:insert(credits)
    sceneGroup:insert(tutorial)
    sceneGroup:insert(exit)
end

function scene:show( event )
    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
        credits:addEventListener( "tap", gotoCredits )
        start:addEventListener( "tap", gotoLevel )
        tutorial:addEventListener( "tap", gotoTutorial )
        exit:addEventListener( "tap", gotoExit )
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
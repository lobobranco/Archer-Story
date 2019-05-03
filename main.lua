local composer = require( "composer" )
display.setStatusBar( display.HiddenStatusBar )

audio.reserveChannels( 1 ) --Música do Menu
audio.reserveChannels( 2 ) --Música do GameOver
audio.reserveChannels( 3 ) --Música do Fácil
audio.reserveChannels( 4 ) --Música do Normal
audio.reserveChannels( 5 ) --Música do Difícil
audio.reserveChannels( 6 ) --Música do Mordor
audio.reserveChannels( 7 ) --Som da Flecha Esquerda
audio.reserveChannels( 8 ) --Som da Flecha Direita

menumusic = audio.loadSound( "soundtrack/menu.wav" )
audio.play( menumusic, {channel=1, loops=-1} )


composer.gotoScene ("mainmenu")
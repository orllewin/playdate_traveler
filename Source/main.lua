import 'CoreLibs/graphics'
import "CoreLibs/object"
import 'CoreLibs/sprites'
import 'CoreLibs/timer'
import 'CoracleViews/focus_manager'
import 'CoracleViews/label_left'
import 'CoracleViews/rotary_encoder_medium'
import 'AudioOut/droplet'
import 'AudioIn/source'

playdate.setCrankSoundsDisabled(true)

local graphics <const> = playdate.graphics
local inverted = true
playdate.display.setInverted(inverted)

graphics.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	playdate.graphics.fillRect(0, 0, 400, 240)
end)

local pixarlmed = graphics.font.new("Fonts/pixarlmed")
graphics.setFont(pixarlmed)

local source = Source()
source:start()

local droplets = {}

for i=1,10 do
	droplets[i] = Droplet("".. i)
	droplets[i]:reset()
end

local titleLabel = LabelLeft("Traveller", 6, 6, 0.4)

local focusManager = FocusManager()

local encoderXColumn1 = 75
local encoderYAnchor = 60
local encoderYSpacing = 50
local encoderWidth = 120

--(label, xx, yy, w, listener)
local rateEncoder = MediumRotaryEncoder("Rate", encoderXColumn1, encoderYAnchor, encoderWidth, function(value)
	--rate change
end)
focusManager:addView(rateEncoder, 1)

local attackEncoder = MediumRotaryEncoder("Attack", encoderXColumn1, encoderYAnchor + encoderYSpacing, encoderWidth, function(value)
	--attack change
end)
focusManager:addView(attackEncoder, 2)

local releaseEncoder = MediumRotaryEncoder("Release", encoderXColumn1, encoderYAnchor + (encoderYSpacing * 2), encoderWidth, function(value)
	--release change
end)
focusManager:addView(releaseEncoder, 3)

focusManager:start()
focusManager:push()



function playdate.update()
	for i=1,10 do
		droplets[i]:update()
	end
	
	playdate.graphics.sprite.update()
	playdate.timer:updateTimers()
	
	--See note in Source, flag checked here to trigger next sample record:
	if source:isRecording() == false then
		source:recordSample()
	end
end

local menu = playdate.getSystemMenu()
local invertMenuItem, error = menu:addMenuItem("Invert Display", function() 
	inverted = not inverted
	playdate.display.setInverted(inverted)
end)
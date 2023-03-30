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

local dropletCount = 10

for i=1,dropletCount do
	droplets[i] = Droplet("".. i)
	droplets[i]:reset()
end

local titleLabel = LabelLeft("Traveller", 6, 6, 0.4)

local focusManager = FocusManager()

local encoderXColumn1 = 75
local encoderXColumn2 = 210
local encoderYAnchor = 60
local encoderYSpacing = 50
local encoderWidth = 120

-- Column 1
local rateEncoder = MediumRotaryEncoder("Rate", encoderXColumn1, encoderYAnchor, encoderWidth, function(value)
	--rate change
	for i=1,dropletCount do
		droplets[i]:setRate(value)
	end
end)
focusManager:addView(rateEncoder, 1)

local attackEncoder = MediumRotaryEncoder("Attack", encoderXColumn1, encoderYAnchor + encoderYSpacing, encoderWidth, function(value)
	--attack change
	for i=1,dropletCount do
		droplets[i]:setAttack(value)
	end
end)
focusManager:addView(attackEncoder, 2)

local releaseEncoder = MediumRotaryEncoder("Release", encoderXColumn1, encoderYAnchor + (encoderYSpacing * 2), encoderWidth, function(value)
	--release change
	for i=1,dropletCount do
		droplets[i]:setRelease(value)
	end
end)
focusManager:addView(releaseEncoder, 3)

local driveEncoder = MediumRotaryEncoder("Drive", encoderXColumn1, encoderYAnchor + (encoderYSpacing * 3), encoderWidth, function(value)
	--Global overdrive:
	setDrive(value)
end)
focusManager:addView(driveEncoder, 4)

--Column 2
local delayLabel = LabelLeft("Delay", 150, 50, 0.4)
local delayLengthEncoder = MediumRotaryEncoder("Length", encoderXColumn2, encoderYAnchor + encoderYSpacing, encoderWidth, function(value)
	--delay length change
	setDelayLength(value)
end)
focusManager:addView(delayLengthEncoder, 2)

local delayFeedbackEncoder = MediumRotaryEncoder("FBack.", encoderXColumn2, encoderYAnchor + (encoderYSpacing * 2), encoderWidth, function(value)
	--delay feedback change
	setDelayFeedback(value)
end)
focusManager:addView(delayFeedbackEncoder, 3)

local delayLevelEncoder = MediumRotaryEncoder("Level", encoderXColumn2, encoderYAnchor + (encoderYSpacing * 3), encoderWidth, function(value)
	--delay level change
	setDelayLevel(value)
end)
focusManager:addView(delayLevelEncoder, 4)

--Column 3
local lowPassLabel = LabelLeft("Low Pass", 270, 50, 0.4)

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

------------------------------------------------------------------------------
--Effects

function setDrive(drive)
	print("Set drive to: " .. drive)
end

function setDelayLength(length)
	print("Set delay length to: " .. length)
end

function setDelayFeedback(feedback)
	print("Set delay feedback to: " .. feedback)
end

function setDelayLevel(level)
	print("Set delay level to: " .. level)
end
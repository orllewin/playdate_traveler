import 'CoreLibs/graphics'
import "CoreLibs/object"
import 'CoreLibs/sprites'
import 'CoreLibs/timer'
import 'Coracle/math'
import 'CoracleViews/focus_manager'
import 'CoracleViews/label_left'
import 'CoracleViews/rotary_encoder_medium'
import 'AudioOut/droplet'
import 'AudioIn/source'

playdate.setCrankSoundsDisabled(true)

local graphics <const> = playdate.graphics
local sound <const> = playdate.sound

globalSlots = 7

globalRate = 0.5
globalAttack = 0.2
globalRelease = 0.2

local inverted = true
playdate.display.setInverted(inverted)

graphics.sprite.setBackgroundDrawingCallback(function(x, y, width, height)
	playdate.graphics.setColor(playdate.graphics.kColorWhite)
	playdate.graphics.fillRect(0, 0, 400, 240)
end)

local pixarlmed = graphics.font.new("Fonts/pixarlmed")
graphics.setFont(pixarlmed)

local droplets = {}

local dropletCount = 5

for i=1,dropletCount do
	droplets[i] = Droplet("".. i)
	droplets[i]:reset()
end

-- Effects --------------------------------------------------------------------------------
local globalDriveAmount = 0.0
local globalDelayDebounce = nil
local globalDelayBlocked = false

local maxDelay = 2.5
local globalDelayLength = 0.25
local globalDelayLevel = 0.35
local globalDelayFeedback = 0.35

local globalLowPassFrequency = 0.8
local globalLowPassRes = 0.2

--Hi pass: not user configurable:
local highpass = playdate.sound.twopolefilter.new(playdate.sound.kFilterHighPass)
highpass:setMix(1.0)
highpass:setFrequency(60)
highpass:setResonance(0.0)
playdate.sound.addEffect(highpass)

local globalDelay = sound.delayline.new(map(globalDelayLength, 0.0, 1.0, 0.0, maxDelay))
globalDelay:setFeedback(globalDelayFeedback)
globalDelay:setMix(0.0)
playdate.sound.addEffect(globalDelay)

local globalBitcrusher = playdate.sound.bitcrusher.new()
globalBitcrusher:setAmount(0.30)
globalBitcrusher:setUndersampling(0.55)
globalBitcrusher:setMix(globalDriveAmount)
playdate.sound.addEffect(globalBitcrusher)


local overdrive = playdate.sound.overdrive.new()
overdrive:setGain(0.0)
overdrive:setLimit(0.9)
overdrive:setMix(globalDriveAmount)
playdate.sound.addEffect(overdrive)

local lowpass = playdate.sound.twopolefilter.new(playdate.sound.kFilterLowPass)
lowpass:setMix(1.0)
lowpass:setFrequency(map(globalLowPassFrequency, 0.0, 1.0, 100, 10000))
lowpass:setResonance(globalLowPassRes)
playdate.sound.addEffect(lowpass)



function setRate(rate)
	globalRate = rate
	for i=1,dropletCount do
		droplets[i]:setRate(globalRate)
	end
end

function setAttack(attack)
	globalAttack = attack
	for i=1,dropletCount do
		droplets[i]:setAttack(value)
	end
end

function setRelease(release)
	globalRelease = release
	for i=1,dropletCount do
		droplets[i]:setRelease(value)
	end
end

function setDelayLength(length)
	
	if globalDelayBlocked then return end
	
	globalDelayBlocked = true
	globalDelayLength = length
	local mappedDelay = map(globalDelayLength, 0.0, 1.0, 0.1, maxDelay)
	print("Set delay length to: " .. length .. " mapped: " .. mappedDelay)
	playdate.sound.removeEffect(globalDelay)
	globalDelay = sound.delayline.new(mappedDelay)
	globalDelay:setFeedback(globalDelayFeedback)
	globalDelay:setMix(globalDelayLevel/2.0)
	playdate.sound.addEffect(globalDelay)
	
	globalDelayDebounce = playdate.timer.new(200, function()
		globalDelayBlocked = false
	end)
end

function setDelayFeedback(feedback)
	print("Set delay feedback to: " .. feedback)
	globalDelayFeedback = feedback
	globalDelay:setFeedback(globalDelayFeedback)
end

function setDelayLevel(level)
	print("Set delay level to: " .. level)
	globalDelayLevel = level
	globalDelay:setMix(globalDelayLevel/2.0)
end

function setDrive(drive)
	print("Drive: " .. drive)
	globalDriveAmount = drive
	globalBitcrusher:setMix(globalDriveAmount/2)
	globalBitcrusher:setAmount(globalDriveAmount*0.9)
	globalBitcrusher:setUndersampling(globalDriveAmount*0.9)
	
	overdrive:setGain(globalDriveAmount*3)
	overdrive:setMix(globalDriveAmount/2)
end

-- EO Effects -----------------------------------------------------------------------------

local source = Source()
source:start()

local titleLabel = LabelLeft("Traveller", 6, 6, 0.4)

local focusManager = FocusManager()

local encoderXColumn1 = 73
local encoderXColumn2 = 205
local encoderXColumn3 = 335
local encoderYAnchor = 60
local encoderYSpacing = 50
local encoderWidth = 115

-- Column 1
local rateEncoder = MediumRotaryEncoder("Rate", encoderXColumn1, encoderYAnchor, encoderWidth, function(value)
	--rate change
	setRate(value)
end)
rateEncoder:setValue(globalRate)
focusManager:addView(rateEncoder, 1)

local attackEncoder = MediumRotaryEncoder("Attack", encoderXColumn1, encoderYAnchor + encoderYSpacing, encoderWidth, function(value)
	--attack change
	for i=1,dropletCount do
		droplets[i]:setAttack(value)
	end
end)
attackEncoder:setValue(globalAttack)
focusManager:addView(attackEncoder, 2)

local releaseEncoder = MediumRotaryEncoder("Release", encoderXColumn1, encoderYAnchor + (encoderYSpacing * 2), encoderWidth, function(value)
	--release change
	for i=1,dropletCount do
		droplets[i]:setRelease(value)
	end
end)
releaseEncoder:setValue(globalRelease)
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
delayLengthEncoder:setValue(globalDelayLength)
focusManager:addView(delayLengthEncoder, 2)

local delayFeedbackEncoder = MediumRotaryEncoder("FBack.", encoderXColumn2, encoderYAnchor + (encoderYSpacing * 2), encoderWidth, function(value)
	--delay feedback change
	setDelayFeedback(value)
end)
delayFeedbackEncoder:setValue(globalDelayFeedback)
focusManager:addView(delayFeedbackEncoder, 3)

local delayLevelEncoder = MediumRotaryEncoder("Level", encoderXColumn2, encoderYAnchor + (encoderYSpacing * 3), encoderWidth, function(value)
	--delay level change
	setDelayLevel(value)
end)
delayLevelEncoder:setValue(globalDelayLevel)
focusManager:addView(delayLevelEncoder, 4)

--Column 3
local lowPassLabel = LabelLeft("Low Pass", 273, 50, 0.4)

local lowPassFreqEncoder = MediumRotaryEncoder("Freq.", encoderXColumn3, encoderYAnchor + encoderYSpacing, encoderWidth, function(value)
 	globalLowPassFrequency = value
	lowpass:setFrequency(map(globalLowPassFrequency, 0.0, 1.0, 100, 10000))
end)
lowPassFreqEncoder:setValue(globalLowPassFrequency)
focusManager:addView(lowPassFreqEncoder, 2)

local lowPassResEncoder = MediumRotaryEncoder("Res.", encoderXColumn3, encoderYAnchor + (encoderYSpacing * 2), encoderWidth, function(value)
	globalLowPassRes = value
	lowpass:setResonance(globalLowPassRes)
end)
lowPassResEncoder:setValue(globalLowPassRes)
focusManager:addView(lowPassResEncoder, 3)

focusManager:start()
focusManager:push()



function playdate.update()
	for i=1,dropletCount do
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

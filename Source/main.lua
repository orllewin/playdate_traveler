import "CoreLibs/object"
import 'CoreLibs/timer'
import 'AudioOut/droplet'
import 'AudioIn/source'

local source = Source()
source:start()

local droplets = {}

for i=1,10 do
	droplets[i] = Droplet("".. i)
	droplets[i]:reset()
end

function playdate.update()
	for i=1,10 do
		droplets[i]:update()
	end
	
	playdate.timer:updateTimers()
	
	--See note in Source, flag checked here to trigger next sample record:
	if source:isRecording() == false then
		source:recordSample()
	end
end
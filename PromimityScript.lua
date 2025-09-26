local TweenService = game:GetService("TweenService") -- TweenService (Animation service)

local container = script.Parent.Parent -- the container model Declared	
local doorLeft = container:WaitForChild("Door Left") -- left door Delcared
local doorRight = container:WaitForChild("Door Right") -- right door Delcared
local prompt = script.Parent:WaitForChild("ProximityPrompt") -- the prompt Delcared

local tweenTime = 0.3 -- time for each door to slide

local centerVector = (doorRight.Position - doorLeft.Position).Unit -- get the vector between the two doors


local slideDistance = 5 -- distance each door slides

local closedLeftPos = doorLeft.Position -- get the position of the left door
local closedRightPos = doorRight.Position -- get the position of the right door


local leftOpenPos = closedLeftPos - centerVector * slideDistance -- get the position of the left door when it opens
local rightOpenPos = closedRightPos + centerVector * slideDistance -- get the position of the right door when it opens

local busy = false -- prevent spamming

local function tweenDoor(part, targetPos) -- function to tween the doors
	local tweenInfo = TweenInfo.new(tweenTime, Enum.EasingStyle.Sine, Enum.EasingDirection.Out) -- tween info (Animation info)
	local tween = TweenService:Create(part, tweenInfo, {Position = targetPos}) -- tween (animation)
	tween:Play() -- play the tween (animation)
	tween.Completed:Wait() -- wait for the tween to finish (animation to finish)
end

prompt.Triggered:Connect(function(player) -- when the prompt is triggered
	if busy then return end 
	busy = true -- prevent spamming

	-- Only open doors (no closing)
	tweenDoor(doorLeft, leftOpenPos) -- animate the left door
	tweenDoor(doorRight, rightOpenPos) -- animate the right door
	prompt.Enabled = false -- disable the prompt after opening

	busy = false -- allow opening again
end)

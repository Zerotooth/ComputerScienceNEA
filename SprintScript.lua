-- Declarations
local Player = game.Players.LocalPlayer -- declares game players to a local base
local Character = Player.Character or Player.CharacterAdded:Wait() -- waits for a Playble charecter to join or be added to server
local Humanoid = Character:WaitForChild("Humanoid") -- waits for a player

--  Update Character and Humanoid when player respawns
Player.CharacterAdded:Connect(function(newCharacter) -- When player respawns
	Character = newCharacter -- Sets the new character
	Humanoid = newCharacter:WaitForChild("Humanoid") -- Sets the new Humanoid
end)

-- Stamina system
local maxStamina = 100 -- Sets the maximum server
local stamina = maxStamina -- sets each players Current stamina
local drainRate = 1       -- stamina lost per 0.1s while sprinting (10s sprint max)
local regenRate = 0.5     -- stamina regained per 0.1s (half second sprint per second not sprinting)
local sprintSpeed = 40 -- speed of sprinting
local walkSpeed = 16 -- Speed of walking

local UIS = game:GetService("UserInputService") -- User input service
local RS = game:GetService("RunService") -- Run service

local sprinting = false -- Sprinting status at start is false

-- Check if player is holding Left Shift
UIS.InputBegan:Connect(function(input, gpe) -- When player presses a key
	if gpe then return end 
	if input.KeyCode == Enum.KeyCode.LeftShift then -- Check if it was left shift
		if stamina > 0 then -- If player has stamina
			sprinting = true -- Start sprinting
			Humanoid.WalkSpeed = sprintSpeed -- make their speed the sprinting speed
		end
	end
end)

UIS.InputEnded:Connect(function(input) -- When player lets go of a key
	if input.KeyCode == Enum.KeyCode.LeftShift then -- Check if it was left shift
		sprinting = false -- Stop sprinting
		Humanoid.WalkSpeed = walkSpeed -- Set speed to normal walking speed
	end 
end)

-- Update loop
RS.Heartbeat:Connect(function(dt) -- code run every frame to check
	if sprinting and stamina > 0 then -- If stamina is availavle
		stamina = math.max(stamina - drainRate, 0) -- Take away stamina each frame by the drain rate
		if stamina <= 0 then -- If runout of stamina
			sprinting = false -- Stop sprinting
			Humanoid.WalkSpeed = walkSpeed -- Set speed to normal walking speed
		end
	else
		-- Regenerate stamina if not sprinting
		stamina = math.min(stamina + regenRate, maxStamina) -- When they are not sprinting regenerate their stamina up to the maximum 100
	end
end)

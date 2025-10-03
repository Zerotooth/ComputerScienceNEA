local Players = game:GetService("Players") -- Get the Players service
local Teams = game:GetService("Teams") -- Get the Teams service

local kingsTeam = Teams:FindFirstChild("King's") -- Find the "Kings" team
local playersTeam = Teams:FindFirstChild("Players") -- Find the "Players" team
local lobbyTeam = Teams:FindFirstChild("Lobby") -- Find the "Lobby" team

local kingsSpawn = workspace:FindFirstChild("KingsSpawn") -- Find the spawn parts
local playersSpawn = workspace:FindFirstChild("PlayersSpawn") -- Find the spawn parts
local lobbySpawn = workspace:FindFirstChild("LobbySpawn") -- Find the spawn parts

local function moveToTeam(player, team, spawnPart) -- Function to move player to team and spawn
	player.Team = team -- Set player's team
	if player.Character and player.Character:FindFirstChild("HumanoidRootPart") then -- Move player to spawn
		player.Character.HumanoidRootPart.CFrame = spawnPart.CFrame + Vector3.new(0,3,0) -- Move player to spawn
	end
end


local function setupCharacter(player, character) -- Setup death listener
	local humanoid = character:WaitForChild("Humanoid") -- Wait for humanoid
	humanoid.Died:Connect(function() -- When player dies
		player.Team = lobbyTeam -- Set player's team
		player.CharacterAdded:Connect(function(newChar) -- When player respawns
			newChar:WaitForChild("HumanoidRootPart").CFrame = lobbySpawn.CFrame + Vector3.new(0,3,0) -- Move player to spawn
		end)
	end)
end


local function startRound() -- Start round
	local players = Players:GetPlayers() -- Get all players
	local toggle = true -- Alternate between teams

	for _, player in ipairs(players) do -- Loop through players
		if player.Team == lobbyTeam then -- only assign lobby players
			if toggle then -- Alternate between teams
				moveToTeam(player, kingsTeam, kingsSpawn) -- Move player to Kings team and spawn
			else 
				moveToTeam(player, playersTeam, playersSpawn) -- Move player to Players team and spawn
			end
			toggle = not toggle -- Disable toggle for next player
		end
	end
end


local function endRound() -- End round
	for _, player in ipairs(Players:GetPlayers()) do -- Loop through players
		moveToTeam(player, lobbyTeam, lobbySpawn) -- Move player to Lobby team and spawn
	end
end


Players.PlayerAdded:Connect(function(player) -- When player joins
	player.CharacterAdded:Connect(function(char) -- Setup death listener
		setupCharacter(player, char) -- Setup death listener
	end)
end)


while true do
	-- Lobby Stage
	print("Lobby phase...")
	task.wait(10)

	-- Start round
	print("Round starting...")
	startRound()

	-- Let round run for 60s
	task.wait(60)

	-- End round
	print("Round ending, back to lobby...")
	endRound()
end

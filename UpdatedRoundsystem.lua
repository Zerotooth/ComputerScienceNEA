local Players = game:GetService("Players") -- Get Players
local Teams = game:GetService("Teams") -- Get Teams

print('ROUND SCRIPT LOADED') -- Check that script is loaded

-- Exact team names
local kingsTeam = Teams:WaitForChild("King's") -- Get King teams
local playersTeam = Teams:WaitForChild("Players") -- Get Players team
local lobbyTeam = Teams:WaitForChild("Lobby") -- Get Lobby team

print("Teams:", kingsTeam.Name, playersTeam.Name, lobbyTeam.Name) -- Check team names loaded

local kingsSpawn = workspace:WaitForChild("KingsSpawn") -- Get spawn parts for kings
local playersSpawn = workspace:WaitForChild("PlayersSpawn") -- Get spawn parts for players
local lobbySpawn = workspace:WaitForChild("LobbySpawn") -- Get spawn parts for lobby

print("Spawns ready") -- Check spawns loaded

local function teleportToTeamSpawn(player) -- Teleport player to their team's spawn
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then -- Check if player has character and HRP
		print("teleport skipped:", player.Name, "- no HRP") -- No HRP, skip teleport
		return
	end
	local spawnPart = lobbySpawn -- Default to lobby spawn
	if player.Team == kingsTeam then spawnPart = kingsSpawn -- Kings spawn
	elseif player.Team == playersTeam then spawnPart = playersSpawn end -- Players spawn
	player.Character.HumanoidRootPart.CFrame = spawnPart.CFrame + Vector3.new(0, 3, 0) -- Teleport to spawn
	print("Teleported", player.Name, "→", player.Team.Name) -- Check telports worked
end

local function moveToTeam(player, team) -- Move player to team and teleport
	player.Team = team -- Move to team
	teleportToTeamSpawn(player) -- Teleport to new team spawn
end

local function setupPlayer(player) -- Setup player on join
	print("Setup:", player.Name, "to Lobby") -- Move to lobby
	player.Team = lobbyTeam -- Move to lobby

	player.CharacterAdded:Connect(function(character) -- Wait for character to load
		task.wait(0.1) -- wait 0.1 seconds
		character:WaitForChild("HumanoidRootPart") -- Wait for HRP
		teleportToTeamSpawn(player) -- Teleport to lobby spawn
	end)

	player.CharacterAdded:Connect(function(character) -- Wait for humanoid to load
		local humanoid = character:WaitForChild("Humanoid") -- Wait for humanoid
		humanoid.Died:Connect(function() -- On death, move to lobby
			print("Death", player.Name, "died → Lobby") -- Output that a player has been moved
			player.Team = lobbyTeam -- Move to lobby
		end)
	end)
end


local function splitTeamPoints() -- Split 10k points between players on each team
	local TEAM_POINTS = 10000 -- Total points to split
	print("10k given per team") -- Check function has started

	for _, team in ipairs({kingsTeam, playersTeam}) do -- Loop through teams
		local teamPlayers = {} -- Create a list of players
		for _, p in ipairs(Players:GetPlayers()) do -- Loop through all players
			if p.Team == team then table.insert(teamPlayers, p) end -- Add players to team list
		end
		local count = #teamPlayers -- Get number of players on team
		print(team.Name, "team:", count, "players") -- Output number of players

		if count > 0 then -- If greater than 0
			local perPlayer = math.floor(TEAM_POINTS / count) -- Calculate points per player
			local extra = TEAM_POINTS % count -- Calculate extra points
			for i, p in ipairs(teamPlayers) do -- Loop through players
				local stats = p:FindFirstChild("leaderstats") -- Find leaderstats
				if stats then -- If leaderstats exists
					local pts = stats:FindFirstChild("Points") -- Find Points
					if pts then -- If Points exists
						local added = perPlayer + (i==1 and extra or 0) -- Add extra points to first player
						pts.Value += added -- Add points
						print("Success", p.Name, "got", added, "→ total:", pts.Value) -- Output success
					else print("Fail", p.Name, "missing Points") end -- Output failure
				else print("Fail", p.Name, "missing leaderstats") end -- Output failure
			end
		else print(team.Name, "- empty") end -- Output empty team
	end
	print("Individual Points assigned") -- Output completion
end


local function resetPoints() -- Reset all players' Points to 0
	print("Resetting players points") -- Output reset start
	local resetCount = 0 -- What points to be set to
	for _, player in ipairs(Players:GetPlayers()) do -- Loop through all players
		local leaderstats = player:FindFirstChild("leaderstats") -- Find leaderstats
		if leaderstats then -- If leaderstats exists
			local points = leaderstats:FindFirstChild("Points") -- Find Points
			if points then -- If Points exists
				points.Value = 0 -- Set Points to 0
				print("Reset", player.Name, "→ 0") -- Output reset
				resetCount += 1 -- Count reset
			end
		end
	end
	print("RESET", resetCount, "players\n") -- Output reset completion
end

local function startRound() -- START GAME
	print("ROUND START") -- Output start
	local lobbyCount = 0 -- Lobby count
	local lobbyPlayers = {} -- Lobby players
	for _, p in ipairs(Players:GetPlayers()) do -- Loop through all players
		if p.Team == lobbyTeam then -- If in lobby team
			table.insert(lobbyPlayers, p) -- Add to lobby list
			lobbyCount += 1 -- Count lobby
		end
	end
	print("Lobby ready:", lobbyCount) -- Output lobby count

	local toggle = true -- Alternate teams
	for _, p in ipairs(lobbyPlayers) do -- Loop through lobby players
		moveToTeam(p, toggle and kingsTeam or playersTeam) -- Move to team
		toggle = not toggle -- Alternate teams
	end

	splitTeamPoints() -- Assign points to teams
end

local function endRound() -- END GAME
	print(" ROUND END ") -- Output end 
	for _, p in ipairs(Players:GetPlayers()) do -- Loop through all players
		moveToTeam(p, lobbyTeam) -- Move to lobby
	end
	task.wait(0.5)  -- Let teleports finish
	resetPoints()   -- Clear points
end

-- Setup everyone
for _, p in ipairs(Players:GetPlayers()) do setupPlayer(p) end -- Setup existing players
Players.PlayerAdded:Connect(setupPlayer) -- Setup new players

print("System ready") -- Output ready

-- LOOP
while true do -- Main loop
	print("LOBBY period 10s") -- Lobby period
	task.wait(10) -- 10s lobby
	startRound() -- Start round
	print("Round perido 60s") -- Round period
	task.wait(60) -- 60s round
	endRound() -- End round
	print(" Next round starting soon") -- Next round
end

local Players = game:GetService("Players")
local Teams = game:GetService("Teams")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Music
local music1 = workspace.LobbyMusic
local music2 = workspace.GameMusic

print("ROUND SCRIPT LOADED")

-- Teams (with safe fallback if missing)
local kingsTeam   = Teams:FindFirstChild("King's")   or warn("King's team MISSING")
local playersTeam = Teams:FindFirstChild("Players")  or warn("Players team MISSING")
local lobbyTeam   = Teams:FindFirstChild("Lobby")    or warn("Lobby team MISSING")

if not kingsTeam or not playersTeam or not lobbyTeam then
	warn("One or more teams are missing! Script will partially fail.")
end

print("Teams:", 
	kingsTeam   and kingsTeam.Name   or "MISSING",
	playersTeam and playersTeam.Name or "MISSING",
	lobbyTeam   and lobbyTeam.Name   or "MISSING"
)

-- Spawns
local kingsSpawn  = workspace:FindFirstChild("KingsSpawn")  or warn("KingsSpawn MISSING")
local playersSpawn = workspace:FindFirstChild("PlayersSpawn") or warn("PlayersSpawn MISSING")
local lobbySpawn  = workspace:FindFirstChild("LobbySpawn")   or warn("LobbySpawn MISSING")

if not kingsSpawn or not playersSpawn or not lobbySpawn then
	warn("One or more spawns are missing!")
end
print("Spawns ready")

-- Events
local resetPointStationsEvent = ReplicatedStorage:FindFirstChild("ResetPointStationsEvent")
local closeDoorsEvent         = ReplicatedStorage:FindFirstChild("CloseDoorsEvent")

if not resetPointStationsEvent then warn("ResetPointStationsEvent MISSING") end
if not closeDoorsEvent         then warn("CloseDoorsEvent MISSING") end

local function teleportToTeamSpawn(player)
	if not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
		print("teleport skipped:", player.Name, "- no HRP")
		return
	end

	local spawnPart = lobbySpawn
	if player.Team == kingsTeam then
		spawnPart = kingsSpawn
	elseif player.Team == playersTeam then
		spawnPart = playersSpawn
	end

	if spawnPart then
		player.Character.HumanoidRootPart.CFrame = spawnPart.CFrame + Vector3.new(0, 3, 0)
		print("Teleported", player.Name, "→", player.Team and player.Team.Name or "No team")
	else
		warn("No valid spawn for", player.Name)
	end
end

local function moveToTeam(player, team)
	player.Team = team
	teleportToTeamSpawn(player)
end

local function setupPlayer(player)
	print("Setup:", player.Name, "→ Lobby")
	player.Team = lobbyTeam

	player.CharacterAdded:Connect(function(character)
		task.wait(0.1)
		character:WaitForChild("HumanoidRootPart")
		teleportToTeamSpawn(player)
	end)

	player.CharacterAdded:Connect(function(character)
		local humanoid = character:WaitForChild("Humanoid")
		humanoid.Died:Connect(function()
			print("Death:", player.Name, "→ Lobby")
			player.Team = lobbyTeam
		end)
	end)
end

local function splitTeamPoints()
	local TEAM_POINTS = 10000
	print("Awarding 10k per team")

	for _, team in ipairs({kingsTeam, playersTeam}) do
		if not team then continue end

		local teamPlayers = {}
		for _, p in ipairs(Players:GetPlayers()) do
			if p.Team == team then
				table.insert(teamPlayers, p)
			end
		end

		local count = #teamPlayers
		print(team.Name, "team:", count, "players")

		if count > 0 then
			local perPlayer = math.floor(TEAM_POINTS / count)
			local extra = TEAM_POINTS % count
			for i, p in ipairs(teamPlayers) do
				local stats = p:FindFirstChild("leaderstats")
				if stats then
					local pts = stats:FindFirstChild("Points")
					if pts then
						local added = perPlayer + (i == 1 and extra or 0)
						pts.Value += added
						print("→", p.Name, "got", added, "(total:", pts.Value, ")")
					else
						warn(p.Name, "missing Points")
					end
				else
					warn(p.Name, "missing leaderstats")
				end
			end
		else
			print(team.Name, "- empty")
		end
	end
	print("Points assigned")
end

local function resetBases()
	print("Resetting capture bases...")

	local kingsBase   = workspace:FindFirstChild("KingsBase")
	local playersBase = workspace:FindFirstChild("PlayersBase")

	if kingsBase then
		local current = kingsBase:FindFirstChild("CurrentPoints")
		local maxVal  = kingsBase:FindFirstChild("MaxPoints")
		local active  = kingsBase:FindFirstChild("IsActive")

		if current and maxVal then
			current.Value = maxVal.Value
			print("KingsBase reset to", current.Value)
		else
			warn("KingsBase missing CurrentPoints or MaxPoints")
		end
		if active then active.Value = true end
		kingsBase.Color = Color3.fromRGB(0, 255, 0)
	else
		warn("KingsBase not found")
	end

	if playersBase then
		local current = playersBase:FindFirstChild("CurrentPoints")
		local maxVal  = playersBase:FindFirstChild("MaxPoints")
		local active  = playersBase:FindFirstChild("IsActive")

		if current and maxVal then
			current.Value = maxVal.Value
			print("PlayersBase reset to", current.Value)
		else
			warn("PlayersBase missing CurrentPoints or MaxPoints")
		end
		if active then active.Value = true end
		playersBase.Color = Color3.fromRGB(0, 255, 0)
	else
		warn("PlayersBase not found")
	end

	print("Bases reset complete")
end

local function calculateRoundResults()
	local kingsTotal = 0
	local playersTotal = 0
	local mvpPlayer = nil
	local maxPoints = -1

	for _, p in ipairs(Players:GetPlayers()) do
		if p.Team ~= lobbyTeam then
			local stats = p:FindFirstChild("leaderstats")
			if stats then
				local pts = stats:FindFirstChild("Points")
				if pts then
					local points = pts.Value
					if p.Team == kingsTeam then
						kingsTotal += points
					elseif p.Team == playersTeam then
						playersTotal += points
					end

					if points > maxPoints then
						maxPoints = points
						mvpPlayer = p
					end
				end
			end
		end
	end

	print("Round results → King's:", kingsTotal, "| Players:", playersTotal, "| MVP:", mvpPlayer and mvpPlayer.Name or "None", "("..maxPoints..")")

	local winnerTeam = "TIE"
	if kingsTotal > playersTotal then
		winnerTeam = kingsTeam.Name
	elseif playersTotal > kingsTotal then
		winnerTeam = playersTeam.Name
	end

	local gui = workspace:FindFirstChild("Results Screen")
	if gui then
		local sg = gui:FindFirstChild("SurfaceGui")
		if sg then
			local f = sg:FindFirstChild("Frame")
			if f then
				local teamtxt = f:FindFirstChild("Teamtxt")
				local mvptxt  = f:FindFirstChild("Mvptxt")
				if teamtxt then teamtxt.Text = winnerTeam end
				if mvptxt then mvptxt.Text = mvpPlayer and mvpPlayer.Name or "None" end
				print("GUI updated → Winner:", winnerTeam, "| MVP:", mvptxt and mvptxt.Text or "None")
			end
		end
	else
		warn("Results Screen not found in workspace")
	end
end

local function resetPoints()
	print("Resetting all points...")
	local count = 0
	for _, p in ipairs(Players:GetPlayers()) do
		local ls = p:FindFirstChild("leaderstats")
		if ls then
			local pts = ls:FindFirstChild("Points")
			if pts then
				pts.Value = 0
				count += 1
				print("Reset", p.Name, "→ 0")
			end
		end
	end
	print("RESET", count, "players")
end

local function startRound()
	print("ROUND START")
	local lobbyPlayers = {}
	for _, p in ipairs(Players:GetPlayers()) do
		if p.Team == lobbyTeam then
			table.insert(lobbyPlayers, p)
		end
	end
	print("Lobby players found:", #lobbyPlayers)

	local toggle = true
	for _, p in ipairs(lobbyPlayers) do
		moveToTeam(p, toggle and kingsTeam or playersTeam)
		toggle = not toggle
	end

	splitTeamPoints()
	if resetPointStationsEvent then resetPointStationsEvent:Fire() end
	print("Point stations reset")
end

local function endRound()
	print("ROUND END")
	calculateRoundResults()

	for _, p in ipairs(Players:GetPlayers()) do
		moveToTeam(p, lobbyTeam)
	end

	task.wait(0.5)
	resetPoints()
	resetBases()

	if closeDoorsEvent then closeDoorsEvent:Fire() end
	print("Doors closed")
end

-- Setup
for _, p in ipairs(Players:GetPlayers()) do
	setupPlayer(p)
end
Players.PlayerAdded:Connect(setupPlayer)

print("System ready")

-- Main loop
while true do
	music1:Play()
	print("LOBBY (10s)")
	task.wait(10)
	music1:Stop()
	startRound()
	music2:Play()
	print("ROUND (180s)")
	task.wait(180)  -- ← you had 60, but comment said 3 min → fixed to 180
	music2:Stop()
	endRound()
	print("Next round soon")
end

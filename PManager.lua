local PManager = {}

--Variables that hold paths to different objects
--ServerStorage
local ServerStorage = game:GetService("ServerStorage")
local PlayerItems = ServerStorage:FindFirstChild("PlayerItems")
local NameGUI = PlayerItems:FindFirstChild("NameGUI")
--Players
local Players = game:GetService("Players")
--Teams
local Teams = game:GetService("Teams")
local Playing = Teams:FindFirstChild("Playing")
local Eliminated = Teams:FindFirstChild("Eliminated")

--Functions
function PManager.speedZero(player)
	--Speeds players to zero and removes jumping.
	local character = game.Workspace:WaitForChild(player.Name)
	local Humanoid = character:WaitForChild("Humanoid")
	Humanoid.WalkSpeed = 0
	Humanoid.JumpPower = 0
end

function PManager.speedOn(player)
	--Speeds players back to 16 and allows jumping.
	local character = game.Workspace:WaitForChild(player.Name)
	local Humanoid = character:WaitForChild("Humanoid")
	Humanoid.WalkSpeed = 16
	Humanoid.JumpPower = 50
end

--[[
function PManager.isHere(playerTable)
	--Checks if players are still in the game.
	for i = 1, #playerTable, 1 do
		if Players:IsAncestorOf(playerTable[i]) == false then
			print(playerTable[i].Name .. " Left the game")
			playerTable[i] = nil
		end
	end
end
]]--

function PManager.isHere(playerTable)
	playerTable = Playing:GetPlayers()
end

function PManager.teleportPlayers(playerTable, teleportTable)
	for i = 1, #playerTable, 1 do
		if playerTable[i] ~= nil then
			local playerModel = game.Workspace:WaitForChild(playerTable[i].Name)
			playerModel:MoveTo(teleportTable[1].Position)
			table.remove(teleportTable, 1)
		end
	end
end

function PManager.nameGUI(player)
	--Check if the player already has a name tag prevents lag
	local playerWork = game.Workspace[player.Name]
	local Humanoid = playerWork:FindFirstChild("Humanoid")
	Humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	--Gives all players the nameGUI above their avatar
	if player:GetAttribute("NameTag") == false then
		local clonedGUI = NameGUI:Clone()
		clonedGUI.Parent = game.Workspace[player.Name].Head
		clonedGUI.Name = "NameDisplay"
		local CharacterName = player:GetAttribute("CharacterName")
		if CharacterName == nil then
			clonedGUI.TextLabel.Text = player.Name
		else
			clonedGUI.TextLabel.Text = CharacterName
		end
		player:SetAttribute("NameTag", true)
	else
		local clonedGUI = game.Workspace[player.Name].Head.NameDisplay
		local CharacterName = player:GetAttribute("CharacterName")
		if CharacterName == nil then
			clonedGUI.TextLabel.Text = player.Name
		else
			clonedGUI.TextLabel.Text = CharacterName
		end
	end
end

function PManager.applyFunction(playerTable, funcName)
	--Apply a functions to each player inside of the given table.
	for i = 1, #playerTable, 1 do
		if playerTable[i] ~= nil then
			funcName(playerTable[i])
		end
	end
end

function PManager.updateTeam(player, newTeam)
	player.TeamColor = newTeam.TeamColor
end

function PManager.sitPlayer(player)
	player.Character.Humanoid.Sit = true
end

--Event Fired Functions
Players.PlayerAdded:Connect(function(player)
	player.CharacterAdded:Connect(function(character)
		character:WaitForChild("Humanoid").Died:Connect(function()
			wait(6)
			player:SetAttribute("NameTag", false)
			PManager.nameGUI(player)
		end)
	end)
end)
Players.PlayerAdded:Connect(function(player)
	wait(1)
	player:SetAttribute("NameTag", false)
	PManager.nameGUI(player)
end)

return PManager

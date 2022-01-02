local killerMenu = {}
--Used the Roblox API

--Variables that hold paths to different objects
--ServerStorage
local ServerStorage = game:GetService("ServerStorage")
local GUIStorage = ServerStorage:FindFirstChild("GUIStorage")
local Kill = GUIStorage:FindFirstChild("Kill")
local killSelectUI = GUIStorage:FindFirstChild("killSelect")
--ReplicatedStorage
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvents = ReplicatedStorage:FindFirstChild("remoteEvents")
local killEvent = remoteEvents:FindFirstChild("killEvent")
--Teams
local Teams = game:GetService("Teams")
local Playing = Teams:FindFirstChild("Playing")
local Eliminated = Teams:FindFirstChild("Eliminated")
--Players
local Players = game:GetService("Players")

--Functions
function killerMenu.killerReset()
	--Reset Killer
	killer = nil
end

function killerMenu.sendGui(player)
	--Send the kill button to all players.
	local killGUIClone = Kill:Clone()
	killGUIClone.Parent = player.PlayerGui
end

function killerMenu.removeGui(player)
	--Remove the gui from players and return the player who clicked it.
	killEvent:FireAllClients()
	killer = player
end

function killerMenu.returnKiller()
	--Returns the killer's player instance
	return killer
end

function killerMenu.killSelectGui(player)
	local killSelectUIClone = killSelectUI:Clone()
	local playerTable = Playing:GetPlayers()
	--Remove the killer from the player tab
	for i = 1, #playerTable, 1 do
		if playerTable[i] == player then
			table.remove(playerTable, i)
		end
	end
	--Update the buttons of killSelectUIClone
	local buttonsTable = killSelectUIClone:FindFirstChild("Frame"):FindFirstChild("Buttons"):GetChildren()
	for i = 1, #playerTable, 1 do
		if playerTable[i] ~= nil then
			local BTN = buttonsTable[i]
			BTN.Text = playerTable[i]:GetAttribute("CharacterName")
			BTN.Visible = true
		end
	end
	--Put the GUI in the player's gui
	killSelectUIClone.Parent = player.PlayerGui
end

function killerMenu.receiveKill(player, selection)
	local playerTable = Playing:GetPlayers()
	for index, player in ipairs(playerTable) do
		local playerCharacter = player:GetAttribute("CharacterName")
		if playerCharacter == selection then
			selectedPlayer = player
		end
	end
end

function killerMenu.returnTarget()
	--Return the target
	return selectedPlayer
end

function killerMenu.randomKill()
	local playerTable = Playing:GetPlayers()
	--Remove killer
	for index, player in ipairs(playerTable) do
		if player == killer then
			table.remove(playerTable, index)
		end
	end
	--Select a random kill
	local randNum = math.random(1, #playerTable)
	selectedPlayer = playerTable[randNum]
	return selectedPlayer
end

return killerMenu

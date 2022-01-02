local CharacterMenu = {}

--Variables that hold paths to different objects
--ServerStorage
local ServerStorage = game:GetService("ServerStorage")
local ValueTags = ServerStorage:FindFirstChild("ValueTags")
local GUIStorage = ServerStorage:FindFirstChild("GUIStorage")
local PlayerItems = ServerStorage:FindFirstChild("PlayerItems")
local NameGUI = PlayerItems:FindFirstChild("NameGUI")
local HumanoidDesc = ServerStorage:FindFirstChild("HumanoidDesc")
--ReplicatedStorage
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvents = ReplicatedStorage:FindFirstChild("remoteEvents")
local characterSelect = remoteEvents:FindFirstChild("characterSelect")
--Players
local Players = game:GetService("Players")

--Table
AvaliableCharacters = {}

--Functions
function CharacterMenu.sendMenu(player)
	--This function sends player the selection menu
	local MenuClone = GUIStorage:FindFirstChild("CharacterMenu"):Clone()
	MenuClone.Parent = player.PlayerGui
	--Give character attribute
	player:SetAttribute("CharacterName", "")
end


function CharacterMenu.resetCharacterTable()
	--This function places all the characters in a table or refreshes it
	AvaliableCharacters = {"Uyakuya", "Mayaka", "Sunko", "Lakoto", "Celestia", 
		"Syoko", "Loi", "Zondo", "Yoko", "Miyozaka", "Rifumi", "Basuhirok"}
end


function CharacterMenu.ManageSelections(player, selection)
	--This function binds the chosen character to a player and then removes it as a choice
	local indexVal = table.find(AvaliableCharacters, selection)
	print(indexVal)
	if indexVal ~= nil then
		table.remove(AvaliableCharacters, indexVal)
		characterSelect:FireAllClients(selection)
		print(player.Name .. " Selected " .. selection)
		player:SetAttribute("CharacterName", selection)
	else
		print("This character is taken")
	end	
end

function CharacterMenu.checkSelection(player)
	--This function checks if everyplayer has a selected character, if they dont a random one is given to them
	if player:GetAttribute("CharacterName") == "" then
		local randomIndex = math.random(1, #AvaliableCharacters)
		player:SetAttribute("CharacterName", AvaliableCharacters[randomIndex])
		table.remove(AvaliableCharacters, randomIndex)
		--Remove GUI from player
		player.PlayerGui:FindFirstChild("CharacterMenu"):Destroy()
	end
end

function CharacterMenu.avatarSetter(player)
	--This function changes the player's avatar to the selected character's
	local CharacterName = player:GetAttribute("CharacterName")
	local humanoid = player.Character and player.Character:FindFirstChild("Humanoid")
	local bethDesc = HumanoidDesc:FindFirstChild(CharacterName)
	if humanoid then
		humanoid:ApplyDescription(bethDesc)
	end
end

function CharacterMenu.ReturnRandName(playerTable)
	while true do
		local randNum = math.random(1, #playerTable)
		if playerTable[randNum] ~= nil then
			local charName = playerTable[randNum]:GetAttribute("CharacterName")
			return charName
		end
	end
end

return CharacterMenu

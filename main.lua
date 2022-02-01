--Uses ROBLOX API
--Variables that hold paths to different objects
--ServerScriptService
local ServerScriptService = game:GetService("ServerScriptService")
local Scripts = ServerScriptService:FindFirstChild("Scripts")
--ServerStorage
local ServerStorage = game:GetService("ServerStorage")
local ValueTags = ServerStorage:FindFirstChild("ValueTags")
local GameText = ValueTags:FindFirstChild("GameText")
local hudEnabled = ValueTags:FindFirstChild("hudEnabled")
local TimerTag = ValueTags:FindFirstChild("TimerTag")
local GUIStorage = ServerStorage:FindFirstChild("GUIStorage")
local Speaker = ValueTags:FindFirstChild("Speaker")
local RequiredPlayers = ValueTags:FindFirstChild("RequiredPlayers")
--Locations
local Locations = ServerStorage:FindFirstChild("Locations")
local Nurse = Locations:FindFirstChild("Nurse")
local Gym = Locations:FindFirstChild("Gym")
local Dine = Locations:FindFirstChild("Dine")
local Court = Locations:FindFirstChild("Court")
--ReplicatedStorage
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local remoteEvents = ReplicatedStorage:FindFirstChild("remoteEvents")
local characterSelect = remoteEvents:FindFirstChild("characterSelect")
local voteEvent = remoteEvents:FindFirstChild("voteEvent")
local killEvent = remoteEvents:FindFirstChild("killEvent")
local hudEvent = remoteEvents:FindFirstChild("hudEvent")
--Players
local Players = game:GetService("Players")
--Teams
local Teams = game:GetService("Teams")
local Playing = Teams:FindFirstChild("Playing")
local Eliminated = Teams:FindFirstChild("Eliminated")
--WorkSpace
local GameMusic = game.Workspace:FindFirstChild("GameMusic")

--Calling module scripts
local CharacterMenu = require(script.CharacterMenu)
local PManager = require(script.PManager)
local voteMenu = require(script.voteMenu)
local killerMenu = require(script.killerMenu)
local clueMenu = require(script.clueMenu)
local gManager = require(script.GManager)
local mManager = require(script.MusicManager)
local cManager = require(script.challengeManager)

--Functions

while true do
	local EliminatedPlayers = Eliminated:GetPlayers()
	if #EliminatedPlayers >= RequiredPlayers.Value then
		--Intermission
		mManager.StopMusic()
		mManager.ChangeMusic(1840520416)
		gManager.CountDown(5, "Intermission")
		local contestants = Playing:GetPlayers()
		if #contestants < RequiredPlayers.Value then
			--If theres not 8 players when intermission is done restart loop.
			for i = 1, #contestants, 1 do
				PManager.updateTeam(contestants[i], Eliminated)
			end
			continue
		end
		--StartGame
		--Select A Character
		gManager.updateGameInfo("Game", "Welcome to cluegame! You will now select a character to play as in this story.", true)
		wait(6)
		PManager.isHere(contestants)
		CharacterMenu.resetCharacterTable()
		PManager.applyFunction(contestants, CharacterMenu.sendMenu)
		characterSelect.OnServerEvent:Connect(CharacterMenu.ManageSelections)
		gManager.CountDown(5, "Select A Character")
		PManager.applyFunction(contestants, CharacterMenu.checkSelection)
		--Apply Character Selection & Teleport Players
		PManager.isHere(contestants)
		PManager.applyFunction(contestants, PManager.nameGUI)
		PManager.applyFunction(contestants, CharacterMenu.avatarSetter)
		--Teleport Players to the GYM, add load screen
		local clonedGYM = Gym:Clone()
		clonedGYM.Parent = workspace
		wait(1.5)
		TeleportSpots = clonedGYM:FindFirstChild("TeleSpots"):GetChildren()
		PManager.isHere(contestants)
		PManager.teleportPlayers(contestants, TeleportSpots)
		wait(0.5)
		mManager.StopMusic()
		mManager.ChangeMusic(1846620979)
		gManager.Introduction(contestants)
		gManager.CountDown(5, "Meet Each Other")
		--Game Loop
		while #contestants > 3 do
			mManager.ChangeMusic(198374563)
			--Teleport Players To Dine
			PManager.applyFunction(contestants, PManager.speedZero)
			local clonedDine = Dine:Clone()
			clonedDine.Parent = workspace
			TeleportSpots = clonedDine:FindFirstChild("TeleSpots"):GetChildren()
			PManager.isHere(contestants)
			PManager.teleportPlayers(contestants, TeleportSpots)
			Speaker.Value = "Makoto"
			gManager.updateGameInfo(Speaker.Value, "Click the knife icon if you want to commit a crime. If no one commits a crime we will do a challenge.", true)
			wait(2)
			--Selecting Killer
			killerMenu.killerReset()
			PManager.isHere(contestants)
			PManager.applyFunction(contestants, killerMenu.sendGui)
			killEvent.OnServerEvent:Connect(killerMenu.removeGui)
			wait(10)
			local killer = killerMenu.returnKiller()
			print(killer)
			--Choosing a target
			if killer ~= nil then
				killerMenu.killSelectGui(killer)
				killEvent.OnServerEvent:Connect(killerMenu.receiveKill)
				wait(10)
				local target = killerMenu.returnTarget()
				print(target)
				if target == nil then
					--Choose a random person to kill
					target = killerMenu.randomKill()
				else
					--Make them eliminated
					local TargetChar = target:GetAttribute("CharacterName")
					gManager.updateGameInfo(Speaker.Value, (TargetChar .. " has been killed."), true)
					clueMenu.sendMenu(killer)
					wait(15)
					clueMenu.removeGUI(killer)
					clueMenu.returnClues(killer)
					PManager.updateTeam(target, Eliminated)
					contestants = Playing:GetPlayers()
				end
				--Clue Section
				mManager.ChangeMusic(1838946542)			
				local TeleSpots = clueMenu.displayClues()
				PManager.isHere(contestants)
				PManager.teleportPlayers(contestants, TeleSpots)
				PManager.applyFunction(contestants, PManager.speedOn)
				gManager.CountDown(25, "Investigate")
				PManager.isHere(contestants)
				voteMenu.clearVotes()
				--Teleport players to court
				mManager.ChangeMusic(279328644)
				local CourtClone = Court:Clone()
				CourtClone.Parent = game.Workspace
				local TeleSpots = CourtClone:FindFirstChild("TeleSpots"):GetChildren()
				PManager.applyFunction(contestants, PManager.speedZero)
				PManager.teleportPlayers(contestants, TeleSpots)
				gManager.CountDown(20, "Discuss")
				PManager.applyFunction(contestants, voteMenu.sendVote)
				gManager.updateGameInfo(Speaker.Value, "Vote who you believe is guilty.", true)
				voteEvent.OnServerEvent:Connect(voteMenu.recieveVote)
				gManager.CountDown(15, "Vote")
				voteMenu.removeGui()
				local votedOut = voteMenu.calculateVotes()
				local playerVotedChar = votedOut:GetAttribute("CharacterName")
				gManager.updateGameInfo(Speaker.Value, (playerVotedChar .. " has been voted out."), true)
				PManager.updateTeam(votedOut, Eliminated)
				contestants = Playing:GetPlayers()
				CourtClone:Destroy()
				clonedDine:Destroy()
				clueMenu.cleanUP()
				wait(5)
				
			else
				--Challenge so no one died
				killerMenu.removeGui(nil)
				gManager.updateGameInfo(Speaker.Value, "No one commited a crime, we will do a challenge now.", true)
				wait(5)
			end
		end
	else
		if GameMusic.SoundId ~= "rbxassetid://1841905171" then
			mManager.ChangeMusic(1841905171)
		end
		gManager.updateGameInfo("Game", "Waiting for 8 or more players.", true)
		wait(0.5)
		gManager.updateGameInfo("Game", "Waiting for 8 or more players..", true)
		wait(0.5)
		gManager.updateGameInfo("Game", "Waiting for 8 or more players...", true)
		wait(0.5)
	end
end








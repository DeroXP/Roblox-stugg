# Data in Roblox

so what i wanted to cover here just so i remeber is that places in the same universee id can get datastores from each other so for example if i wanted to store game data if like where a player has progressed in one game then get it in a another game or a main game then they would have to be in the same universe, this also means making another place in asset manager if you arent sure on what i mean.

Here's an example of how you can use DataStores to share data between two games in the same Universe ID:

Game 1 (e.g. "Progress Tracker")

-- Create a DataStore object
local DataStoreService = game:GetService("DataStoreService")
local progressStore = DataStoreService:GetDataStore("ProgressStore")

-- Store player progress
local player = game.Players.LocalPlayer
local progress = 10 -- some progress value
progressStore:SetAsync(player.UserId .. "-progress", progress)

Game 2 (e.g. "Main Game")

-- Create a DataStore object with the same name and Universe ID
local DataStoreService = game:GetService("DataStoreService")
local progressStore = DataStoreService:GetDataStore("ProgressStore")

-- Retrieve player progress
local player = game.Players.LocalPlayer
local progressKey = player.UserId .. "-progress"
local progressValue = progressStore:GetAsync(progressKey)
if progressValue then
    print("Player progress:", progressValue)
else
    print("No progress found for player")
end

In this example:

In Game 1, we create a DataStore object named "ProgressStore" and store the player's progress with a key based on their UserId.
In Game 2, we create a DataStore object with the same name and Universe ID as Game 1.
We retrieve the player's progress from the DataStore using the same key.
Note that both games need to have the same Universe ID set in the Asset Manager for this to work. Also, make sure to handle errors and edge cases properly in your actual implementation.

[prompt](https://www.blackbox.ai/share/fb6a1d44-b7de-491b-8bfd-a6c1dca9c4d3)
-- RhythmService
-- Created by Christian Toney / Draguwro
-- Published by Makuwro

local RunService = game:GetService("RunService");

local RhythmService = {
  Tolerance = {Perfect = 0.1, OK = 0.2}
};
local Song = {Sound = nil, Keys = {}, KeyPosition = 1, StopwatchEvent = nil};
local Events = {};

function RhythmService:SetSound(sound, keepKeys, startStopwatchOnPlay)
  assert(sound and sound:IsA("Sound"), "A sound instance must be the first argument");
  assert(not keepKeys or typeof(keepKeys) == "boolean", "keepKeys must be a boolean or nil");
  assert(not startStopwatchOnPlay or typeof(startStopwatchOnPlay) == "boolean", "startStopwatchOnPlay must be a boolean or nil");

  -- Set sound and remove keys if necessary
  Song.Sound = sound;
  if not keepKeys then
    Song.Keys = {};
  end;
  
  if startStopwatchOnPlay then
    local PlayEvent;
    PlayEvent = sound.Played:Connect(function()
      PlayEvent:Disconnect();
      RhythmService:StartStopwatch();
    end);
  end;
end;

function RhythmService:AddKey(timePosition, index)
  assert(Song.Sound, "A sound instance must be defined before adding a key");
  assert(timePosition and tonumber(timePosition), "A time position must be given to add a key");
  assert(not index or tonumber(index), "index must be a number or nil");
  
  -- Add key
  local Key = {timePosition, 1};
  if index then
    table.insert(Song.Keys, index, Key);
  else
    table.insert(Song.Keys, Key);
  end;
end;

function RhythmService:SetKeys(keys)
  assert(typeof(keys) == "table", "keys must be a table")
  
  -- Set keys
  for _, timePosition in ipairs(keys) do
    table.insert(Song.Keys, {timePosition, 1})
  end;
end;

function RhythmService:RemoveKey(index)
  assert(not index or tonumber(index), "index must be a number");
  table.remove(Song.Keys, index);
end;

function RhythmService:CheckRhythm()
  assert(Song.StopwatchEvent and Song.StopwatchEvent.Connected, "The stopwatch hasn't started!");
  
  local SongPosition = Song.Sound.TimePosition;
  local Goal = Song.Keys[Song.KeyPosition];
  local PerfectTolerance = RhythmService.Tolerance.Perfect;
  local OKTolerance = RhythmService.Tolerance.OK;
  local Result = {
    Rating = 0;
    GoalTime = Goal[1];
    HitTime = SongPosition;
  };
  
  -- Check the time
  if Goal[2] ~= 0 then
    if Goal[1] - PerfectTolerance <= SongPosition and SongPosition <= Goal[1] + PerfectTolerance then
      Result.Rating = 2;
    elseif Goal[1] - OKTolerance <= SongPosition and SongPosition <= Goal[1] + OKTolerance then
      Result.Rating = 1;
    end;
  end;
  
  if Result.Rating ~= 0 then
    RhythmService:ToggleKey(true);
  end;
  
  return Result;
end;

function RhythmService:ToggleKey(disable, index, keepPosition)
  assert(not disable or typeof(disable) == "boolean", "disable must be a boolean or nil");
  assert(not index or tonumber(index), "Index must be a number or nil");
  assert(not keepPosition or typeof(disable) == "boolean", "Index must be a number or nil");

  -- Toggle key and shift position
  Song.Keys[Song.KeyPosition or index][2] = (disable and 0) or 1;
  if not keepPosition and #Song.Keys >= Song.KeyPosition + 1 then
    Song.KeyPosition = Song.KeyPosition + 1;
  elseif #Song.Keys < Song.KeyPosition + 2 then
    RhythmService:StopStopwatch();
  end;
end;

function RhythmService:StopStopwatch()
  if Song.StopwatchEvent and Song.StopwatchEvent.Connected then
    Song.StopwatchEvent:Disconnect();
  end;
  
  Song.StopwatchEvent = nil;
end;

function RhythmService:StartStopwatch()
  RhythmService:StopStopwatch();
  
  -- Add a new SW
  Song.StopwatchEvent = RunService.Heartbeat:Connect(function()
    for i, v in ipairs(Song.Keys) do
      if v[2] ~= 0 and v[1] + RhythmService.Tolerance.OK < Song.Sound.TimePosition then 
        RhythmService:ToggleKey(true);
        Events.OnIdle:Fire();
        break;
      end;
    end;
  end);
end;

-- Events
for _, eventName in ipairs({"OnIdle"}) do
  Events[eventName] = Instance.new("BindableEvent");
  RhythmService[eventName] = Events[eventName].Event;
end

return RhythmService;

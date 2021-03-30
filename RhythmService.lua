-- RhythmService
-- Created by Christian Toney / Draguwro

local RunService = game:GetService("RunService");
local RhythmService = {
  Tolerance = {0.1, 0.2};
  -- The first tolerance level is considered a perfect, 
  -- while the last tolerance level is considered right before the player misses the beat
  -- You can add more tolerance levels if you'd like
  Stopwatch = nil;
  -- You can use RhythmService.Stopwatch to see if the stopwatch is active
};
local Song = {Sound = nil, Keys = {}, KeyPosition = 1};
local Events = {};

function RhythmService:SetSound(sound: Sound, keepKeys: boolean?, startStopwatchOnPlay: boolean?)
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

function RhythmService:AddKey(timePosition: number, index: number?, endHold: number?)
  assert(Song.Sound, "A sound instance must be defined before adding a key");
  
  -- Add key
  local Key = {timePosition, 1, endHold or nil};
  if index then
    table.insert(Song.Keys, index, Key);
  else
    table.insert(Song.Keys, Key);
  end;
end;

-- function RhythmService:SetKeys(keys: {{number, boolean?}}?)
function RhythmService:SetKeys(keys)
  -- Set keys
  Song.Keys = {};
  if keys then
    for _, v in ipairs(keys) do
      if typeof(v) == "table" then
        table.insert(Song.Keys, {v[1], 1, v[2]});
      else
        table.insert(Song.Keys, {v, 1});
      end;
    end
  end;
end;

function RhythmService:RemoveKey(index: number)
  table.remove(Song.Keys, index);
end;

function RhythmService:CheckRhythm(noHold: boolean?)
  assert(#Song.Keys > 0, "There has to be at least one key!");
  assert(RhythmService.Stopwatch and RhythmService.Stopwatch.Connected, "The stopwatch hasn't started!");
  
  local SongPosition = Song.Sound.TimePosition;
  local Goal = Song.Keys[Song.KeyPosition];
  local Result = {
    GoalTime = (Goal[2] == 0 and noHold and Goal[3]) or Goal[1];
    HitTime = SongPosition;
  };
  
  if (noHold and not Goal[3]) or (noHold and Goal[2] == 1) then
    return;
  end;
  
  -- Check the time
  for level, tolerance in ipairs(RhythmService.Tolerance) do
    if Goal[2] ~= 0 or (Goal[2] == 0 and noHold) then
      if ((noHold and Goal[3]) or Goal[1]) - tolerance <= SongPosition and SongPosition <= ((noHold and Goal[3]) or Goal[1]) + tolerance then
        Result.Rating = level;
        if (noHold and Goal[3]) or (not noHold and not Goal[3]) then
          RhythmService:ToggleKey(true);
        else
          Song.Keys[Song.KeyPosition][2] = 0;
        end;
        break;
      end;
    end;
  end;
  
  return Result;
end;

function RhythmService:ToggleKey(disable: boolean?, index: number?, keepPosition: boolean?)
  -- Toggle key and shift position
  Song.Keys[Song.KeyPosition or index][2] = (disable and 0) or 1;
  if not keepPosition and #Song.Keys >= Song.KeyPosition + 1 then
    Song.KeyPosition = Song.KeyPosition + 1;
  elseif #Song.Keys < Song.KeyPosition + 2 then
    RhythmService:StopStopwatch();
  end;
end;

function RhythmService:ResetKeys()
  for i, key in ipairs(Song.Keys) do
    Song.Keys[i] = {key[1], 1, key[3]};
  end;
end;

function RhythmService:StopStopwatch()
  if RhythmService.Stopwatch and RhythmService.Stopwatch.Connected then
    RhythmService.Stopwatch:Disconnect();
  end;
  
  RhythmService.Stopwatch = nil;
end;

function RhythmService:StartStopwatch()
  assert(Song.Sound, "A sound hasn't been defined!");
  assert(#Song.Keys > 0, "There has to be at least one key!");
  
  RhythmService:StopStopwatch();
  RhythmService:ResetKeys();
  Song.KeyPosition = 1;
  
  -- Add a new SW
  RhythmService.Stopwatch = RunService.Heartbeat:Connect(function()
    for i, v in ipairs(Song.Keys) do
      local Limit = (v[2] ~= 0 and v[1]) or v[3]
      if Limit and Limit + RhythmService.Tolerance[#RhythmService.Tolerance] < Song.Sound.TimePosition then
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
end;

return RhythmService;

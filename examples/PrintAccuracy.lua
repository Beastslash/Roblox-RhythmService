local UserInputService = game:GetService("UserInputService");
local RhythmService = require(script.RhythmService);

RhythmService:SetSound(workspace.Sound, false, true); -- Assuming the sound is in the workspace
RhythmService:SetKeys({0.95, 2.35, 3.95}); -- Certain parts of the sound to check
RhythmService.OnIdle:Connect(function() 
  -- Do something
end);

-- This will trigger even if the sound isn't playing
UserInputService.InputBegan:Connect(function(input)
  if input.KeyCode == Enum.KeyCode.Space then
    local Result = RhythmService:CheckRhythm();
    print(Result.Rating); -- Returns 0-2 depending on accuracy
  end;
end);

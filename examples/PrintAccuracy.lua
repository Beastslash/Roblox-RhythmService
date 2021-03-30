local UserInputService = game:GetService("UserInputService");
local RhythmService = require(script.RhythmService);

RhythmService:SetSound(workspace.Sound, false, true); -- Assuming the sound is in the workspace
RhythmService:SetKeys({0.95, 2.35, {3.95, 5}}); -- Certain parts of the sound to check
RhythmService.OnIdle:Connect(function() 
  print("Miss (Idle)")
end);

UserInputService.InputBegan:Connect(function(input)
  if input.KeyCode == Enum.KeyCode.Space then
    local Result = RhythmService:CheckRhythm();
    print((Result.Rating == 1 and "Perfect") or (Result.Rating == 2 and "OK") or "Miss");
  end;
end);

UserInputService.InputEnded:Connect(function(input)
  if input.KeyCode == Enum.KeyCode.Space then
    if RhythmService.Stopwatch then -- :CheckRhythm will error if the stopwatch isn't active
      local Result = RhythmService:CheckRhythm(true);
      if Result then
        print((Result.Rating == 1 and "Perfect hold!") or (Result.Rating == 2 and "OK hold") or "Miss");
      end;
    end;
  end;
end);

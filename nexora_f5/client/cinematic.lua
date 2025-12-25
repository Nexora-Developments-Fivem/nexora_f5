cinematicMode = false
local barProgress = 0.0

function ToggleCinematic()
    cinematicMode = not cinematicMode
end

CreateThread(function()
    while true do
        Wait(0)
        
        if cinematicMode and barProgress < 1.0 then
            barProgress = barProgress + Config.Cinematic.AnimationSpeed
            if barProgress > 1.0 then 
                barProgress = 1.0 
            end
        elseif not cinematicMode and barProgress > 0.0 then
            barProgress = barProgress - Config.Cinematic.AnimationSpeed
            if barProgress < 0.0 then 
                barProgress = 0.0 
            end
        end
        
        if barProgress > 0.0 then
            local barHeight = Config.Cinematic.BarHeight * barProgress
            DrawRect(0.5, barHeight / 2.0, 1.0, barHeight, 0, 0, 0, 255)
            DrawRect(0.5, 1.0 - (barHeight / 2.0), 1.0, barHeight, 0, 0, 0, 255)
        end
    end
end)
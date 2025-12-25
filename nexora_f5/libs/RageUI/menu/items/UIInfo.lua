function RageUI.Info(Title, RightText, LeftText)
    local LineCount = #RightText >= #LeftText and #RightText or #LeftText
    if Title ~= nil then
        RenderText("~h~" .. Title .. "~h~", 332 + 20 + 100, 7, 0, 0.34, 255, 255, 255, 255, 0)
    end
    if RightText ~= nil then
        RenderText(table.concat(RightText, "\n~s~"), 332 + 20 + 100, Title ~= nil and 37 or 7, 0, 0.28, 255, 255, 255, 255, 0)
    end
    if LeftText ~= nil then
        RenderText(table.concat(LeftText, "\n~s~"), 332 + 332 + 100, Title ~= nil and 37 or 7, 0, 0.28, 255, 255, 255, 255, 2)
    end
    RenderRectangle(332 + 10 + 100, 0, 332 + 50, Title ~= nil and 50 + (LineCount * 20) or ((LineCount + 1) * 20), 18, 22, 24, 200)
end

--RageUI.Info("Titre", {"Sous titre 1", "Sous titre 2", "Sous titre 3","Sous titre 4"}, {"Sous titre droite 1", "Sous titre droite 2", "Sous titre droite 3","Sous titre droite 4" })
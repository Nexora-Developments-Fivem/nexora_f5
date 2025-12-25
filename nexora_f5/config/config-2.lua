Config.HUDResources = {
    esx = {
        {resource = "esx_hud", type = "export", exportName = "HudToggle"},
    },
    qbcore = {
        {resource = "qb-hud", type = "export", exportName = "toggleHUD"},
        {resource = "ps-hud", type = "export", exportName = "toggleHUD"},
        {resource = "renewed-hud", type = "export", show = "showHUD", hide = "hideHUD"},
        {resource = "qs-hud", type = "event", show = "qs-hud:client:toggleHUD", hide = "qs-hud:client:toggleHUD"}
    },
    custom = {}
}
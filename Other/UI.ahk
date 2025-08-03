#Requires AutoHotkey v2.0
; OnError(ErrorHandler)

global lastlog := ""
global MainUI
global Process
global StatusHistory := []
global MacroUI := "Goon AFS Macro"
global MapsGui := ""
global ModifiersGui := ""
global CurrentPage := 1
global TotalPages := 4
global roblox := "ahk_exe RobloxPlayerBeta.exe"
global PrevBtn := ""
global NextBtn := ""
global TierGui := ""
global ModifiersGui := ""
global PortalType := ""

;Update Checker
global repoOwner := "sawnek"
global repoName := "Goon-AFS-Macro"
global Version := "v1.3.4"

LoadColorSettings() {
    colorFile := A_ScriptDir "\Settings\Colors.txt"
    if !FileExist(colorFile) {
        try {
            FileAppend(
                "TextColor=B5C7EB`n" .
                "BackgroundColor=1a1a1a`n" .
                "AccentColor=B5C7EB`n" .
                "BorderColor=B5C7EB`n" .
                "HeaderBackground=2a2a2a`n" .
                "ButtonBackground=2a2a2a`n" .
                "HoverColor=3a3a3a",
                colorFile
            )
            UpdateText("Created color settings file")
        } catch Error as e {
            UpdateText("Error creating color settings file: " e.Message)
            return Map(
                "TextColor", "cB5C7EB",
                "BackgroundColor", "c1a1a1a",
                "AccentColor", "cB5C7EB",
                "BorderColor", "cB5C7EB",
                "HeaderBackground", "c2a2a2a",
                "ButtonBackground", "c2a2a2a",
                "HoverColor", "c3a3a3a"
            )
        }
    }

    try {
        fileContent := FileRead(colorFile)
        settings := StrSplit(fileContent, "`n")
        colors := Map()

        for setting in settings {
            parts := StrSplit(setting, "=")
            if (parts.Length = 2) {
                colorName := Trim(parts[1])
                colorValue := Trim(parts[2])
                colors[colorName] := "c" colorValue
            }
        }
        UpdateText("Color settings loaded")
        return colors
    } catch Error as e {
        UpdateText("Error loading color settings: " e.Message)
        return Map(
            "TextColor", "cB5C7EB",
            "BackgroundColor", "c1a1a1a",
            "AccentColor", "c8d9cb9",
            "BorderColor", "c8d9cb9",
            "HeaderBackground", "c2a2a2a",
            "ButtonBackground", "c2a2a2a",
            "HoverColor", "c3a3a3a"
        )
    }
}

CreateDirectories() {
    if !DirExist(A_ScriptDir "\Logs") {
        DirCreate(A_ScriptDir "\Logs")
        UpdateText("Logs directory created")
    }
}

CreateSettingsFile()
CreateDirectories()

colors := LoadColorSettings()
textcolor := colors["TextColor"]
bgColor := colors["BackgroundColor"]
accentColor := colors["AccentColor"]
borderColor := colors["BorderColor"]
headerBgColor := colors["HeaderBackground"]
buttonBgColor := colors["ButtonBackground"]
hoverColor := colors["HoverColor"]

MainUI := Gui("-Caption +AlwaysOnTop", "Goon AFS Macro")

MainUI.BackColor := bgColor
MainUI.SetFont("s10 bold", "Segoe UI")
DragWindow := MainUI.Add("Text", "x0 y0 w1000 h25 " accentColor)
DragWindow.OnEvent("Click", (*) => DragWindowFunc())
CloseButton := MainUI.Add("Picture", "x1260 y5 w25 H25", XBUTTON)
CloseButton.OnEvent("Click", (*) => ExitApp())
MinimizeButton := MainUI.Add("Picture", "x1220 y5 w25 h25", Minimize)
MinimizeButton.OnEvent("Click", (*) => WinMinimize())

DragWindowFunc() {
    PostMessage(0xA1, 2)
    Sleep 1
    if WinExist(roblox) {
        WinGetPos(&X, &Y, &W, &H, MainUI)
        WinActivate(roblox)
        WinMove(X, Y, 800, 600, roblox)
    }
}

MainUI.AddProgress("c0x603b3b x5 y30 h600 w800", 100)
WinSetTransColor("0x603b3b 255", MainUI)
MainUI.SetFont("s12 bold")
MainUI.Add("Text", "x850 y670 w80 c" textcolor " BackgroundTrans", "Mode:")
MainUI.SetFont("s10")
global ModeSelect := MainUI.Add("DropDownList", "x920 y670 w150 vSelectedMode Choose1 Background" buttonBgColor " c" textcolor,
    ["", "Story", "Infinite", "Legend", "Raid", "Inferno", "Custom"])

global CustomModeSelect := MainUI.Add("DropDownList", "x920 y700 w150 vSelectedCustomMode Background" buttonBgColor " c" textcolor " Hidden")

global WorldSelect := MainUI.Add("DropDownList", "x920 y700 w150 vWorldSelect Background" buttonBgColor " c" textcolor " Hidden", 
    ["", "Clown Town", "Alien Island", "Sand Village", "Demon Winter", "Huco Mondo", "Asakusa Flame"])
WorldSelect.OnEvent("Change", (*) => SetTimer(() => LoadModeSettings(), -100))

global LegendSelect := MainUI.Add("DropDownList", "x920 y700 w150 vLegendSelect Background" buttonBgColor " c" textcolor " Hidden", 
    ["", "Alien Island", "Demon Winter", "Huco Mondo", "Asakusa Flame"])
LegendSelect.OnEvent("Change", (*) => SetTimer(() => LoadModeSettings(), -100))

global RaidSelect := MainUI.Add("DropDownList", "x920 y700 w150 vRaidSelect Background" buttonBgColor " c" textcolor " Hidden", 
    ["", "Emies Lobby", "Nature Village"])
RaidSelect.OnEvent("Change", (*) => SetTimer(() => LoadModeSettings(), -100))

global ActSelect := MainUI.Add("DropDownList", "x920 y730 w150 vActSelect Background" buttonBgColor " c" textcolor " Hidden", 
    ["", "Act 1", "Act 2", "Act 3", "Act 4", "Act 5", "Act 6"])

global LegendActSelect := MainUI.Add("DropDownList", "x920 y730 w150 vLegendActSelect Background" buttonBgColor " c" textcolor " Hidden", 
    ["", "Act 1", "Act 2", "Act 3"])

global RaidActSelect := MainUI.Add("DropDownList", "x920 y730 w150 vRaidActSelect Background" buttonBgColor " c" textcolor " Hidden", 
    ["", "Act 1", "Act 2", "Act 3", "Act 4"])

global NightmareToggle := MainUI.Add("Checkbox", "x1090 y703 w100 Checked c" textcolor " Hidden" " vNightmareToggle", "Nightmare")

global CustomModeEdit := MainUI.Add("Edit", "x1090 y670 w100 vCustomModeEdit Hidden", "")
global CustomModeCreateBtn := MainUI.Add("Button", "x1200 y670 w60 h25 c" textcolor " Background" buttonBgColor " Hidden",
    "Create")

; global GameSpeedSelect := MainUI.Add("DropDownList", "x1225 y719 w60 vGameSpeed Choose3 Background" buttonBgColor " c" textcolor,
;     ["1x", "2x", "3x"])

global AutoAbility := MainUI.Add("Checkbox", "x1090 y733 w100 Checked c" textcolor " Hidden " " vAutoAbility", "Auto Ability")

global Wave15Toggle := MainUI.Add("Checkbox", "x1090 y703 w100 Checked c" textcolor " Hidden" " vWave15Toggle", "Wave 15")

; Only set up the event once, and remove duplicate OnEvent
ModeSelect.OnEvent("Change", ModeSelectChanged)

GetMode() {
    submitted := MainUI.Submit(false)
    return submitted.SelectedMode
}

ModeSelectChanged(*) {
    mode := ModeSelect.Text

    ; Hidden controls on switch
    NightmareToggle.Visible := false
    Wave15Toggle.Visible := false
    ; GameSpeedSelect.Visible := false
    CustomModeSelect.Visible := false
    CustomModeEdit.Visible := false
    CustomModeCreateBtn.Visible := false
    WorldSelect.Visible := false
    ActSelect.Visible := false
    LegendSelect.Visible := false
    LegendActSelect.Visible := false
    RaidSelect.Visible := false
    RaidActSelect.Visible := false
    ; Visible controls on switch
    if !(mode = "") {
    AutoAbility.Visible := true
    } else {
        AutoAbility.Visible := false
    }


    switch mode {
        case "Custom":
            UpdateCustomModes()
            CustomModeSelect.Visible := true
            CustomModeEdit.Visible := true
            CustomModeCreateBtn.Visible := true
            MainUI.Show()
        case "Story":
            WorldSelect.Visible := true
            ActSelect.Visible := true
            NightmareToggle.Visible := true
            MainUI.Show()
        case "Infinite":
            WorldSelect.Visible := true
            Wave15Toggle.Visible := true
            MainUI.Show()
        case "Legend":
            LegendSelect.Visible := true
            LegendActSelect.Visible := true
            MainUI.Show()
        case "Raid":
            RaidSelect.Visible := true
            RaidActSelect.Visible := true
            MainUI.Show()
        case "Inferno":
            LoadGameModeSettings()
            MainUI.Show()
        Default:
            MainUI.Show()
            ClearAll2()
    }
}
LoadGameModeSettings(*) {
    submitted := MainUI.Submit(false)
    selectedMode := submitted.SelectedMode
    gameMode := selectedMode
    settingsDir := ""

    if (!gameMode || gameMode = "") {
        return
    }

    settingsFile := A_ScriptDir "\Settings\" settingsDir "\" gameMode ".txt"

    loop 72 {
        MainUI["Unit" . A_Index].Value := ""
        MainUI["Upgrade" . A_Index].Text := "0"
        MainUI["X" . A_Index].Value := ""
        MainUI["Y" . A_Index].Value := ""
        MainUI["CopyFrom" . A_Index].Value := ""
    }

    if FileExist(settingsFile) {
        try {
            fileContent := FileRead(settingsFile)
            settings := StrSplit(fileContent, "`n")
            currentIndex := 0

            for setting in settings {
                setting := Trim(setting)
                if (setting) {
                    parts := StrSplit(setting, "=")
                    if (parts.Length = 2) {
                        settingName := Trim(parts[1])
                        settingValue := Trim(parts[2])

                        if (settingName = "Index")
                            currentIndex := settingValue
                        else if (currentIndex > 0 && settingName != "Wait") {
                            try {
                                if (settingName = "Upgrade")
                                    MainUI["Upgrade" . currentIndex].Text := settingValue
                                else
                                    MainUI[settingName . currentIndex].Value := settingValue
                            } catch Error as e {
                                MsgBox("Error loading setting " settingName ": " e.Message)
                                return false
                            }
                        }
                    }
                }
            }
            UpdateText("Settings loaded for " gameMode)
        } catch Error as e {
            MsgBox("Error reading settings file: " e.Message)
            return false
        }
    } else {
        UpdateText("No settings file found for " gameMode)
        return false
    }

    MainUI.Show("w1300 h775")
    return true
}
MainUI.SetFont("s14 bold")
MainUI.Add("Text", "x825 y3 w400 h30 c" textcolor " +Center", "Unit Selection")
MainUI.SetFont("s10")

MainUI.Add("Text", "x825 y40 w408 h35 Background" headerBgColor)

MainUI.SetFont("s11 bold")
MainUI.Add("Text", "x835 y47 w40 c" textcolor " BackgroundTrans", "#")
MainUI.Add("Text", "x880 y47 w50 c" textcolor " BackgroundTrans", "Slot")
MainUI.Add("Text", "x945 y47 w70 c" textcolor " BackgroundTrans", "Upgrade")
MainUI.Add("Text", "x1037 y47 w70 c" textcolor " BackgroundTrans", "Position")
PageDisplay := MainUI.Add("Text", "x1250 y47 w30 h25 c" textcolor " +Center BackgroundTrans", CurrentPage . "/" .
    TotalPages)

MainUI.SetFont("s9 bold", "Segoe UI")
PrevBtn := MainUI.Add("Button", "x1103 y46 w60 h24 c" textcolor " Background" buttonBgColor, "Previous")
NextBtn := MainUI.Add("Button", "x1170 y46 w60 h24 c" textcolor " Background" buttonBgColor, "Next")

; === CONSTANTS ===
rowHeight := 29
baseY := 75
visibleCount := 18

; === Header Background Rows ===
loop visibleCount {
    i := A_Index
    yPos := baseY + (i - 1) * rowHeight
    if (Mod(i, 2) = 0)
        MainUI.Add("Text", "x825 y" yPos " w408 h27 Background" headerBgColor)
}

; === Unit Rows ===
loop 72 {
    i := A_Index
    pageIndex := Mod(i - 1, visibleCount) + 1
    yPos := baseY + (pageIndex - 1) * rowHeight

    isHidden := (i > visibleCount)
    hiddenStr := isHidden ? " Hidden" : ""
    controlColor := "Background" buttonBgColor " c" textcolor hiddenStr
    buttonColor := "c" textcolor hiddenStr

    ; === Unit Number Label ===
    MainUI.Add("Text", "x835 y" (yPos + 5) " w25 c" textcolor " BackgroundTrans" hiddenStr " vUnitNum" i, i)

    ; === Unit Name Edit ===
    MainUI.Add("Edit", "x874 y" (yPos + 2) " w45 vUnit" i " " controlColor)
    MainUI["Unit" . i].OnEvent("Change", UnitChanged.Bind(i))

    ; === CopyFrom Edit ===
    MainUI.Add("Edit", "x1199 y" (yPos + 2) " w30 vCopyFrom" i " " controlColor)
    MainUI["CopyFrom" . i].OnEvent("Change", CopyUnitData.Bind(i))

    ; === Upgrade Dropdown ===
    MainUI.Add("DropDownList", "x945 y" (yPos + 2) " w65 vUpgrade" i " Choose1" hiddenStr,
        ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "MAX"])

    ; === X/Y Coordinate Edits ===
    MainUI.Add("Edit", "x1037 y" (yPos + 2) " w40 vX" i " " controlColor)
    MainUI.Add("Edit", "x1082 y" (yPos + 2) " w40 vY" i " " controlColor)

    ; === Set Coords Button ===
    MainUI.Add("Button", "x1127 y" (yPos + 2) " w50 h21 vCoords" i " " buttonColor, "Set")
        .OnEvent("Click", SelectCords.Bind(i))
}

MainUI.SetFont("s10 bold", "Segoe UI")

CopyBtn := MainUI.Add("Button", "x825 y595 w95 h32 c" textcolor " Background" buttonBgColor, "Copy")
PasteBtn := MainUI.Add("Button", "x930 y595 w95 h32 c" textcolor " Background" buttonBgColor, "Paste")
ClearBtn := MainUI.Add("Button", "x1035 y595 w95 h32 c" textcolor " Background" buttonBgColor, "Clear")
Save := MainUI.Add("Button", "x1140 y595 w95 h32 c" textcolor " Background" buttonBgColor, "Save")

MainUI.Add("Text", "x825 y600 w95 h28 Background2a2a2a Hidden", "")
MainUI.Add("Text", "x930 y600 w95 h28 Background2a2a2a Hidden", "")
MainUI.Add("Text", "x1035 y600 w95 h28 Background2a2a2a Hidden", "")
MainUI.Add("Text", "x1140 y600 w95 h28 Background2a2a2a Hidden", "")

PrevBtn.OnEvent("Click", PreviousPage)
NextBtn.OnEvent("Click", NextPage)
CopyBtn.OnEvent("Click", CopySettings)
PasteBtn.OnEvent("Click", PasteSettings)
ClearBtn.OnEvent("Click", ClearAll)
Save.OnEvent("Click", (*) => SaveSettings())

MainUI.SetFont("s13 bold")
MainUI.Add("Text", "x95 y632 w300 h120 c" textcolor " BackgroundTrans", "Process:")
MainUI.Add("Text", "x362 y632 w198 h21 c" textcolor " BackgroundTrans", "Settings:")
MainUI.Add("Text", "x600 y632 w300 h120 c" textcolor " BackgroundTrans", "Webhook:")
MainUI.SetFont("s10")

Process := MainUI.Add("Text", "x20 y660 w250 h105 c" textcolor " BackgroundTrans", "Press F1 to start the macro")

MainUI.Add("Text", "x0 y628 w13500 h3 Background" borderColor)       ; Top border thickened
MainUI.Add("Text", "x0 y628 w5 h125 Background" borderColor)       ; Left vertical
MainUI.Add("Text", "x0 y770 w1300 h5 Background" borderColor)      ; Bottom border
MainUI.Add("Text", "x280 y630 w3 h170 Background" borderColor)     ; Middle vertical 1
MainUI.Add("Text", "x514 y630 w3 h170 Background" borderColor)     ; Middle vertical 2
MainUI.Add("Text", "x0 y655 w1350 h3 Background" borderColor)      ; Horizontal inside
MainUI.Add("Text", "x805 y0 w3 h770 Background" borderColor)       ; Vertical right of middle
MainUI.Add("Text", "x0 y0 w1350 h5 Background" borderColor)        ; Very top border
MainUI.Add("Text", "x0 y0 w5 h770 Background" borderColor)         ; Very left border
MainUI.Add("Text", "x1295 y0 w5 h770 Background" borderColor)      ; Very right border
MainUI.Add("Text", "x5 y30 w1350 h3 Background" borderColor)       ; Header separator
;MainUI.Add("Text", "x5 y30 w3 h600 Background" borderColor)        ; Header left vertical

MainUI.SetFont("s9")
MainUI.Add("Text", "x535 y680 w80 BackgroundTrans c" textcolor, "Enable:")
WebhookCheckbox := MainUI.Add("Checkbox", "x615 y680 vEnableWebhook")
TestWebhook := MainUI.Add("Button", "x655 y677 w60 h20 c" textcolor " Background" buttonBgColor, "Test")
MainUI.Add("Text", "x535 y705 w80 BackgroundTrans c" textcolor, "URL:")
WebhookEdit := MainUI.Add("Edit", "x615 y702 w150 vMyEdit Background" buttonBgColor " c" textcolor)
MainUI.Add("Text", "x535 y730 w80 BackgroundTrans c" textcolor, "Discord ID:")
DiscordIdEdit := MainUI.Add("Edit", "x615 y727 w150 vDiscordIdEdit Background" buttonBgColor " c" textcolor)

TestWebhook.OnEvent("Click", (*) => TestWebhookFunc())

TestWebhookFunc() {
    WebhookScreenshot2()
}

MainUI.SetFont("s16 bold", "Arial")

global statusHistory := []

UpdateText(text) {
    try {
        logFile := A_ScriptDir "\Logs\status.log"
        FileAppend(FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") " - " text "`n", logFile)

        if (!IsObject(statusHistory))
            global statusHistory := []

        statusHistory.InsertAt(1, text)
        if (statusHistory.Length > 6)
            statusHistory.Pop()

        displayText := ">"
        for index, status in statusHistory {
            if (index = 1)
                displayText .= status . "`n"
            else
                displayText .= status . "`n"
        }

        if (IsObject(Process))
            Process.Text := displayText
    } catch Error as e {
        try {
            if (IsObject(Process))
                Process.Text := "> Error: " e.Message

            logFile := A_ScriptDir "\Logs\status.log"
            FileAppend(FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") " - Error updating status: " e.Message "`n", logFile)
        }
    }
}

ShowMapsGui() {
    global MapsGui, Map1Checkbox, Map2Checkbox, Map3Checkbox, Map4Checkbox, Map5Checkbox, bgColor, textcolor,
        accentColor,
        buttonBgColor

    if (!IsObject(MapsGui)) {
        MapsGui := Gui("-Caption +Border +AlwaysOnTop", "Select Maps to Exclude")
        MapsGui.MarginX := 0
        MapsGui.MarginY := 0
        MapsGui.BackColor := bgColor
        MapsGui.SetFont("s12 bold", "Segoe UI")

        ; Adjusted height to accommodate 5 maps
        MapsGui.Add("Text", "x0 y0 w320 h1 Background" accentColor)  ; Top border
        MapsGui.Add("Text", "x0 y0 w1 h265 Background" accentColor)  ; Left border
        MapsGui.Add("Text", "x319 y0 w1 h265 Background" accentColor)  ; Right border
        MapsGui.Add("Text", "x0 y264 w320 h1 Background" accentColor)  ; Bottom border

        titleText := MapsGui.Add("Text", "x1 y5 w318 h30 Center " textcolor " BackgroundTrans", "Exclude Maps")
        titleText.SetFont("s14 bold", "Segoe UI")
        titleText.OnEvent("Click", (*) => PostMessage(0xA1, 2, , , MapsGui))

        MapsGui.Add("Text", "x20 y35 w280 h2 Background" accentColor)

        Map1Checkbox := MapsGui.Add("Checkbox", "x30 y55 w260 vMap1 c" textcolor " ", "Innovation Island")
        Map1Checkbox.SetFont("s10", "Segoe UI")

        Map2Checkbox := MapsGui.Add("Checkbox", "x30 y80 w260 vMap2 c" textcolor " ", "City of Voldstandig")
        Map2Checkbox.SetFont("s10", "Segoe UI")

        Map3Checkbox := MapsGui.Add("Checkbox", "x30 y105 w260 vMap3 c" textcolor " ", "Future City (Ruins)")
        Map3Checkbox.SetFont("s10", "Segoe UI")

        Map4Checkbox := MapsGui.Add("Checkbox", "x30 y130 w260 vMap4 c" textcolor " ", "Hidden Storm Village")
        Map4Checkbox.SetFont("s10", "Segoe UI")

        ; Fixed positioning for Map5 - moved it down to y155
        Map5Checkbox := MapsGui.Add("Checkbox", "x30 y155 w260 vMap5 c" textcolor " ", "Giant Island")
        Map5Checkbox.SetFont("s10", "Segoe UI")

        ; Moved separator and buttons down
        MapsGui.Add("Text", "x20 y185 w280 h1 Background" accentColor)

        saveBtn := MapsGui.Add("Button", "x50 y205 w100 h35 Background" buttonBgColor " c" textcolor, "Save & Close")
        saveBtn.SetFont("s10 bold", "Segoe UI")
        saveBtn.OnEvent("Click", (*) => (SaveMapExclusionStates(), MapsGui.Hide()))

        cancelBtn := MapsGui.Add("Button", "x170 y205 w100 h35 Background" buttonBgColor " c" textcolor, "Cancel")
        cancelBtn.SetFont("s10 bold", "Segoe UI")
        cancelBtn.OnEvent("Click", (*) => MapsGui.Hide())

        Map1Checkbox.OnEvent("Click", (*) => SaveMapExclusionStates())
        Map2Checkbox.OnEvent("Click", (*) => SaveMapExclusionStates())
        Map3Checkbox.OnEvent("Click", (*) => SaveMapExclusionStates())
        Map4Checkbox.OnEvent("Click", (*) => SaveMapExclusionStates())
        Map5Checkbox.OnEvent("Click", (*) => SaveMapExclusionStates())
    }

    LoadMapExclusionStates()
    MapsGui.Show("w320 h265")  ; Adjusted height
}

SaveMapExclusionStates() {
    global Map1Checkbox, Map2Checkbox, Map3Checkbox, Map4Checkbox, Map5Checkbox
    mapStates := Map1Checkbox.Value "|" Map2Checkbox.Value "|" Map3Checkbox.Value "|" Map4Checkbox.Value "|" Map5Checkbox
        .Value
    settingsDir := A_ScriptDir . "\Settings"
    if !DirExist(settingsDir)
        DirCreate(settingsDir)
    if FileExist(settingsDir . "\MapExclusions.txt")
        FileDelete(settingsDir . "\MapExclusions.txt")
    FileAppend mapStates, settingsDir . "\MapExclusions.txt"
}

LoadMapExclusionStates() {
    global Map1Checkbox, Map2Checkbox, Map3Checkbox, Map4Checkbox, Map5Checkbox
    mapExclusionsFile := A_ScriptDir . "\Settings\MapExclusions.txt"
    if FileExist(mapExclusionsFile) {
        local mapStates := FileRead(mapExclusionsFile)
        parts := StrSplit(mapStates, "|")
        ; Fixed the logic - check for 5 parts instead of 4
        if (parts.Length >= 5) {
            Map1Checkbox.Value := parts[1]
            Map2Checkbox.Value := parts[2]
            Map3Checkbox.Value := parts[3]
            Map4Checkbox.Value := parts[4]
            Map5Checkbox.Value := parts[5]
        } else if (parts.Length == 4) {
            Map1Checkbox.Value := parts[1]
            Map2Checkbox.Value := parts[2]
            Map3Checkbox.Value := parts[3]
            Map4Checkbox.Value := parts[4]
            Map5Checkbox.Value := 0
        }
    } else {
        Map1Checkbox.Value := 0
        Map2Checkbox.Value := 0
        Map3Checkbox.Value := 0
        Map4Checkbox.Value := 0
        Map5Checkbox.Value := 0
    }
}
ShowModifiersGui() {
    global ModifiersGui, Modifier1Checkbox, Modifier2Checkbox, Modifier3Checkbox, Modifier4Checkbox, Modifier5Checkbox,
        Modifier6Checkbox, bgColor, textcolor, accentColor, buttonBgColor

    if (!IsObject(ModifiersGui)) {
        ModifiersGui := Gui("-Caption +Border +AlwaysOnTop", "Select Modifiers to Exclude")
        ModifiersGui.MarginX := 0
        ModifiersGui.MarginY := 0
        ModifiersGui.BackColor := bgColor
        ModifiersGui.SetFont("s12 bold", "Segoe UI")

        ModifiersGui.Add("Text", "x0 y0 w320 h1 Background" accentColor)  ; Top border
        ModifiersGui.Add("Text", "x0 y0 w1 h280 Background" accentColor)  ; Left border
        ModifiersGui.Add("Text", "x319 y0 w1 h280 Background" accentColor)  ; Right border
        ModifiersGui.Add("Text", "x0 y279 w320 h1 Background" accentColor)  ; Bottom border

        titleText := ModifiersGui.Add("Text", "x1 y5 w318 h30 Center " textcolor " BackgroundTrans",
            "Exclude Modifiers")
        titleText.SetFont("s14 bold", "Segoe UI")
        titleText.OnEvent("Click", (*) => PostMessage(0xA1, 2, , , ModifiersGui))

        ModifiersGui.Add("Text", "x20 y35 w280 h2 Background" accentColor)

        Modifier1Checkbox := ModifiersGui.Add("Checkbox", "x30 y55 w260 vModifier1 c" textcolor " ",
            "Juggernaut Enemies")
        Modifier1Checkbox.SetFont("s10", "Segoe UI")

        Modifier2Checkbox := ModifiersGui.Add("Checkbox", "x30 y80 w260 vModifier2 c" textcolor " ", "Flying Enemies")
        Modifier2Checkbox.SetFont("s10", "Segoe UI")

        Modifier3Checkbox := ModifiersGui.Add("Checkbox", "x30 y105 w260 vModifier3 c" textcolor " ",
            "Single Placement")
        Modifier3Checkbox.SetFont("s10", "Segoe UI")

        Modifier4Checkbox := ModifiersGui.Add("Checkbox", "x30 y130 w260 vModifier4 c" textcolor " ", "Unsellable")
        Modifier4Checkbox.SetFont("s10", "Segoe UI")

        Modifier5Checkbox := ModifiersGui.Add("Checkbox", "x30 y155 w260 vModifier5 c" textcolor " ", "High Cost")
        Modifier5Checkbox.SetFont("s10", "Segoe UI")

        Modifier6Checkbox := ModifiersGui.Add("Checkbox", "x30 y180 w260 vModifier6 c" textcolor " ", "Random Units")
        Modifier6Checkbox.SetFont("s10", "Segoe UI")

        ; Separator line
        ModifiersGui.Add("Text", "x20 y210 w280 h1 Background" accentColor)

        ; Styled buttons
        saveBtn := ModifiersGui.Add("Button", "x50 y230 w100 h35 Background" buttonBgColor " c" textcolor,
            "Save & Close")
        saveBtn.SetFont("s10 bold", "Segoe UI")
        saveBtn.OnEvent("Click", (*) => (SaveModifierExclusionStates(), ModifiersGui.Hide()))

        cancelBtn := ModifiersGui.Add("Button", "x170 y230 w100 h35 Background" buttonBgColor " c" textcolor, "Cancel")
        cancelBtn.SetFont("s10 bold", "Segoe UI")
        cancelBtn.OnEvent("Click", (*) => ModifiersGui.Hide())

        ; Add OnEvent handlers to save state on change
        Modifier1Checkbox.OnEvent("Click", (*) => SaveModifierExclusionStates())
        Modifier2Checkbox.OnEvent("Click", (*) => SaveModifierExclusionStates())
        Modifier3Checkbox.OnEvent("Click", (*) => SaveModifierExclusionStates())
        Modifier4Checkbox.OnEvent("Click", (*) => SaveModifierExclusionStates())
        Modifier5Checkbox.OnEvent("Click", (*) => SaveModifierExclusionStates())
        Modifier6Checkbox.OnEvent("Click", (*) => SaveModifierExclusionStates())
    }

    LoadModifierExclusionStates()
    ModifiersGui.Show("w320 h280")
}
SaveModifierExclusionStates() {
    global Modifier1Checkbox, Modifier2Checkbox, Modifier3Checkbox, Modifier4Checkbox, Modifier5Checkbox,
        Modifier6Checkbox
    modifierStates := Modifier1Checkbox.Value "|" Modifier2Checkbox.Value "|" Modifier3Checkbox.Value "|" Modifier4Checkbox
        .Value "|" Modifier5Checkbox.Value "|" Modifier6Checkbox.Value
    settingsDir := A_ScriptDir . "\Settings"
    if !DirExist(settingsDir)
        DirCreate(settingsDir)
    if FileExist(settingsDir . "\ModifierExclusions.txt")
        FileDelete(settingsDir . "\ModifierExclusions.txt")
    FileAppend modifierStates, settingsDir . "\ModifierExclusions.txt"
}

LoadModifierExclusionStates() {
    global Modifier1Checkbox, Modifier2Checkbox, Modifier3Checkbox, Modifier4Checkbox, Modifier5Checkbox,
        Modifier6Checkbox
    modifierExclusionsFile := A_ScriptDir . "\Settings\ModifierExclusions.txt"
    if FileExist(modifierExclusionsFile) {
        local modifierStates := FileRead(modifierExclusionsFile)
        parts := StrSplit(modifierStates, "|")
        if (parts.Length = 6) {
            Modifier1Checkbox.Value := parts[1]
            Modifier2Checkbox.Value := parts[2]
            Modifier3Checkbox.Value := parts[3]
            Modifier4Checkbox.Value := parts[4]
            Modifier5Checkbox.Value := parts[5]
            Modifier6Checkbox.Value := parts[6]
        }
    }
}

MainUI.Add("Text", "x12 y5 w800 +BackgroundTrans c" textcolor, "Goon AFS " Version)
MainUI.Show("w1300 h775")
LOADWEBHOOKK() {
    webhookFile := A_ScriptDir "\Settings\Webhook.txt"
    if (FileExist(webhookFile)) {
        webhookContent := FileRead(webhookFile)
        webhookSettings := StrSplit(webhookContent, "`n")
        for setting in webhookSettings {
            parts := StrSplit(setting, "=")
            if (parts.Length = 2) {
                if (parts[1] = "Webhook")
                    MainUI["MyEdit"].Value := parts[2]
                else if (parts[1] = "DiscordID")
                    MainUI["DiscordIdEdit"].Value := parts[2]
                if webhookcontent != "" {
                    WebhookCheckbox := true
                }
            }
        }
    }
}

ClearAll(*) {
    loop 72 {
        MainUI["Unit" . A_Index].Value := ""
        MainUI["Upgrade" . A_Index].Text := "0"
        MainUI["X" . A_Index].Value := ""
        MainUI["Y" . A_Index].Value := ""
        MainUI["CopyFrom" . A_Index].Value := ""
    }
    UpdateText("All fields cleared")
}

Gui_LButtonDown(guiObj, *) {
    ; This function allows dragging of a custom-caption GUI
    PostMessage 0xA1, 2, , , guiObj.Hwnd ; HTCAPTION = 2
}
ClearAll2() {
    loop 72 {
        MainUI["Unit" . A_Index].Value := ""
        MainUI["Upgrade" . A_Index].Text := "0"
        MainUI["X" . A_Index].Value := ""
        MainUI["Y" . A_Index].Value := ""
        MainUI["CopyFrom" . A_Index].Value := ""
    }
}
CustomModeCreateBtn.OnEvent("Click", CreateCustomMode)
CreateCustomMode(*) {
    name := Trim(CustomModeEdit.Text)
    if (name = "") {
        MsgBox("Enter a name for the custom mode.")
        return
    }
    file := A_ScriptDir "\Settings\Customs\" name ".txt"
    if FileExist(file) {
        MsgBox("A custom mode with this name already exists.")
        return
    }
    try {
        FileAppend("", file)
        UpdateText("Created custom mode: " name)
        UpdateCustomModes()
        CustomModeSelect.Text := name
        LoadSelectedCustomMode()
    } catch Error as e {
        MsgBox("Failed to create custom mode: " e.Message)
    }
}

UpdateCustomModes() {
    global CustomModeSelect
    CustomModeSelect.Delete()
    loop files, A_ScriptDir "\Settings\Customs\*.txt" {
        name := StrReplace(A_LoopFileName, ".txt")
        CustomModeSelect.Add([name])
    }
}

CustomModeSelect.OnEvent("Change", LoadSelectedCustomMode)
LoadSelectedCustomMode(*) {
    selected := CustomModeSelect.Text
    if (selected = "") {
        return
    }

    file := A_ScriptDir "\Settings\Customs\" selected ".txt"
    if !FileExist(file) {
        UpdateText("Custom mode file not found: " selected)
        return
    }

    loop 72 {
        MainUI["Unit" . A_Index].Value := ""
        MainUI["Upgrade" . A_Index].Text := "0"
        MainUI["X" . A_Index].Value := ""
        MainUI["Y" . A_Index].Value := ""
        if MainUI.HasProp("CopyFrom" . A_Index) {
            MainUI["CopyFrom" . A_Index].Value := ""
        }
    }

    try {
        fileContent := FileRead(file)
        settings := StrSplit(fileContent, "`n")
        currentIndex := 0

        for setting in settings {
            setting := Trim(setting)
            if (setting = "")
                continue
            parts := StrSplit(setting, "=")
            if (parts.Length != 2)
                continue
            settingName := Trim(parts[1])
            settingValue := Trim(parts[2])

            if (settingName = "Index") {
                currentIndex := settingValue
                continue
            }

            if (currentIndex > 0 && currentIndex <= 72 && settingName != "Wait") {
                try {
                    if (settingName = "Upgrade") {
                        MainUI["Upgrade" . currentIndex].Text := settingValue
                    } else {
                        MainUI[settingName . currentIndex].Value := settingValue
                    }
                } catch Error as e {
                    MsgBox("Error loading setting " settingName ": " e.Message)
                    return
                }
            }
        }
        UpdateText("Loaded custom mode: " selected)
    } catch Error as e {
        MsgBox("Failed to load custom mode: " e.Message)
    }
}
; LoadModeSettings(*) {
;     if (ModeSelect.Text = "Custom") {
;         return
;     }
;     loop 72 {
;         MainUI["Unit" . A_Index].Value := ""
;         MainUI["Upgrade" . A_Index].Text := "0"
;         MainUI["X" . A_Index].Value := ""
;         MainUI["Y" . A_Index].Value := ""
;         MainUI["CopyFrom" . A_Index].Value := ""
;     }

;     submitted := MainUI.Submit(false)
;     mode := submitted.SelectedMode

;     if (!mode || mode = "") {
;         MsgBox("Please select a valid mode")
;         return false
;     }
;     settingsFile := A_ScriptDir "\Settings\" mode ".txt"

;     if FileExist(settingsFile) {
;         try {
;             fileContent := FileRead(settingsFile)
;             settings := StrSplit(fileContent, "`n")
;             currentIndex := 0

;             for setting in settings {
;                 setting := Trim(setting)
;                 if (setting) {
;                     parts := StrSplit(setting, "=")
;                     if (parts.Length = 2) {
;                         settingName := Trim(parts[1])
;                         settingValue := Trim(parts[2])

;                         if (settingName = "Index")
;                             currentIndex := settingValue
;                         else if (currentIndex > 0 && currentIndex <= 72 && settingName != "Wait") {
;                             try {
;                                 if (settingName = "Upgrade") or (settingName = "Wait")
;                                     MainUI["Upgrade" . currentIndex].Text := settingValue
;                                 else
;                                     MainUI[settingName . currentIndex].Value := settingValue
;                             } catch Error as e {
;                                 MsgBox("Error loading setting " settingName ": " e.Message)
;                                 return false
;                             }
;                         }
;                     }
;                 }
;             }
;             UpdateText("Settings loaded for " mode)
;         } catch Error as e {
;             MsgBox("Error reading settings file: " e.Message)
;             return false
;         }
;     } else {
;         try {
;             defaultSettings := ""
;             loop 72 {
;                 defaultSettings .= "Index=" A_Index "`n"
;                 defaultSettings .= "Unit=`n"
;                 defaultSettings .= "Upgrade=0`n"
;                 defaultSettings .= "X=`n"
;                 defaultSettings .= "Y=`n`n"
;             }
;             FileAppend(defaultSettings, settingsFile)
;             UpdateText("Created new settings file for " mode)
;         } catch Error as e {
;             UpdateText("Error creating settings file: " e.Message)
;             return false;
;         }
;     }

;     MainUI.Show("w1300 h750")
;     return true
; }

SaveSettings(*) {
    try {
        submitted := MainUI.Submit(false)
        webhookContent := submitted.MyEdit
        discordIdContent := submitted.DiscordIdEdit
        mode := submitted.SelectedMode
        selectedCustom := submitted.SelectedCustomMode
        selectedWorld := submitted.WorldSelect
        selectedLegend := submitted.LegendSelect
        selectedRaid := submitted.RaidSelect

        if !DirExist(A_ScriptDir "\Settings")
            DirCreate(A_ScriptDir "\Settings")
        if !DirExist(A_ScriptDir "\Settings\Worlds")
            DirCreate(A_ScriptDir "\Settings\Worlds")
        if !DirExist(A_ScriptDir "\Settings\Infinites")
            DirCreate(A_ScriptDir "\Settings\Infinites")
        if !DirExist(A_ScriptDir "\Settings\Legends")
            DirCreate(A_ScriptDir "\Settings\Legends")
        if !DirExist(A_ScriptDir "\Settings\Raids")
            DirCreate(A_ScriptDir "\Settings\Raids")

        webhookFile := A_ScriptDir "\Settings\Webhook.txt"
        try {
            if FileExist(webhookFile)
                FileDelete(webhookFile)
            FileAppend("Webhook=" webhookContent "`nDiscordID=" discordIdContent, webhookFile)
        } catch Error as e {
            UpdateText("Error saving webhook: " e.Message)
        }

        keybindsFile := A_ScriptDir "\Settings\Keybinds.txt"
        try {
            if FileExist(keybindsFile)
                FileDelete(keybindsFile)
            FileAppend(
                "StartHotkey=" submitted.StartHotkey "`n" .
                "PauseHotkey=" submitted.PauseHotkey "`n" .
                "StopHotkey=" submitted.StopHotkey "`n" .
                "SaveImageHotkey=" submitted.SaveImageHotkey,
                keybindsFile
            )
            UpdateText("Created keybinds file")
        } catch Error as e {
            UpdateText("Error creating keybinds file: " e.Message)
        }

        if (!mode) {
            MsgBox("Please select a mode before saving")
            return false
        }
        webhookFile := A_ScriptDir "\Settings\Webhook.txt"
        try {
            if FileExist(webhookFile)
                FileDelete(webhookFile)
            FileAppend("Webhook=" webhookContent "`nDiscordID=" discordIdContent, webhookFile)
        } catch Error as e {
            UpdateText("Error saving webhook: " e.Message)
            return false
        }

        settingsText := ""
        loop 72 {
            x := MainUI["X" . A_Index].Value
            y := MainUI["Y" . A_Index].Value
            if (x != "" && (!IsNumber(x) || x < 0 || x > 800)) {
                MsgBox("Invalid X coordinate for Unit " A_Index)
                return false
            }
            if (y != "" && (!IsNumber(y) || y < 0 || y > 600)) {
                MsgBox("Invalid Y coordinate for Unit " A_Index)
                return false
            }

            settingsText .= "Index=" A_Index "`n"
            settingsText .= "Unit=" MainUI["Unit" . A_Index].Value "`n"
            settingsText .= "Upgrade=" MainUI["Upgrade" . A_Index].Text "`n"
            settingsText .= "X=" x "`n"
            settingsText .= "Y=" y "`n`n"
        }

        settingsFile := ""
        if (mode = "Custom") {
            if (!selectedCustom || selectedCustom = "") {
                MsgBox("Please select a Custom mode")
                return false
            }
            settingsFile := A_ScriptDir "\Settings\Customs\" selectedCustom ".txt"
        } else if (mode = "Story") {
            if (!selectedWorld || selectedWorld = "") {
                MsgBox("Please select a valid world")
                return false
            }
            settingsFile := A_ScriptDir "\Settings\Worlds\" selectedWorld ".txt"
        } else if (mode = "Infinite") {
            if (!selectedWorld || selectedWorld = "") {
                MsgBox("Please select a valid world")
                return false
            }
            settingsFile := A_ScriptDir "\Settings\Infinites\" selectedWorld ".txt"
        } else if (mode = "Legend") {
            if (!selectedLegend || selectedLegend = "") {
                MsgBox("Please select a valid legend world")
                return false
            }
            settingsFile := A_ScriptDir "\Settings\Legends\" selectedLegend ".txt"
        } else if (mode = "Raid") {
            if (!selectedRaid || selectedRaid = "") {
                MsgBox("Please select a valid raid world")
                return false
            }
            settingsFile := A_ScriptDir "\Settings\Raids\" selectedRaid ".txt"
        } else {
            settingsFile := A_ScriptDir "\Settings\" mode ".txt"
        }

        try {
            if FileExist(settingsFile)
                FileDelete(settingsFile)
            FileAppend(settingsText, settingsFile)

            if (mode = "Custom")
                UpdateText("Settings saved successfully for Custom mode")
            else if (mode = "Story")
                UpdateText("Settings saved successfully for " selectedWorld)
            else if (mode = "Infinite")
                UpdateText("Settings saved successfully for Infinite " selectedWorld)
            else if (mode = "Legend")
                UpdateText("Settings saved successfully for " selectedLegend)
            else if (mode = "Raid")
                UpdateText("Settings saved successfully for " selectedRaid)
            else
                UpdateText("Settings saved successfully for " mode)

            return true
        } catch Error as e {
            UpdateText("Error saving settings: " e.Message)
            return false
        }
    } catch Error as e {
        UpdateText("Error in SaveSettings: " e.Message)
        return false
    }
}

LoadModeSettings(*) {
    submitted := MainUI.Submit(false)
    mode := submitted.SelectedMode
    selectedWorld := submitted.WorldSelect
    selectedLegend := submitted.LegendSelect
    selectedRaid := submitted.RaidSelect

    ; Validate required selection for each mode
    switch mode {
        case "", "Custom":
            UpdateText(mode = "" ? "Please select a valid mode" : "")
            return false
        case "Story":
            if (!selectedWorld) {
                UpdateText("Please select a valid world")
                return false
            }
            settingsFile := A_ScriptDir "\Settings\Worlds\" selectedWorld ".txt"
        case "Infinite":
            if (!selectedWorld) {
                UpdateText("Please select a valid world")
                return false
            }
            settingsFile := A_ScriptDir "\Settings\Infinites\" selectedWorld ".txt"
        case "Legend":
            if (!selectedLegend) {
                UpdateText("Please select a valid legend world")
                return false
            }
            settingsFile := A_ScriptDir "\Settings\Legends\" selectedLegend ".txt"
        case "Raid":
            if (!selectedRaid) {
                UpdateText("Please select a valid raid world")
                return false
            }
            settingsFile := A_ScriptDir "\Settings\Raids\" selectedRaid ".txt"
        case "Inferno":
            settingsFile := A_ScriptDir "\Settings\Inferno.txt"
        default:
            settingsFile := A_ScriptDir "\Settings\" mode ".txt"
    }

    ; Clear all slots before loading
    loop 72 {
        MainUI["Unit" . A_Index].Value := ""
        MainUI["Upgrade" . A_Index].Text := "0"
        MainUI["X" . A_Index].Value := ""
        MainUI["Y" . A_Index].Value := ""
        MainUI["CopyFrom" . A_Index].Value := ""
    }

    ; Load settings if file exists
    if FileExist(settingsFile) {
        try {
            settings := StrSplit(FileRead(settingsFile), "`n")
            currentIndex := 0

            for setting in settings {
                setting := Trim(setting)
                if (!setting) 
                    continue

                parts := StrSplit(setting, "=")
                if (parts.Length = 2) {
                    settingName := Trim(parts[1])
                    settingValue := Trim(parts[2])

                    if (settingName = "Index")
                        currentIndex := settingValue
                    else if (currentIndex && currentIndex <= 72 && settingName != "Wait") {
                        try {
                            if (settingName = "Upgrade")
                                MainUI["Upgrade" . currentIndex].Text := settingValue
                            else
                                MainUI[settingName . currentIndex].Value := settingValue
                        } catch Error as e {
                            MsgBox("Error loading setting " settingName ": " e.Message)
                            return false
                        }
                    }
                }
            }

            ; Informative mode-specific feedback
            msg := "Settings loaded for "
            switch mode {
                case "Story", "Infinite": msg .= selectedWorld
                case "Legend": msg .= selectedLegend
                case "Raid": msg .= selectedRaid
                default: msg .= mode
            }
            UpdateText(msg)

        } catch Error as e {
            MsgBox("Error reading settings file: " e.Message)
            return false
        }

    ; If settings file doesn't exist → create default
    } else {
        try {
            defaultSettings := ""
            loop 72 {
                defaultSettings .= "Index=" A_Index "`n"
                defaultSettings .= "Unit=`n"
                defaultSettings .= "Upgrade=0`n"
                defaultSettings .= "X=`n"
                defaultSettings .= "Y=`n`n"
            }
            FileAppend(defaultSettings, settingsFile)
            UpdateText("New settings file created for " mode)
        } catch Error as e {
            UpdateText("Error creating settings file: " e.Message)
            return false
        }
    }

    MainUI.Show("w1300 h775")
    return true
}

SaveImage(*) {
    Mode := GetMode()
    ActivateRoblox()
    Sleep 500
    if MsgBox("Zoom Out?", "ZoomTech", "YesNo") = "Yes" {
        ZoomTech()
    }
    ActivateRoblox()

    if (MainUI["SelectedMode"].Text = "Custom") {
        customName := MainUI["SelectedCustomMode"].Text
        if (customName = "") {
            customName := "Custom"
        }
        filePath := A_ScriptDir "\Images\" customName ".png"
    } else if (MainUI["SelectedMode"].Text = "Trials") {
        filePath := A_ScriptDir "\Images\Trials.png"
    } else if (MainUI["SelectedMode"].Text = "Story" || MainUI["SelectedMode"].Text = "Infinite") {
        filePath := A_ScriptDir "\Images\Worlds\" WorldSelect.Text ".png"
    } else if (MainUI["SelectedMode"].Text = "Legend") {
        filePath := A_ScriptDir "\Images\Worlds\" LegendSelect.Text ".png"
    } else if (MainUI["SelectedMode"].Text = "Raid") {
        filePath := A_ScriptDir "\Images\Raids\" RaidSelect.Text ".png"
    } else if (MainUI["SelectedMode"].Text = "Inferno") {
        filePath := A_ScriptDir "\Images\InfernoEvent\" "Amaterasa.png"
    } else {
        filePath := A_ScriptDir "\Images\Custom.png"
    }
    pToken := Gdip_Startup()
    WinGetClientPos(&X, &Y, &W, &H, roblox)
    pBitmap := Gdip_BitmapFromScreen(X "|" Y "|" W "|" H)
    Gdip_SaveBitmapToFile(pBitmap, filePath)
    Gdip_DisposeImage(pBitmap)
    Gdip_Shutdown(pToken)
    UpdateText("Custom image saved to " filePath)
}


SelectCords(index, *) {
    static isGuiOpen := false
    if (isGuiOpen) {
        MsgBox("Coordinate selection window is already open")
        return false
    }
    isGuiOpen := true

    imageGui := Gui("", "Select Coordinates | RIGHT CLICK TO SELECT")
    imageGui.Opt("+AlwaysOnTop")
    modeImages := []

    imageMap := Map()
    for modePair in modeImages {
        imageMap[modePair[1]] := modePair[2]
    }

    customImagesDir := A_ScriptDir "\Images\"
    loop files, A_ScriptDir "\Settings\Customs\*.txt" {
        customName := StrReplace(A_LoopFileName, ".txt")
        imagePath := customImagesDir customName ".png"
        imageMap[customName] := imagePath
    }

    selectedMode := MainUI["SelectedMode"].Text
    legendWorld := MainUI["LegendSelect"].Text
    worldName := MainUI["WorldSelect"].Text

    worldImagesDir := A_ScriptDir "\Images\Worlds\"
    imageToUse := ""

    if (selectedMode = "Custom") {
        customName := MainUI["SelectedCustomMode"].Text
        if (customName != "") {
            imageToUse := customImagesDir customName ".png"
        }
    } else if (selectedMode = "Story" || selectedMode = "Infinite") {
        if (worldName != "") {
            imageToUse := worldImagesDir worldName ".png"
        }
    } else if (selectedMode = "Legend") {
        if (legendWorld != "") {
            imageToUse := worldImagesDir legendWorld ".png"
        }
    } else if (selectedMode = "Raid") {
        raidName := MainUI["RaidSelect"].Text
        if (raidName != "") {
            imageToUse := A_ScriptDir "\Images\Raids\" raidName ".png"
        }
     } else if (selectedMode = "Inferno") {
        imageToUse := A_ScriptDir "\Images\InfernoEvent\Amaterasa.png"
    }

    if !FileExist(imageToUse) {
        MsgBox("Image not found: " imageToUse)
        isGuiOpen := false
        return false
    }

    try {
        picture := imageGui.Add("Picture", "x0 y0 w800 h600 +0x4000000", imageToUse)
    } catch Error as e {
        MsgBox("Error loading image: " e.Message)
        isGuiOpen := false
        return false
    }

    markers := []
    loop 72 {
        if (MainUI["X" A_Index].Value != "" && MainUI["Y" A_Index].Value != "") {
            x := MainUI["X" A_Index].Value
            y := MainUI["Y" A_Index].Value

            if (!IsNumber(x) || !IsNumber(y)) {
                continue
            }

            x := Integer(x)
            y := Integer(y)

            imagePath := A_ScriptDir "\Images\BlueDot.png"
            if (!FileExist(imagePath)) {
                try {
                    marker := imageGui.Add("Text", "x" x " y" y " w20 w20 Background0x0000FF Center", "●")
                    marker.ToolTip := "Unit " A_Index ": " MainUI["Unit" A_Index].Value
                    markers.Push(marker)
                } catch Error as e {
                    throw ("Error adding text marker: " e.Message " " e.What " " e.Line " " e.File)
                }
                continue
            }

            try {
                marker := imageGui.Add("Picture", "x" (x - 10) " y" (y - 10) " w20 h20 BackgroundTrans", imagePath)
                marker.ToolTip := "Unit " A_Index ": " MainUI["Unit" A_Index].Value
                number := imageGui.Add("Text", "x" (x + 5) " y" (y + 10) " w20 h20 BackgroundTrans", A_Index)
                number.SetFont("s12", "bold")
                markers.Push(marker)
            } catch Error as e {
                UpdateText("Error adding marker: " e.Message " " e.What " " e.Line " " e.File)
            }
        }
    }

    imageGui.OnEvent("Close", (*) => (imageGui.Destroy(), isGuiOpen := false))
    WinGetPos(&x, &y, &w, &h, roblox)
    imageGui.Show("x" x " y" y " w800 h600")

    KeyWait "RButton", "D"
    try {
        if (!imageGui.Hwnd || !WinExist(imageGui)) {
            isGuiOpen := false
            return
        }

        CoordMode("Mouse", "Client")
        MouseGetPos(&x, &y, &win)

        if (!WinActive(imageGui)) {
            imageGui.Destroy()
            isGuiOpen := false
            return
        }

        if (x > 800 || y > 600) {
            imageGui.Destroy()
            isGuiOpen := false
            return
        }
        x := Max(0, Min(x, 800))
        y := Max(0, Min(y, 600))
        MainUI["X" index].Value := x
        MainUI["Y" index].Value := y
    } catch Error as e {
        isGuiOpen := false
        return
    }

    imageGui.Destroy()
    isGuiOpen := false
    SaveSettings()
}
#HotIf WinExist(roblox)

CopyUnitData(index, *) {
    try {
        value := MainUI["CopyFrom" . index].Value
        if (value = "-") {
            loopCount := 72 - index
            loop loopCount {
                i := index + A_Index - 1
                MainUI["Unit" . i].Value := MainUI["Unit" . (i + 1)].Value
                MainUI["Upgrade" . i].Text := MainUI["Upgrade" . (i + 1)].Text
                MainUI["X" . i].Value := MainUI["X" . (i + 1)].Value
                MainUI["Y" . i].Value := MainUI["Y" . (i + 1)].Value
                MainUI["CopyFrom" . i].Value := MainUI["CopyFrom" . (i + 1)].Value
            }
            MainUI["Unit72"].Value := ""
            MainUI["Upgrade72"].Text := "0"
            MainUI["X72"].Value := ""
            MainUI["Y72"].Value := ""
            MainUI["CopyFrom72"].Value := ""
            UpdateText("Cleared data for unit " index " and shifted units down.")
            return
        } else if (value = "+") {
            loopCount := 72 - index
            loop loopCount {
                i := 72 - A_Index + 1
                if (i > index) {
                    MainUI["Unit" . i].Value := MainUI["Unit" . (i - 1)].Value
                    MainUI["Upgrade" . i].Text := MainUI["Upgrade" . (i - 1)].Text
                    MainUI["X" . i].Value := MainUI["X" . (i - 1)].Value
                    MainUI["Y" . i].Value := MainUI["Y" . (i - 1)].Value
                    MainUI["CopyFrom" . i].Value := ""
                }
            }
            MainUI["Unit" . index].Value := ""
            MainUI["Upgrade" . index].Text := "0"
            MainUI["X" . index].Value := ""
            MainUI["Y" . index].Value := ""
            MainUI["CopyFrom" . index].Value := ""
            UpdateText("Inserted a blank slot at unit " index " and shifted units down.")
            return
        }

        sourceIndex := Integer(value)
        if (sourceIndex > 0 && sourceIndex <= 72) {
            MainUI["Unit" . index].Value := MainUI["Unit" . sourceIndex].Value
            MainUI["Upgrade" . index].Text := MainUI["Upgrade" . sourceIndex].Text
            MainUI["X" . index].Value := MainUI["X" . sourceIndex].Value
            MainUI["Y" . index].Value := MainUI["Y" . sourceIndex].Value
            UpdateText("Copied data from unit " sourceIndex " to " index)
        }
    } catch Error as e {
        UpdateText("Error copying unit data: " e.Message)
    }
}

CopySettings(*) {
    try {
        settingsText := ""
        loop 72 {
            settingsText .= "Index=" A_Index "`n"
            settingsText .= "Unit=" MainUI["Unit" . A_Index].Value "`n"
            settingsText .= "Upgrade=" MainUI["Upgrade" . A_Index].Text "`n"
            settingsText .= "X=" MainUI["X" . A_Index].Value "`n"
            settingsText .= "Y=" MainUI["Y" . A_Index].Value "`n`n"
        }

        A_Clipboard := settingsText

        mode := MainUI["SelectedMode"].Text
        if (mode = "") {
            mode := "CustomSettings"
        }

        filename := A_ScriptDir "\Settings\" mode "_" FormatTime(A_Now, "yyyyMMdd_HHmmss") ".txt"
        FileAppend(settingsText, filename)
        UpdateText("Settings copied to clipboard")

        SetTimer(() => (FileExist(filename) ? FileDelete(filename) : ""), -1000)
    } catch Error as e {
        UpdateText("Error copying settings: " e.Message)
    }
}

PasteSettings(*) {
    try {
        if (A_Clipboard = "") {
            UpdateText("No settings in clipboard")
            return
        }
        settings := StrSplit(A_Clipboard, "`n")
        currentIndex := 0
        for setting in settings {
            setting := Trim(setting)
            if (setting) {
                parts := StrSplit(setting, "=")
                if (parts.Length = 2) {
                    settingName := Trim(parts[1])
                    settingValue := Trim(parts[2])

                    if (settingName = "Index")
                        currentIndex := settingValue
                    else if (currentIndex > 0 && currentIndex <= 72) {
                        try {
                            if (settingName = "Upgrade")
                                MainUI["Upgrade" . currentIndex].Text := settingValue
                            else
                                MainUI[settingName . currentIndex].Value := settingValue
                        } catch Error as e {

                        }
                    }
                }
            }
        }
        UpdateText("Settings pasted successfully")
    } catch Error as e {
        UpdateText("Error pasting settings: " e.Message)
    }
}

MainUI.SetFont("s10 bold")
MainUI.Add("Text", "x302 y668 w80 BackgroundTrans c" textcolor, "Start:")
StartHotkey := MainUI.Add("Hotkey", "x342 y665 w21 h22 vStartHotkey", "F1")

MainUI.Add("Text", "x420 y668 w80 BackgroundTrans c" textcolor, "Pause:")
PauseHotkey := MainUI.Add("Hotkey", "x469 y665 w21 h22 vPauseHotkey", "F2")

MainUI.Add("Text", "x302 y694 w80 BackgroundTrans c" textcolor, "Stop:")
StopHotkey := MainUI.Add("Hotkey", "x342 y693 w21 h22 vStopHotkey", "F3")

MainUI.Add("Text", "x420 y694 w80 BackgroundTrans c" textcolor, "Zoom:")
global SaveImageHotkey := MainUI.Add("Hotkey", "x469 y693 w21 h22 vSaveImageHotkey", "F4")

MainUI.SetFont("s13 bold")

LoadKeybinds() {
    keybindsFile := A_ScriptDir "\Settings\Keybinds.txt"
    if FileExist(keybindsFile) {
        try {
            fileContent := FileRead(keybindsFile)
            settings := StrSplit(fileContent, "`n")

            for setting in settings {
                parts := StrSplit(setting, "=")
                if (parts.Length = 2) {
                    controlName := parts[1]
                    hotkeyValue := parts[2]

                    if (MainUI.HasProp(controlName))
                        MainUI[controlName].Value := hotkeyValue
                }
            }

            SetupHotkeys()

        } catch Error as e {
            MsgBox("Error loading keybinds: " e.Message)
        }
    } else {
        FileAppend(
            "StartHotkey=F1`n" .
            "PauseHotkey=F2`n" .
            "StopHotkey=F3`n" .
            "SaveImageHotkey=F4",
            keybindsFile
        )
    }
}

SetupHotkeys() {
    submitted := MainUI.Submit(false)

    try {
        Hotkey(MainUI["StartHotkey"].Value, "Off")
        Hotkey(MainUI["PauseHotkey"].Value, "Off")
        Hotkey(MainUI["StopHotkey"].Value, "Off")
        Hotkey(MainUI["SaveImageHotkey"].Value, "Off")
    }

    if (submitted.StartHotkey) {
        try {
            Hotkey(submitted.StartHotkey, StartMacro)
            UpdateText("Start hotkey set to " submitted.StartHotkey)
        } catch Error as e {
            UpdateText("Error setting start hotkey: " e.Message)
        }
    }

    if (submitted.PauseHotkey) {
        try {
            Hotkey(submitted.PauseHotkey, PauseMacro)
            UpdateText("Pause hotkey set to " submitted.PauseHotkey)
        } catch Error as e {
            UpdateText("Error setting pause hotkey: " e.Message)
        }
    }

    if (submitted.StopHotkey) {
        try {
            Hotkey(submitted.StopHotkey, StopMacro)
            UpdateText("Stop hotkey set to " submitted.StopHotkey)
        } catch Error as e {
            UpdateText("Error setting stop hotkey: " e.Message)
        }
    }

    if (submitted.SaveImageHotkey) {
        try {
            Hotkey(submitted.SaveImageHotkey, SaveImage)
            UpdateText("Save Image hotkey set to " submitted.SaveImageHotkey)
        } catch Error as e {
            UpdateText("Error setting save image hotkey: " e.Message)
        }
    }
}
StartHotkey.OnEvent("Change", (*) => SetupHotkeys())
PauseHotkey.OnEvent("Change", (*) => SetupHotkeys())
StopHotkey.OnEvent("Change", (*) => SetupHotkeys())
SaveImageHotkey.OnEvent("Change", (*) => SetupHotkeys())

PauseMacro(*) {
    if !WinExist(roblox) {
        return
    }
    static paused := false
    paused := !paused
    Pause paused
    UpdateText(paused ? "Paused" : "Resumed")
}
StopMacro(*) {
    Reload()
}

CreateDirectories()
LoadKeybinds()
CheckForUpdates()

PreviousPage(*) {
    global CurrentPage, PrevBtn, NextBtn, PageDisplay

    if (CurrentPage > 1) {
        startUnit := (CurrentPage - 1) * 18 + 1
        endUnit := CurrentPage * 18
        loop endUnit - startUnit + 1 {
            unitIndex := startUnit + A_Index - 1
            try {
                MainUI["UnitNum" . unitIndex].Visible := false
                MainUI["Unit" . unitIndex].Visible := false
                MainUI["Upgrade" . unitIndex].Visible := false
                MainUI["X" . unitIndex].Visible := false
                MainUI["Y" . unitIndex].Visible := false
                MainUI["CopyFrom" . unitIndex].Visible := false
                MainUI["Coords" . unitIndex].Visible := false
            }
        }

        CurrentPage--

        startUnit := (CurrentPage - 1) * 18 + 1
        endUnit := CurrentPage * 18
        loop endUnit - startUnit + 1 {
            unitIndex := startUnit + A_Index - 1
            try {
                MainUI["UnitNum" . unitIndex].Visible := true
                MainUI["Unit" . unitIndex].Visible := true
                MainUI["Upgrade" . unitIndex].Visible := true
                MainUI["X" . unitIndex].Visible := true
                MainUI["Y" . unitIndex].Visible := true
                MainUI["CopyFrom" . unitIndex].Visible := true
                MainUI["Coords" . unitIndex].Visible := true
            }
        }

        PageDisplay.Text := CurrentPage . "/" . TotalPages
        PrevBtn.Enabled := CurrentPage > 1
        NextBtn.Enabled := true
        UpdateText("Switched to page " CurrentPage " (units " startUnit "-" endUnit ")")
    }
}

NextPage(*) {
    global CurrentPage, PrevBtn, NextBtn, PageDisplay

    if (CurrentPage < TotalPages) {
        startUnit := (CurrentPage - 1) * 18 + 1
        endUnit := CurrentPage * 18
        loop endUnit - startUnit + 1 {
            unitIndex := startUnit + A_Index - 1
            try {
                MainUI["UnitNum" . unitIndex].Visible := false
                MainUI["Unit" . unitIndex].Visible := false
                MainUI["Upgrade" . unitIndex].Visible := false
                MainUI["X" . unitIndex].Visible := false
                MainUI["Y" . unitIndex].Visible := false
                MainUI["CopyFrom" . unitIndex].Visible := false
                MainUI["Coords" . unitIndex].Visible := false
            }
        }

        CurrentPage++

        startUnit := (CurrentPage - 1) * 18 + 1
        endUnit := CurrentPage * 18
        loop endUnit - startUnit + 1 {
            unitIndex := startUnit + A_Index - 1
            try {
                MainUI["UnitNum" . unitIndex].Visible := true
                MainUI["Unit" . unitIndex].Visible := true
                MainUI["Upgrade" . unitIndex].Visible := true
                MainUI["X" . unitIndex].Visible := true
                MainUI["Y" . unitIndex].Visible := true
                MainUI["CopyFrom" . unitIndex].Visible := true
                MainUI["Coords" . unitIndex].Visible := true
            }
        }

        PageDisplay.Text := CurrentPage . "/" . TotalPages
        PrevBtn.Enabled := true
        NextBtn.Enabled := CurrentPage < TotalPages
        UpdateText("Switched to page " CurrentPage " (units " startUnit "-" endUnit ")")
    }
}

CreateSettingsFile() {
    if !DirExist(A_ScriptDir "\Settings") {
        DirCreate(A_ScriptDir "\Settings")
        UpdateText("Settings directory created")
    }
    ; modes := []

    defaultSettings := ""
    loop 72 {
        defaultSettings .= "Index=" A_Index "`n"
        defaultSettings .= "Unit=`n"
        defaultSettings .= "Upgrade=0`n"
        defaultSettings .= "X=`n"
        defaultSettings .= "Y=`n`n"
    }

    ; for currentMode in modes {
    ;     if (currentMode != "") {
    ;         modeFile := A_ScriptDir "\Settings\" currentMode ".txt"
    ;         if !FileExist(modeFile) {
    ;             try {
    ;                 FileAppend(defaultSettings, modeFile)
    ;                 UpdateText("Created settings for " currentMode)
    ;             } catch Error as e {
    ;                 UpdateText("Error creating " currentMode " settings: " e.Message)
    ;             }
    ;         }
    ;     }
    ; }

    DelayFile := A_ScriptDir "\Settings\PlacementDelay.txt"
    if !FileExist(DelayFile) {
        try {
            FileAppend("PlacementDelayMS=350", DelayFile)
            UpdateText("Created Delay file")
        } catch Error as e {
            UpdateText("Error Creating Placement Delay File: " e.Message)
        }
    }
    keybindsFile := A_ScriptDir "\Settings\Keybinds.txt"
    if !FileExist(keybindsFile) {
        try {
            FileAppend(
                "StartHotkey=F1`n" .
                "PauseHotkey=F2`n" .
                "StopHotkey=F3`n" .
                "SaveImageHotkey=F4",
                keybindsFile
            )
            UpdateText("Created keybinds file")
        } catch Error as e {
            UpdateText("Error creating keybinds file: " e.Message)
        }
    }
    webhookFile := A_ScriptDir "\Settings\Webhook.txt"
    if !FileExist(webhookFile) {
        try {
            FileAppend("Webhook=`nDiscordID=", webhookFile)
            UpdateText("Created webhook file")
        } catch Error as e {
            UpdateText("Error creating webhook file: " e.Message)
        }
    }
    privateServerFile := A_ScriptDir "\Settings\PrivateServer.txt"
    if !FileExist(privateServerFile) {
        try {
            FileAppend("", privateServerFile)
            UpdateText("Created Private Server settings file.")
        } catch Error as e {
            UpdateText("Error creating Private Server settings file: " e.Message)
        }
    }
    Cards := A_ScriptDir "\Settings\Cards.txt"
    if !FileExist(Cards) {
        try {
            FileAppend("Cards=1", Cards)
        }
    }

}

if !DirExist(A_ScriptDir "\Settings\Customs") {
    DirCreate(A_ScriptDir "\Settings\Customs")
    UpdateText("Customs directory created")
}
PrivateServerBtn := MainUI.Add("Button", "x340 y730 w120 h30 Background" buttonBgColor " c" textcolor,
    "Private Server")
PrivateServerBtn.OnEvent("Click", (*) => PrivateServerGUI())
PrivateServerGUI() {
    global PrivateServerWin, PrivateServerLinkEdit, textcolor, bgColor, accentColor, buttonBgColor

    PrivateServerWin := Gui("-Caption +Border +AlwaysOnTop", "Private Server Settings")
    PrivateServerWin.MarginX := 0
    PrivateServerWin.MarginY := 0
    PrivateServerWin.BackColor := bgColor
    PrivateServerWin.SetFont("s12 bold", "Segoe UI")

    PrivateServerWin.Add("Text", "x0 y0 w420 h1 Background" accentColor)  ; Top border
    PrivateServerWin.Add("Text", "x0 y0 w1 h180 Background" accentColor)  ; Left border
    PrivateServerWin.Add("Text", "x419 y0 w1 h180 Background" accentColor)  ; Right border
    PrivateServerWin.Add("Text", "x0 y179 w420 h1 Background" accentColor)  ; Bottom border

    titleText := PrivateServerWin.Add("Text", "x1 y5 w370 h30 Center " textcolor " BackgroundTrans",
        "Private Server Settings")
    titleText.SetFont("s14 bold", "Segoe UI")
    titleText.OnEvent("Click", (*) => PostMessage(0xA1, 2, , , PrivateServerWin))

    ; closeBtn := PrivateServerWin.Add("Text", "x390 y5 w25 h25 Center c" textcolor " BackgroundTrans", "✕")
    ; closeBtn.SetFont("s12 bold", "Segoe UI")
    ; closeBtn.OnEvent("Click", (*) => PrivateServerWin.Hide())
    ; closeBtn.OnEvent("C", (*) => closeBtn.Opt("Background" accentColor))
    ; closeBtn.OnEvent("MouseLeave", (*) => closeBtn.Opt("BackgroundTrans"))

    PrivateServerWin.Add("Text", "x20 y40 w380 h2 Background" accentColor)

    instructionText := PrivateServerWin.Add("Text", "x30 y55 w360 h20 " textcolor " BackgroundTrans",
        "Enter your private server link below:")
    instructionText.SetFont("s10", "Segoe UI")

    linkLabel := PrivateServerWin.Add("Text", "x30 y80 w80 h20 " textcolor " BackgroundTrans", "Server Link:")
    linkLabel.SetFont("s10 bold", "Segoe UI")

    PrivateServerLinkEdit := PrivateServerWin.Add("Edit", "x30 y100 w360 h25 Background" buttonBgColor " c" textcolor " VScroll"
    )
    PrivateServerLinkEdit.SetFont("s10", "Segoe UI")

    PrivateServerWin.Add("Text", "x20 y135 w380 h1 Background" accentColor)

    testBtn := PrivateServerWin.Add("Button", "x50 y145 w100 h25 Background" buttonBgColor " c" textcolor, "Test Link")
    testBtn.SetFont("s10 bold", "Segoe UI")
    testBtn.OnEvent("Click", (*) => TestPrivateServerLink())

    saveBtn := PrivateServerWin.Add("Button", "x170 y145 w100 h25 Background" buttonBgColor " c" textcolor, "Save")
    saveBtn.SetFont("s10 bold", "Segoe UI")
    saveBtn.OnEvent("Click", (*) => SavePrivateServerLink())

    cancelBtn := PrivateServerWin.Add("Button", "x290 y145 w100 h25 Background" buttonBgColor " c" textcolor, "Close")
    cancelBtn.SetFont("s10 bold", "Segoe UI")
    cancelBtn.OnEvent("Click", (*) => PrivateServerWin.Hide())

    PrivateServerWin.Show("w420 h180")
    LoadPrivateServerLink()
}

TestPrivateServerLink() {
    global PrivateServerLinkEdit

    link := PrivateServerLinkEdit.Text
    if (link = "") {
        UpdateText("Please enter a server link first. No Link Provided")
        return
    }

    if (InStr(link, "roblox.com") || InStr(link, "rbxl.co")) {
        Reconnect()
    } else {
        MsgBox("Invalid server link format. Please enter a valid Roblox private server link.", "Invalid Link",
            "OK IconX")
    }
}
; PrivateServerBtn := MainUI.Add("Button", "x370 y700 w120 h30 Background" buttonBgColor " c" textcolor,
; ;     "Private Server")
; ; PrivateServerBtn.OnEvent("Click", (*) => PrivateServerGUI())

SavePrivateServerLink(*) {
    global PrivateServerLinkEdit
    privateServerLink := PrivateServerLinkEdit.Text
    privateServerFile := A_ScriptDir "\Settings\PrivateServer.txt"

    if (!RegExMatch(privateServerLink,
        "i)^https:\/\/www\.roblox\.com\/games\/\d+\/[\w\-]+\/?\?privateServerLinkCode=[a-zA-Z0-9]{32}$|^roblox:\/\/placeID=\d+\&privateServerLinkCode=[a-zA-Z0-9]{32}$|^privateServerLinkCode=[a-zA-Z0-9]{32}$"
    )) {
        UpdateText("Invalid Roblox private server link format. Proceeding with saving anyway.")
    }
    try {
        FileDelete(privateServerFile)
        FileAppend(privateServerLink, privateServerFile)
        UpdateText("Private server link saved.")
    }
    catch Error as err {
        UpdateText("Error saving private server link: " err.Message)
    }
}

LoadPrivateServerLink() {
    global PrivateServerLinkEdit
    local privateServerFile := A_ScriptDir "\Settings\PrivateServer.txt"
    if FileExist(privateServerFile) {
        try {
            local link := FileRead(privateServerFile)
            if IsObject(PrivateServerLinkEdit) {
                PrivateServerLinkEdit.Value := Trim(link)
                UpdateText("Private server link loaded.")
            }
        } catch Error as e {
            UpdateText("Error loading private server link: " e.Message)
        }
    }
}

/**
 * 
 */

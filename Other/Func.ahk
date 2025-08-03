#Requires AutoHotkey v2.0
global returntolobby := false
OnError(ErrorHandler)

ErrorHandler(exception, mode) {
    try {
        errorMessage := "Error: " exception.Message "`nFile: " exception.File "`nLine: " exception.Line "`nCode: " exception
            .CallStack
        if (exception.What)
            errorMessage .= "`nWhat: " exception.What
        if (exception.Extra)
            errorMessage .= "`nExtra: " exception.Extra

        logFile := A_ScriptDir "\Logs\error.log"
        FileAppend(FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss") " - " errorMessage "`n", logFile)

        MsgBox(errorMessage, "Error", "Icon!")

        if IsObject(MainUI) && IsObject(Process)
            UpdateText("Error occurred. Check Logs\error.log for details")

        return true
    } catch {
        return false
    }
}
global roblox := "ahk_exe RobloxPlayerBeta.exe"
global statusHistory := []
global stageStartTime := A_TickCount
global runCount := 0
global MainUI
global Process
global mode
; Winrate
global totalWins := 0
global totalLosses := 0
global runStartTime := A_TickCount
ActivateRoblox() {
    if !WinExist(roblox) {
        Sleep(500)
        UpdateText("Roblox is not open or you have Microsoft Store Roblox")
    } else {
        WinGetPos(&X, &Y, &W, &H, MainUI)
        WinActivate(roblox)
        WinMove(X, Y, 800, 600, roblox)
        return true
    }
}
OcrBetter(x1, y1, x2, y2, scale, debug := false) {
    try {
        WinGetPos(&winX, &winY, , , "ahk_exe RobloxPlayerBeta.exe")
        x1 += winX
        y1 += winY
        x2 += winX
        y2 += winY

        pToken := Gdip_Startup()

        width := x2 - x1
        height := y2 - y1
        pBitmap := Gdip_BitmapFromScreen(x1 "|" y1 "|" width "|" height)

        newWidth := width * scale
        newHeight := height * scale

        pScaled := Gdip_CreateBitmap(newWidth, newHeight)
        g := Gdip_GraphicsFromImage(pScaled)

        Gdip_SetSmoothingMode(g, 4)
        Gdip_SetInterpolationMode(g, 7)
        Gdip_SetPixelOffsetMode(g, 5)

        Gdip_DrawImage(g, pBitmap, 0, 0, newWidth, newHeight, 0, 0, width, height)

        filename := "OCR"
        fullPath := A_ScriptDir "\Images\" filename ".png"

        if FileExist(fullPath)
            FileDelete(fullPath)

        Gdip_SaveBitmapToFile(pScaled, fullPath, 100)

        Sleep 100

        if !FileExist(fullPath) {
            UpdateText("Failed to save OCR image")
            return ""
        }

        result := s.ocr_from_file(fullPath, , true)
        Sleep 100

        Gdip_DeleteGraphics(g)
        Gdip_DisposeImage(pBitmap)
        Gdip_DisposeImage(pScaled)
        Gdip_Shutdown(pToken)

        if FileExist(fullPath)
            FileDelete(fullPath)

        if debug {
            if IsObject(result) && result.Length > 0 {
                text := ""
                for block in result {
                    cleanedText := RegExReplace(block.text, "\s+", "")
                    text .= cleanedText
                }
                if text != ""
                    UpdateText("Found text: " text)
                else
                    UpdateText("No text found in result")
            } else {
                UpdateText("No result returned or result is empty")
            }
        }

        if IsObject(result) && result.Length > 0 {
            finalText := ""
            for block in result {
                cleaned := RegExReplace(block.text, "\s+", "")
                finalText .= cleaned
            }
            return finalText
        }
        return ""
    } catch as err {
        UpdateText("OCR Error: " err.Message)
        return ""
    }
}
ImagesSearch(X1, Y1, X2, Y2, image, tol := 0, &FoundX?, &FoundY?) {
    CoordMode("Pixel", "Window")

    try {
        if ImageSearch(&FoundX, &FoundY, X1, Y1, X2, Y2, "*" tol " " image)
            return true
    } catch {
        return false
    }
    return false
}

ImageSearchLoop(image, X1, Y1, X2, Y2) {
    CoordMode("Pixel", "Window")
    global FoundX, FoundY

    WinActivate(roblox)
    WinGetPos(&X, &Y, &W, &H, roblox)
    while true {
        if (ok := FindText(&x, &y, X1, Y1, X2, Y2, 0, 0, image)) {
            return [x, y]
        } else {
            Sleep 100
        }
    }
}

PixelSearchS(color, x1, y1, x2, y2, variation, v := true) {
    global foundX, foundY
    ActivateRoblox()
    if PixelSearch(&foundX, &foundY, x1, y1, x2, y2, color, variation) {
        if v {
            return [foundX, foundY]
        } else {
            return true
        }
    }
    return false
}
PixelSearchLoop(color, x1, y1, x2, y2, variation, click := true) {
    global foundX, foundY
    try {
        loop {
            if PixelSearch(&foundX, &foundY, x1, y1, x2, y2, color, variation) {
                if click {
                    MoveXY()
                }
                return [foundX, foundY]
            } else {
                Sleep 100
            }
        }
    } catch Error as e {
        return false
    }
}
; Pixel(color, x1, y1, addx1, addy1, variation) {
;     global foundX, foundY
;     try {
;         if PixelSearch(&foundX, &foundY, x1, y1, x1 + addx1, y1 + addy1, color, variation) {
;             return [foundX, foundY] AND true
;         }
;         return false
;     } catch Error as e {
;         MsgBox("Error in Pixel: " e.Message)
;         return false
;     }
; }
Pixel(color, x, y, w, h, variation := 3) {
    global foundX, foundY
    try {
        if PixelSearch(&foundX, &foundY, x, y, x + w, y + h, color, variation) {
            return [foundX, foundY]  ; Found
        }
        return false  ; Not found
    } catch {
        return false  ; Safe fallback
    }
}
PixelSearchLoop2(color, x1, y1, x2, y2, variation, attempts, move := true) {
    global foundX, foundY
    attempts2 := 0
    try {
        loop {
            if attempts2 >= attempts {
                return false
            }
            if PixelSearch(&foundX, &foundY, x1, y1, x2, y2, color, variation) {
                if move {
                    MoveXY()
                }
                return [foundX, foundY]
            } else {
                attempts2++
                Sleep 100
                continue
            }
        }
    } catch Error as e {
        return false
    }
}

Scroll(times, direction, delay) {
    if (times < 1) {
        MsgBox("Invalid number of times")
        return
    }
    if (direction != "WheelUp" and direction != "WheelDown") {
        MsgBox("Invalid direction")
        return
    }
    if (delay < 0) {
        MsgBox("Invalid delay")
        return
    }
    loop times {
        Send("{" direction "}")
        Sleep(delay)
    }
}

wiggle() {
    MouseMove(1, 1, 5, "R")
    Sleep(30)
    MouseMove(-1, -1, 5, "R")
}
Wigglehuge() {
    MouseMove(5, 5, 5, "R")
    Sleep(30)
    MouseMove(-5, -5, 5, "R")
}
MoveXY() {
    MouseMove(FoundX, FoundY)
    MouseMove(1, 0, , "R")
    Sleep(50)
    wiggle()
    Click()
}

ClickV3(x, y) {
    MouseMove(x, y)
    MouseMove(1, 0, , "R")
    Sleep(50)
    Wigglehuge()
    Click("Right")
}
ClickV2(x, y, clicks := 1) {
    ActivateRoblox()
    MouseMove(x, y)
    MouseMove(1, 0, , "R")
    loop clicks {
        Sleep(50)
        wiggle()
        Click()
    }
}
Clickv5(x, y) {
    MouseMove(x, y)
    MouseMove(1, 0, , "R")
    Sleep(50)
    Wigglehuge()
    Click()
}
Click2(x, y) {

    MouseMove(x, y)
    MouseMove(1, 0, , "R")
    Sleep(50)
    MouseMove(1, 1, 5, "R")
    Sleep(30)
    MouseMove(-1, -1, 5, "R")
    Click()
}

ClickV4(x, y, delay) {
    MouseMove(x, y)
    MouseMove(1, 0, , "R")
    Sleep(delay)
    wiggle()
    Click()
}

Clicks() {
    MouseMove(1, 0, , "R")
    Sleep(50)
    wiggle()
    Click()
    Click()
    Click()
    Sleep(50)
    Click()
    MouseMove(-1, 0, , "R")
}
ZoomTech(start := true) {
    GetMode()
    Send "{Tab}"
    MouseMove(408, 247, 0)
    ;MouseClick("Right", , , 1, 0, "D")
    ;MouseMove(0, 1, 0, "R")
    Sleep(500)
    Scroll(20, "WheelUp", 25)
    MouseMove(0, 5, 0, "R")
    Scroll(20, "WheelDown", 25)
    Sleep(250)
    ;MouseClick("Right", , , 1, 0, "U")
    if start {
        ;ClickV2(361, 542)
    }
}

GetElapsedTime(startTime) {
    elapsedMs := A_TickCount - startTime
    hours := Floor(elapsedMs / (1000 * 60 * 60))
    minutes := Floor(Mod(elapsedMs / (1000 * 60), 60))
    seconds := Floor(Mod(elapsedMs / 1000, 60))

    if (hours > 0)
        return Format("{:02d}:{:02d}:{:02d}", hours, minutes, seconds)
    else
        return Format("{:02d}:{:02d}", minutes, seconds)
}
WebhookScreenshot(title, description) {
    ActivateRoblox()

    if !MainUI["EnableWebhook"].Value
        return
    mode := ModeSelect.Text
    UpdateText("Webhook Enabled")

    color := 0x00aeff
    if InStr(title, "Win")
        color := 0x4BB543
    else if InStr(title, "Loss")
        color := 0xFF3333

    submitted := MainUI.Submit(false)
    currentMode := submitted.SelectedMode
    discordId := MainUI["DiscordIdEdit"].Value
    WebhookURL := MainUI["MyEdit"].Value

    if !(WebhookURL ~=
        "i)^https:\/\/((?:ptb|canary)\.)?discord(?:app)?\.com\/api\/webhooks\/\d{17,23}\/[A-Za-z0-9_\-\.]{60,100}$") {
        MsgBox("Invalid Discord webhook URL", "Webhook Error", "Icon!")
        return
    }

    global totalWins, totalLosses, runCount
    if !IsSet(totalWins)
        totalWins := 0
    if !IsSet(totalLosses)
        totalLosses := 0
    if !IsSet(runCount)
        runCount := 0
    pToken := Gdip_Startup()
    if !pToken {
        UpdateText("Failed to initialize GDI+")
        return
    }

    MonitorGet(MonitorGetPrimary(), &Left, &Top, &Right, &Bottom)
    pBitmap := Gdip_BitmapFromScreen(Left "|" Top "|" (Right - Left) "|" (Bottom - Top))
    if !pBitmap {
        UpdateText("Failed to capture the screen")
        Gdip_Shutdown(pToken)
        return
    }

    WinGetClientPos(&x, &y, &w, &h, roblox)
    pCroppedBitmap := Gdip_CloneBitmapArea(pBitmap, x, y + 5, w - 12, h - 10)
    if !pCroppedBitmap {
        UpdateText("Failed to crop the bitmap")
        Gdip_DisposeImage(pBitmap)
        Gdip_Shutdown(pToken)
        return
    }

    webhook := WebhookBuilder(WebhookURL)
    attachment := AttachmentBuilder(pCroppedBitmap)
    myEmbed := EmbedBuilder()

    myEmbed.setTitle(title . " - " . currentMode . " #" . runCount)

    avgRunTime := "N/A"
    if (runCount > 0) {
        avgRunTimeMs := (A_TickCount - runStartTime) / runCount
        avgRunTimeMin := Floor(avgRunTimeMs / (1000 * 60))
        avgRunTimeSec := Floor(Mod(avgRunTimeMs / 1000, 60))
        avgRunTime := avgRunTimeMin "m " avgRunTimeSec "s"
    }
    winrate := GetWinrate()
    enhancedDesc := description
    enhancedDesc .= "`n• 🔢 | Run #: " . runCount
    enhancedDesc .= "`n• 🔢 | Avg Run: " . avgRunTime
    enhancedDesc .= "`n• 🏆 | Total Wins: " . totalWins
    enhancedDesc .= "`n• 😔 | Total Losses: " . totalLosses
    enhancedDesc .= "`n• 💯 | Winrate: " . winrate

    myEmbed.setDescription(enhancedDesc)
    myEmbed.setColor(color)
    myEmbed.setImage(attachment)

    elapsedTime := GetElapsedTime(stageStartTime)
    totalTime := GetElapsedTime(runStartTime)
    currentTime := FormatTime(A_Now, "h:mm tt")

    myEmbed.setFooter({
        text: "Cys AFS Macro " Version " | Run: " elapsedTime " | Total: " totalTime " | " currentTime
    })

    webhook.send({
        content: discordId ? "<@" discordId ">" : "",
        embeds: [myEmbed],
        files: [attachment]
    })

    Gdip_DisposeImage(pCroppedBitmap)
    Gdip_DisposeImage(pBitmap)
    Gdip_Shutdown(pToken)

    UpdateText("Webhook sent: " . title)
}

WebhookScreenshot2(color := 0x00aeff, status := "") {
    ActivateRoblox()
    if MainUI["EnableWebhook"].Value {
        UpdateText("Webhook Enabled")

        submitted := MainUI.Submit(false)
        currentMode := submitted.SelectedMode

        title := "Test Screenshot"
        description := "Test Screenshot"

        discordId := MainUI["DiscordIDEdit"].Value
        WebhookURL := MainUI["MyEdit"].Value
        webhook := WebhookBuilder(WebhookURL)

        if !(WebhookURL ~=
            "i)^https:\/\/((?:ptb|canary)\.)?discord(?:app)?\.com\/api\/webhooks\/\d{17,23}\/[A-Za-z0-9_\-\.]{60,100}$"
        ) {
            MsgBox(
                "Invalid Discord webhook URL. Please enter a valid URL in the format:`nhttps://discord.com/api/webhooks/ID/TOKEN",
                "Webhook Error", "Icon!")
            return
        }

        pToken := Gdip_Startup()
        if !pToken {
            MsgBox("Failed to initialize GDI+")
            return
        }

        MonitorGet(MonitorGetPrimary(), &Left, &Top, &Right, &Bottom)
        pBitmap := Gdip_BitmapFromScreen(Left "|" Top "|" (Right - Left) "|" (Bottom - Top))
        if !pBitmap {
            MsgBox("Failed to capture screen")
            Gdip_Shutdown(pToken)
            return
        }

        WinGetClientPos(&x, &y, &w, &h, roblox)
        pCroppedBitmap := Gdip_CloneBitmapArea(pBitmap, x, y + 5, w - 10, h - 10)
        if !pCroppedBitmap {
            MsgBox("Failed to crop bitmap")
            Gdip_DisposeImage(pBitmap)
            Gdip_Shutdown(pToken)
            return
        }

        global totalWins, totalLosses, runCount
        elapsedTime := GetElapsedTime(stageStartTime)
        totalTime := GetElapsedTime(runStartTime)
        winrateText := GetWinrate()

        avgRunTime := "N/A"
        if (runCount > 0) {
            avgRunTimeMs := (A_TickCount - runStartTime) / runCount
            avgRunTimeMin := Floor(avgRunTimeMs / (1000 * 60))
            avgRunTimeSec := Floor(Mod(avgRunTimeMs / 1000, 60))
            avgRunTime := avgRunTimeMin "m " avgRunTimeSec "s"
        }

        attachment := AttachmentBuilder(pCroppedBitmap)
        myEmbed := EmbedBuilder()

        if (currentMode != "")
            title .= " - " . currentMode

        myEmbed.setTitle(title)

        if (status != "")
            description := status
        else if (currentMode != "")
            description := "**Manual Screenshot**`n• Mode: " . currentMode
                . "`n• Run #: " . runCount
                . "`n• Winrate: " . winrateText

        myEmbed.setDescription(description)
        myEmbed.setColor(color)
        myEmbed.setImage(attachment)

        currentTime := FormatTime(A_Now, "yyyy-MM-dd HH:mm:ss")
        myEmbed.setFooter({ text: "Cys AFS X Macro " Version "  | Run: " elapsedTime " | Total: " totalTime " | " currentTime })

        webhook.send({
            content: discordId ? "<@" discordId ">" : "",
            embeds: [myEmbed],
            files: [attachment]
        })

        Gdip_DisposeImage(pCroppedBitmap)
        Gdip_DisposeImage(pBitmap)
        Gdip_Shutdown(pToken)
        UpdateText("Test webhook sent successfully")
    }
}

CheckIfUnitPlaced() {
   if PixelSearchLoop2(0x2C5CC2, 80, 390, 100, 415, 2, 3, false) {
   ;if Pixel(0x2C5CC2, 80, 390, 15, 20, 2) {
        return true
    } else {
        return false
    }
}

Retrycheckloop() {
    while true {
        ClickV2(700, 565)
        if RetryCheck() {
            return true
        }
        if !DisconnectCheck() {
            return true
        }
        Sleep 500
    }
}

PlaceInOrder() {
    CoordMode("Mouse", "Client")
    submitted := MainUI.Submit(false)
    mode := submitted.SelectedMode
    selectedCustom := submitted.SelectedCustomMode
    selectedWorld := submitted.WorldSelect
    selectedLegend := submitted.LegendSelect
    selectedRaid := submitted.RaidSelect
    settingsFile := ""

    modeMap := Map(
        "Custom", "\Settings\Customs\",
        "Story", "\Settings\Worlds\",
        "Infinite", "\Settings\Infinites\",
        "Legend", "\Settings\Legends\",
        "Raid", "\Settings\Raids\",
        "Inferno", "\Settings\",
    )

    selectedMap := Map(
        "Custom", selectedCustom,
        "Story", selectedWorld,
        "Infinite", selectedWorld,
        "Legend", selectedLegend,
        "Raid", selectedRaid,
        "Inferno", "Inferno"
    )

    basePath := modeMap.Has(mode) ? modeMap[mode] : "\Settings\"
    filename := selectedMap.Has(mode) ? selectedMap[mode] : mode
    settingsFile := A_ScriptDir . basePath . fileName . ".txt"

    UpdateText("Loading settings from: " settingsFile)

    if !FileExist(settingsFile) {
        UpdateText("No settings file found for mode: " mode)
        return false
    }

    try {
        fileContent := FileRead(settingsFile)
        lines := StrSplit(fileContent, "`n")
    } catch Error as e {
        MsgBox("Error reading settings file: " e.Message)
        return false
    }

    x := "", y := "", unit := "", upgrade := ""

    for _, line in lines {
        line := Trim(line)
        if (line = "")
            continue

        if InStr(line, "Index=") {
            ; Reset state for new block
            x := "", y := "", unit := "", upgrade := ""
            continue
        } else if InStr(line, "Unit=") {
            unit := SubStr(line, 6)
        } else if InStr(line, "Upgrade=") {
            upgrade := SubStr(line, 9)
        } else if InStr(line, "X=") {
            x := SubStr(line, 3)
        } else if InStr(line, "Y=") {
            y := SubStr(line, 3)

            ; When Y is parsed, assume we have all needed info
            if (x != "" && y != "" && unit != "") {
                try {
                    xi := Integer(x)
                    yi := Integer(y)
                } catch {
                    UpdateText("Invalid coordinates: X=" x ", Y=" y)
                    continue
                }

                UpdateText("Placing unit " unit " at (" xi ", " yi ") - Upgrade: " upgrade)
                if !PlaceAndUpgradeUnit(xi, yi, unit, upgrade, 200)
                    return false
            }
        }
    }
    return Retrycheckloop()
}

PlaceAndUpgradeUnit(x, y, unitslot, upgradeLevel := 0, upgradeDelay := 200) {

    if !PlaceUnit(x, y, unitslot) {
        UpdateText("Failed to place unit: " unitslot)
        return false
    }

    Sleep(100)  ; Give the UI a short moment to settle

    if (upgradeLevel != "" && upgradeLevel != "0" && upgradeLevel != 0) {
        if !UpgradeUnit(x, y, upgradeLevel, upgradeDelay, unitslot) {
            UpdateText("Upgrade failed or timed out")
            return false
        }
    }

    UpdateText("Unit " unitslot . " placed and upgraded to " upgradeLevel . " successfully.")
    return true
}

UpgradeUnit(x, y, upgradeLevel, upgradeDelay, unitslot := "") {
    hasClicked := false

    if (upgradeLevel = 0) {
        return true
    }

    UpdateText("Upgrading until " upgradeLevel)
    upgradeImages := [Upgrade1, Upgrade2, Upgrade3, Upgrade4, Upgrade5, Upgrade6, Upgrade7, Upgrade8, Upgrade9,
        Upgrade10, Upgrade11, Upgrade12, Upgrade13, Upgrade14]
    mode := GetMode()
    if (upgradeLevel = "MAX") {
        while true {
            if RetryCheck() || !DisconnectCheck() || InfiniteCheck()
                return false

            if (!CheckIfUnitPlaced() && !hasClicked) {
                CoordMode("Mouse", "Client")
                ClickV4(x, y, 1)
                Sleep(30)
                hasClicked := true
            }
            ActivateRoblox()
            Send "{e}"
            Sleep(upgradeDelay)

            AutoAbilityCheck()

            WinGetPos(&winX, &winY, &winW, &winH, roblox)
            if (FindText(&foundX, &foundY, winX, winY, winW, winH, 0, 0, MaxUnit)) {
                Sleep(100)
                hasClicked := false
                return true
            }
        }
    }

    upgradePattern := upgradeImages[Integer(upgradeLevel)]
    while true {
        if RetryCheck() || !DisconnectCheck() || InfiniteCheck()
                return false

        if (!CheckIfUnitPlaced() && !hasClicked) {
            CoordMode("Mouse", "Client")
            ClickV4(x, y, 1)
            Sleep(30)
            hasClicked := true
        }
        
        ActivateRoblox()
        Send "{e}"
        Sleep(upgradeDelay)

        AutoAbilityCheck()

        WinGetPos(&winX, &winY, &winW, &winH, roblox)
        selectedUpgrade := FindText(&foundX, &foundY, winX+135, winY+325, winW+45, winH-45, 0.1, 0.1, upgradePattern)
        maxUpgrade := FindText(&foundX, &foundY, winX, winY, winW, winH, 0, 0, MaxUnit)
        ; FindText() show search range function
        ;FindText().RangeTip(winX+115, winY+380, winW-700, winH-600, "Red", 2)

        if selectedUpgrade || maxUpgrade {
            UpdateText("Upgrade " upgradeLevel " Complete")
            Sleep(100)
            hasClicked := false
            return true
        }
    }
}

AutoAbilityCheck() {
    if AutoAbility.Value {
        WinGetPos(&winX, &winY, &winW, &winH, roblox)
        if (FindText(&X, &Y, winX, winY, winX+winW, winY+winH, 0.1, 0.1, AbilityButton)) {
            UpdateText("Clicking Auto Ability Button")
            CoordMode("Mouse", "Screen")
            ClickV2(X, Y)
            Sleep(100)
        }
    }
}

PlaceUnit(x, y, unitslot) {
    static placementdelay := ""
    if (placementdelay == "") {
        try {
            placementDelayFile := FileRead(A_ScriptDir "\Settings\PlacementDelay.txt")
            placementdelay := StrSplit(placementDelayFile, "=")[2]
        } catch {
            placementdelay := 100
        }
    }

    if RetryCheck() || !DisconnectCheck() || InfiniteCheck()
        return false

    if (unitslot == "0") {
        ClickV2(x, y)
        return true
    }

    if (InStr(unitslot, "w") || InStr(unitslot, "W")) {
        waittime1 := StrSplit(unitslot, 2)
        waittime := waittime1[2] * 1000
        UpdateText("Waiting " waittime "ms")
        Sleep(waittime)
        return true
    }

    if (InStr(unitslot, "u") || InStr(unitslot, "U")) {
        CoordMode("Mouse", "Client")
        slotMap := Map(
            "u1", [670, 200],
            "u2", [745, 200],
            "u3", [670, 315],
            "u4", [745, 315],
            "u5", [670, 430],
            "u6", [745, 430]
        )
        key := StrLower(unitslot)
        if slotMap.Has(key) {
            coords := slotMap[key]
            ClickV2(coords[1], coords[2])
            return true
        }
    }

    if (unitslot ~= "^[rR]$") {
        ActivateRoblox()
        ClickV3(x, y)
        Sleep(7500)
        return true
    }

    if (unitslot ~= "^[fF]$") {
        Send "{F}"
        Sleep(150)
        return true
    }

    loop {
        if RetryCheck() || !DisconnectCheck() || InfiniteCheck()
            return false

        Send(unitslot)
        Sleep(placementdelay)
        if (CheckVashMode()) {
            UpdateText("Vash Placement Detected, selecting Guns")
            CoordMode("Mouse", "Client")
            ClickV2(250, 280)
            Sleep(150)
        }
        CoordMode("Mouse", "Client")
        ClickV2(x, y)
        Sleep(150)

        if (CheckIfUnitPlaced() && unitslot != "0") {
            UpdateText("Unit Placed Successfully")
            Sleep(50)
            return true
        }
    }
}

CheckVashMode() {
    WinGetPos(&winX, &winY, &winW, &winH, roblox)
    if (FindText(&X, &Y, winX, winY, winX+winW, winY+winH, 0.1, 0.1, VashMode)) {
        return true
    } else {
        return false
    }
}

InfiniteCheck() {
global totalWins, nextmap
mode := GetMode()

if (mode == "Infinite" && Wave15Toggle.Value) {
    WinGetPos(&winX, &winY, &winW, &winH, roblox)
    if (FindText(&X, &Y, winX, winY, winX+winW, winY+winH, 0, 0, InfWave15)) {
        UpdateText("Wave 15 reached, restarting...")
        UpdateText(++totalWins " restarts")
        CoordMode("Mouse", "Client")
        Sleep(100)
        ClickV2(15, 570)  ; Click the cog wheel
        Sleep(500)
        MouseMove(490, 385) ; move to restart match/the settings box
        wiggle()
        Sleep(750)
        Scroll(10, "WheelDown", 50) ; scroll down to the restart match button
        Sleep(750)
        ClickV2(490, 385) ; click the restart match button
        Sleep(500)
        ClickV2(495, 150) ; exit out of settings menu
        while (FindText(&X, &Y, winX, winY, winX+winW, winY+winH, 0, 0, InfWave15)) {
            Sleep(250)
        }
        nextmap++
        return true
        }
    }
    return false
}

UnitChanged(index, *) {
    unit := MainUI["Unit" . index].Value
    switch unit {
        case "f", "F":
            MainUI["X" . index].Value := "705"
            MainUI["Y" . index].Value := "452"
        case "u1", "U1":
            MainUI["X" . index].Value := "670"
            MainUI["Y" . index].Value := "200"
        case "u2", "U2":
            MainUI["X" . index].Value := "745"
            MainUI["Y" . index].Value := "200"
        case "u3", "U3":
            MainUI["X" . index].Value := "670"
            MainUI["Y" . index].Value := "315"
        case "u4", "U4":
            MainUI["X" . index].Value := "745"
            MainUI["Y" . index].Value := "315"
        case "u5", "U5":
            MainUI["X" . index].Value := "670"
            MainUI["Y" . index].Value := "430"
        case "u6", "U6":
            MainUI["X" . index].Value := "745"
            MainUI["Y" . index].Value := "430"
    }
}

RetryCheck() {
    global runCount
    CoordMode("Mouse", "Window")
    CoordMode("Pixel", "Window")

    ; Define detection
    if Pixel(0x9136F0, 305, 180, 30, 20, 3) {  ; Retry
        ClickV2(700, 565)
    }

    WinGetPos(&winX, &winY, &winW, &winH, roblox)
    if FindText(&X, &Y, winX, winY+150, winX+winW, winY+winH-150, 0.1, Rare)
     || FindText(&X, &Y, winX, winY+150, winX+winW, winY+winH-150, 0.1, 0.1, Mythic)
     || FindText(&X, &Y, winX, winY+150, winX+winW, winY+winH-150, 0.1, 0.1, Legendary)
    {
        loop 3 {
            ClickV2(700, 565)
            Sleep(45)
        }
    }

    ; Looking for red DEFEAT
    if Pixel(0xFF5959, 250, 310, 30, 20, 10) {  ; Loss
        runCount++
        return RetryFunctionLoss()
    }
    ; Looking for green VICTORY
    if Pixel(0x78D731, 250, 310, 30, 20, 10) {  ; Win
        runCount++
        return RetryFunctionWin()
    }
    return false
}

RetryFunctionWin() {
    global totalWins, FoundX, FoundY, nextmap
    mode := GetMode()
    submitted := MainUI.Submit(false)
    retryColor := 0xFFC950
    totalWins++
    winrate := GetWinrate()
    ClickV2(700, 565)
    WebhookScreenshot("Map Win", "")
    CoordMode("Mouse", "Window")
    UpdateText("Retry Detected [Win] - Winrate: " winrate)
    while Pixel(retryColor, 320, 400, 50, 35, 15) {
        ClickV2(370, 415)
    }
    Sleep 1000
    nextmap++
    return true
}

RetryFunctionLoss() {
    global totalLosses, FoundX, FoundY, nextmap
    mode := GetMode()
    submitted := MainUI.Submit(false)
    retryColor := 0xFFC950
    totalLosses++
    winrate := GetWinrate()
    ClickV2(700, 565)
    WebhookScreenshot("Map Loss", "Current Winrate: " winrate)
    CoordMode("Mouse", "Window")
    UpdateText("Retry Detected [Loss] - Winrate: " winrate)
    while Pixel(retryColor, 320, 400, 50, 35, 15) {
        ClickV2(370, 415)
    }
    Sleep 1000
    nextmap++
    return true
}

GetWinrate() {
    global totalWins, totalLosses

    totalRuns := totalWins + totalLosses
    if (totalRuns > 0) {
        winratePercent := Round((totalWins / totalRuns) * 100, 2)
        return winratePercent "% (" totalWins "W/" totalLosses "L)"
    }

    return "0% (0W/0L)"
}

FindRaid() {
    if (!WinExist(roblox)) {
        return
    }

    switch modetext {
        case "Custom":
            Custom()
        case "Story":
            if (!worldtext || worldtext = "") {
                MsgBox("Select a valid mode")
                return
            } else if (actindex < 0 || actindex > 7) {
                MsgBox("Select a valid act")
                return
            }
            PlayAreaMovement()
            Story(worldtext, actindex, nightmare)
        case "Infinite":
            PlayAreaMovement()
            Infinite(worldtext)
        case "Legend":
            PlayAreaMovement()
            Legend(legendtext, legendactindex)
        case "Raid":
            RaidAreaMovement()
            Raid(raidtext, raidactindex)
        case "Inferno":
            InfernoAreaMovement()
            Inferno()
    }
}

Clicktomove(x1, y1, delay, x2 := "", y2 := "") {
    UISettings := A_ScriptDir "\Settings\UISettings.txt"
    UISettings := FileRead(UISettings) = 1 ? 1 : 0
    ActivateRoblox()
    send "{Escape}"
    Sleep 750
    ClickV2(253, 124)
    Sleep 750
    if (UISettings = 1) {
        UpdateText("Click to Move: New UI")
        ClickV2(341, 395)
    } else {
        UpdateText("Click to Move: Normal UI")
        ClickV2(341, 290)
    }
    send "{Escape}"
    sleep 2000
    ClickV3(x1, y1)
    Sleep delay
    if (x2 != "" && y2 != "") {
        ClickV3(x2, y2)
        Sleep delay
    }

    Send "{Escape}"
    Sleep 750
    ClickV2(253, 124)
    Sleep 750
    if (UISettings = 1) {
        ClickV2(778, 395)
        send "{Escape}"
    } else {
        ClickV2(783, 288)
        send "{Escape}"
        Sleep 2000
        ClickV2(381, 160)
    }
}

HasInternet() {
    return DllCall("Wininet.dll\InternetGetConnectedState", "int*", 0, "int", 0)
}

Reconnect() {
    static placeId := 16946008847
    privateServerLink := ""
    privateServerFile := A_ScriptDir "\Settings\PrivateServer.txt"

    if FileExist(privateServerFile) {
        try privateServerLink := Trim(FileRead(privateServerFile))
        catch Error as e
            return UpdateText("Error reading private server link: " e.Message)
    }

    for _ in [1, 2] {
        if WinExist("ahk_exe RobloxPlayerBeta.exe") {
            WinClose("ahk_exe RobloxPlayerBeta.exe")
            Sleep(750)
        }
    }

    loop {
        if HasInternet() {
            UpdateText("Internet connection detected, attempting to reconnect...")

            if (privateServerLink != "") {
                serverCode := GetPrivateServerCode(privateServerLink)
                if (serverCode != "") {
                    deepLink := "roblox://experiences/start?placeId=" placeId "&linkCode=" serverCode
                    Run(deepLink)
                    UpdateText("Attempting to join private server...")
                } else {
                    UpdateText("Invalid private server link format.")
                    return false
                }
            } else {
                Run("roblox://placeID=" placeId)
                UpdateText("Attempting to join public server...")
            }

            if WinWait("ahk_exe RobloxPlayerBeta.exe", , 5) {
                UpdateText("Roblox launched successfully.")
                ActivateRoblox()
                Sleep(3000)
                UpdateText("Roblox looking for lobby.")

                if LookForLobby() {
                    UpdateText("Successfully reconnected.")
                    return true
                } else {
                    UpdateText("Failed to find lobby after reconnecting.")
                    ReconnectA := true
                    return false
                }
                return false
                ;break
            } else {
                UpdateText("Roblox not detected, retrying...")
                Sleep(1000)
            }
        } else {
            UpdateText("No internet connection detected, retrying in 3 seconds...")
            Sleep(3000)
        }
    }
}

GetPrivateServerCode(link) {
    if RegExMatch(link, "[?&]privateServerLinkCode=([\w-]+)", &m)
        return m[1]
    return ""
}

LookForLobby() {
    checks := 0
    while !Pixel(0xFFD152, 45, 600, 10, 10, 5) {
        checks++
        Sleep(500)
        if checks >= 60 {
            return false
        }
    }
    UpdateText("Lobby Found")
    return true
}

DisconnectCheck() {
    if Pixel(0x393B3D, 498, 357, 3, 3, 0) {
        global ReconnectA := true
        UpdateText("Disconnected... [Trying to reconnect]")
        return false
    }
    CoordMode("Mouse", "Window")
    return true
}

LookForIngame(Zoom := true, start := true) {
    while (true) {
        if !DisconnectCheck() {
            return false
        }
        Sleep(500)

        unitManager := Pixel(0x30ADFF, 745, 340, 20, 20, 0x0F)
        stockBar := Pixel(0x6AFF45, 290, 45, 100, 45, 0x0F)

        if found := unitManager || stockBar {
            switch found {
                case unitManager:
                    UpdateText("lookforingame(): Unit Manager Found")
                case stockBar:
                    UpdateText("lookforingame(): Stock Bar Found")
            }
            
            if (Zoom) {
                UpdateText("Zooming out")
                Sleep 1000
                if start {
                    ZoomTech()
                } else {
                    ZoomTech(false)
                }
            }
            return true
        } 
    }
    return false
}

; ChangeGameSpeed() {
;     CoordMode("Mouse", "Client")
;     static coords := Map(
;         "1x", [540, 15],
;         "2x", [560, 15],
;         "3x", [585, 15]
;     )
;     if coords.Has(gamespeed) {
;         UpdateText("Changing game speed to " . gamespeed)
;         pos := coords[gamespeed]
;         ClickV2(pos[1], pos[2])
;         Sleep(250)
;     }
; }




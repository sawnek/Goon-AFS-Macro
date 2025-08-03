#Requires AutoHotkey v2.0

TeleportTo(mode) {
    switch mode {
        case "Story", "Infinite", "Legend":
            ClickV2(785, 390)   ; Click on Areas
            Sleep(200)
            ClickV2(318, 285)   ; Click on Story teleport
            Sleep(500)
        case "Raid":
            ClickV2(785, 390)   ; Click on Areas
            Sleep(200)
            ClickV2(318, 325)   ; Click on Raid teleport
            Sleep(500)
        case "Summon":
            ClickV2(785, 390)   ; Click on Areas
            Sleep(200)
            ClickV2(500, 285)   ; Click on Summon teleport
            Sleep(500)
    }
}

; Window:	219, 153
; Client:	211, 122 (default)
; Color:	CF80FF (Red=CF Green=80 Blue=FF)

PlayAreaMovement() {
    UpdateText("Moving to Play area")
    while true {
        TeleportTo(ModeSelect.text)
        Sleep(750)
        Send "{shift down}"
        Send "{a down}"
        Sleep(525)
        Send "{a up}"
        Sleep(150)
        Send "{w down}"
        Sleep(1500)
        Send "{w up}"
        Send "{shift up}"
        Sleep(1000)

        ; Look for header color (purple)
        if PixelSearchLoop2(0xC14DFF, 200, 150, 20, 20, 0x0F, 5, false) {
            UpdateText("UI Found")
            return true
        } else {
            UpdateText("UI not found, retrying...")
            Sleep(500)
        }
    }
}

RaidAreaMovement() {
    UpdateText("Moving to Raid area")
    while true {
        TeleportTo(ModeSelect.text)
        Sleep(750)
        Send "{shift down}"
        Send "{w down}"
        Sleep(2000)
        Send "{w up}"
        Send "{shift up}"
        Sleep(1000)

        ; Look for header color (purple)
        if PixelSearchLoop2(0xC14DFF, 200, 150, 20, 20, 0x0F, 5, false) {
            UpdateText("UI Found")
            return true
        } else {
            UpdateText("UI not found, retrying...")
            Sleep(500)
        }
    }
}

; Window:	213, 144
; Client:	205, 113 (default)
; Color:	FFD052 (Red=FF Green=D0 Blue=52)
InfernoAreaMovement() {
    start := A_TickCount
    UpdateText("Moving to Inferno area")
    while true {
        Send "{shift down}"
        Sleep(50)
        Send "{s down}" 
        WinGetPos(&winX, &winY, &winW, &winH, roblox)
        while !FindText(&X, &Y, winX, winY, winX+winW, winY+winH, 0.1, 0.1, InfernoEvent) {
            Sleep(50)
            if (A_TickCount - start > 10000) {
                break
            }
        }
        Send "{s up}"
        Sleep(50)
        Send "{shift up}"
        Sleep(1000)

        ; Look for header color (orange)
        if PixelSearchLoop2(0xFF50000, 200, 150, 35, 35, 3, 5, false) || FindText(&X, &Y, winX, winY, winX+winW, winY+winH, 0.1, 0.1, InfernoEvent) {
            UpdateText("UI Found")
            return true
        } else {
            UpdateText("UI not found, retrying...")
            TeleportTo("Summon")
            start := A_TickCount
            Sleep(500)
        }
    }
}

Story(world, act, nightmare) {
    UpdateText("Starting Story for " world " - Act " act)
    ClickV2(210, 235)
    ; Select World
    switch world {
        case "Clown Town":
        case "Alien Island":
            ClickV2(210, 290)
        case "Sand Village":
            ClickV2(210, 345)
        case "Demon Winter":
            ClickV2(210, 400)
        case "Huco Mondo":
            Scroll(5, "WheelDown", 5)
            ClickV2(210, 330)
        case "Asakusa Flame":
            Scroll(5, "WheelDown", 5)
            ClickV2(210, 400)
    }
    Sleep(250)
    
    ; Select Act
    ClickV2(265 + act * 45, 400)
    Sleep(250)

    ; Nightmare toggle
    if (nightmare) {
        ClickV2(630, 360)
        Sleep(250)
    }

    ; Start
    ClickV2(480, 440)
    Sleep(500)
    ; Right side start
    ClickV2(603, 421)
    Sleep(500)
    ClickV2(603, 421)
    Sleep(500)

    LookForIngame(true)
    ; ChangeGameSpeed()
    PlaceInOrder()
}


Infinite(world) {
    UpdateText("Starting Infinite for " world)
    ClickV2(210, 235)
    ; Select World
    switch world {
        case "Clown Town":
        case "Alien Island":
            ClickV2(210, 290)
        case "Sand Village":
            ClickV2(210, 345)
        case "Demon Winter":
            ClickV2(210, 400)
        case "Huco Mondo":
            Scroll(5, "WheelDown", 5)
            ClickV2(210, 330)
        case "Asakusa Flame":
            Scroll(5, "WheelDown", 5)
            ClickV2(210, 400)
    }
    ; Select Act
    ClickV2(265 + 7 * 45, 400)
    Sleep(250)

    ; Start
    ClickV2(480, 440)
    Sleep(500)
    ; Right side start
    ClickV2(603, 421)
    Sleep(500)
    ClickV2(603, 421)
    Sleep(500)
    

    LookForIngame(true)
    ; ChangeGameSpeed()
    PlaceInOrder()
}

Legend(legendworld, legendact) {
    UpdateText("Starting Legend stage for " legendworld " - Act " legendact)
    ClickV2(596, 172)
    Sleep(250)
    ClickV2(210, 235)
    ; Select World
    switch legendworld {
        case "Alien Island":
        case "Demon Winter":
            ClickV2(210, 290)
        case "Huco Mondo":
            ClickV2(210, 345) 
        case "Asakusa Flame":
            ClickV2(210, 400)

    }
    ; Select Act
    ClickV2(265 + legendact * 45, 400)
    Sleep(250)

    ; Start
    ClickV2(480, 440)
    Sleep(500)
    ; Right side start
    ClickV2(603, 421)
    Sleep(500)
    ClickV2(603, 421)
    Sleep(500)

    LookForIngame(true)
    ; ChangeGameSpeed()
    PlaceInOrder()
}

Raid(raidworld, raidact) {
    UpdateText("Starting Raid for " raidworld " - Act " raidact)
    ClickV2(210, 235)
    switch raidworld {
        case "Emies Lobby":
        case "Nature Village":
            ClickV2(210, 290)
    }
    ; Select Act
    ClickV2(265 + raidact * 45, 400)
    Sleep(250)

    ; Start
    ClickV2(480, 440)
    Sleep(500)
    ; Right side start 
    ClickV2(603, 421)
    Sleep(500)
    ClickV2(603, 421)
    Sleep(500)

    LookForIngame(true)
    ; ChangeGameSpeed()
    PlaceInOrder()
}

Inferno() {
    UpdateText("Starting Inferno")

    ; Start Amaterasa
    ClickV2(300, 275)
    Sleep(500)
    ; Right side start
    ClickV2(603, 421)
    Sleep(500)
    ClickV2(603, 421)
    Sleep(500)

    LookForIngame(true)
    ; ChangeGameSpeed()
    PlaceInOrder()
}

Custom() {
    if MsgBox("Zoom Out?", "Custom Mode", "YesNo") = "Yes" {
        LookForIngame(true)
        ; ChangeGameSpeed()
    }
    PlaceInOrder()
}
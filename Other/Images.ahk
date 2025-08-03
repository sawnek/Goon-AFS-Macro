#Requires AutoHotkey v2.0
Path := A_ScriptDir

Upgrade1 := "|<>*65$7.ztcqL/Vzk"
Upgrade2 := "|<>*90$8.zwuqtQq3zs"
Upgrade3 := "|<>*70$8.zwPatPL3zs"
Upgrade4 := "|<>*50$7.f5UULX"
Upgrade5 := "|<>*75$6.bD6q5U"
Upgrade6 := "|<>*50$7.X7VUKH"
Upgrade7 := "|<>*60$8.zsPanBrNzs"
Upgrade8 := "|<>*90$7.ztwyOpZzk"
Upgrade9 :="|<>*58$9.zwQVi9vQHzw"
Upgrade10 := "|<>*65$11.zzYO2qBA2t9zz"
Upgrade11 := "|<>*70$9.Yk6YgZYQ"
Upgrade12 := "|<>*59$11.zzYu2qNAas1zz"
Upgrade13 := "|<>*60$11.zzYO8qNQ+t1zz"
Upgrade14 := "|<>*60$11.zzZO2q1AWtlzz"
MaxUnit := "|<>*119$33.000001kwsssTDzzjbTbjjilssssq677WCkEkS3a06Hssl4UC3aBY1WClw70srDVwDizjzzzntzjxwU"

global InfWave15 := "|<>*90$24.Dyy0Tzq0l3byUDbzU7AXs3//tmP/M2QXN4zzTzryDzU0U"

global AbilityButton:= "|<>F64C4F-0.60$28.y000zzz00zzy01zzw03zzs0DzzU0zzy03zzs0DzzU0zzy0300s0A03U0s0Q03zzU0Dzs03y000y"

global VashMode := "|<>**70$41.0000s00sQ018w29Y02F82GDlwvTYokMMCV4n0kEB09YFbUSQ88n1AY0EU629C8EE8000EYEE0UV0kTDQkyU"
global InfernoEvent:="|<>*127$62.zzzXzzzzzzlzzkzzzzzzwTzsDzzzzzz7zyDzzzzzzlzzXyDwzzwQM1U60k40w160M10A10C0FU30kV0k1V0MsswMFwQMs6CCD0AT76C1XXXlz7llXUMsswAlwQM06CCDUAT770HbnXw3DntsS"

; UI
Image1 := Path "\Images\CysMacros.ico"
XBUTTON := path "\Images\exitButton.png"
DiscordLogo := Path "\Images\discordlogo.png"
Minimize := Path "\Images\minimizeButton.png"
CysLogo := Path "\Images\CysLogo.ico"
TraySetIcon(CysLogo)

Disconnected := path "\Images\Disconnected.png"
global Rare :="|<>*88$42.00000007s0000E8600000830000081004609kjzztU9ck61UE9sU610M81W6D6881b6P0M81b6P0k9tU6N7k9dk6NUE9BtiEkk77DvkTUU"
global Legendary :="|<>E98011-0.79$81.k000000070000600000000s0000k000000070000600000000s0000k3wTnwzVz7wzsS0zbyzbwTtzbvbk7CvrCtnjCwsQy0zqCzqCMtXa1yk7slrsln7AQkDr0s7ys6CTtza0wzrwTrwllz7wk3byDUCDa66EN60M0001U000000070007w00000000k000T0000000064"
global Mythic :="|<>CE97FF-0.70$54.byTzzVy7zPxDzVhyrzRvjzhhyrzSrdzggy7zS7UkCA661TDaazjmlwTzbCzjsnyNtbCCCQnZNtXxggQnHMldxghQn1P9hviBQnwPxgvjBAlw3wA7k10413wQ7sFX73zzw7zzzzzzzsDzzzzzzzwDzzzzzzzyTzzzzzU"

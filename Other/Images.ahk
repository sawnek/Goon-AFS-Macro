#Requires AutoHotkey v2.0
Path := A_ScriptDir

Upgrade1 := "|<>*65$7.ztcqL/Vzk"
Upgrade2 := "|<>*85$7.ztvT/B1zk"
Upgrade3 := "|<>*85$8.zwvqtTL/zs"
Upgrade4 := "|<>*85$8.zxPKVSLnzs"
Upgrade5 := "|<>*75$6.bD6q5U"
Upgrade6 := "|<>*90$8.zzTjlhfZzs"
Upgrade7 := "|<>*60$8.zsPanBrNzs"
Upgrade8 := "|<>*90$7.ztwyOpZzk"
Upgrade9 :="|<>*58$9.zwQVi9vQHzw"
Upgrade10 := "|<>*84$11.zzguKqhR+z/zz"
Upgrade11 := "|<>*55$10.zz9c4mH9QVzy"
Upgrade12 := "|<>*59$11.zzYu2qNAas1zz"
Upgrade13 := "|<>*60$11.zzYO8qNQ+t1zz"
Upgrade14 := "|<>*60$11.zzZO2q1AWtlzz"
; MaxUnit := "|<>*119$33.000001kwsssTDzzjbTbjjilssssq677WCkEkS3a06Hssl4UC3aBY1WClw70srDVwDizjzzzntzjxwU"
MaxUnit := "|<>**50$34.000000QDCCC3tzxxwTzzyytntNtnb777WQQMQD1lo9YqC7NaFkwRyE79lrtTNnbThxjiDbyzrkQDlyC000000U"

global InfWave15 := "|<>*90$24.Dyy0Tzq0l3byUDbzU7AXs3//tmP/M2QXN4zzTzryDzU0U"
global AbilityButton:= "|<>F64C4F-0.60$28.y000zzz00zzy01zzw03zzs0DzzU0zzy03zzs0DzzU0zzy0300s0A03U0s0Q03zzU0Dzs03y000y"
; global VashMode := "|<>**70$41.0000s00sQ018w29Y02F82GDlwvTYokMMCV4n0kEB09YFbUSQ88n1AY0EU629C8EE8000EYEE0UV0kTDQkyU"
;global VashMode := "|<>*95$37.s7zzzzk3zzzzsNxtwS8zUEA60Tk8230Dssl3VbyQMUkEXD4STA1bUE871nsQ62"
global VashMode :="|<>**90$42.00000003z00000C300000A17D7nsMvzzzzwNzUkMA4N1UUNwwN1ba8QANzZb8A68FZWDDaA1YUE8663YksA43ywTjzw0000000U"
global InfernoEvent:="|<>*127$62.zzzXzzzzzzlzzkzzzzzzwTzsDzzzzzz7zyDzzzzzzlzzXyDwzzwQM1U60k40w160M10A10C0FU30kV0k1V0MsswMFwQMs6CCD0AT76C1XXXlz7llXUMsswAlwQM06CCDUAT770HbnXw3DntsS"

; UI
Image1 := Path "\Images\CysMacros.ico"
XBUTTON := path "\Images\exitButton.png"
DiscordLogo := Path "\Images\discordlogo.png"
Minimize := Path "\Images\minimizeButton.png"
GoonLogo := Path "\Images\GoonLogo.ico"
TraySetIcon(GoonLogo)

Disconnected := path "\Images\Disconnected.png"
global Rare :="|<>*88$42.00000007s0000E8600000830000081004609kjzztU9ck61UE9sU610M81W6D6881b6P0M81b6P0k9tU6N7k9dk6NUE9BtiEkk77DvkTUU"
global Legendary :="|<>F1A323-0.84$47.000000000070000000C0000000Q0000000s0000DkTlzDq6TlzbyTgQtnbCQsQlXaCMtURX3AQln0S66Ttza0wAATlzA0s8E904M1U00000070000000A000000008"
global Mythic :="|<>CE97FF-0.70$54.byTzzVy7zPxDzVhyrzRvjzhhyrzSrdzggy7zS7UkCA661TDaazjmlwTzbCzjsnyNtbCCCQnZNtXxggQnHMldxghQn1P9hviBQnwPxgvjBAlw3wA7k10413wQ7sFX73zzw7zzzzzzzsDzzzzzzzwDzzzzzzzyTzzzzzU"
global Secret:="|<>E00000-0.73$48.T0000000zU00000MzU00000Qt0k400kws3wTDnxzz7wzjrxzTbCvC7CQ3rykA7yMlrwkA7wMvr0zA70QzbwTg7wST1wCA1wCU"

TEST package layout for direct copy into ESO AddOns.

Edit these paths going forward:
- TEST\TamrielKR\TamrielKR.lua
- TEST\TamrielKR\TamrielKR.txt
- TEST\TamrielKR\TamrielKR.xml
- TEST\TamrielKR\fontstrings.xml
- TEST\TamrielKR\backupfont_kr.xml
- TEST\EsoUI\lang\kr_client.str
- TEST\EsoUI\lang\kr_pregame.str
- TEST\gamedata\lang\kr.lang

Copy target:
- C:\Users\user\Documents\Elder Scrolls Online\live\AddOns

Quick deploy:
- Run TEST\sync-to-live-addons.ps1

Manual deploy:
- Copy the contents of TEST\TamrielKR into AddOns\TamrielKR
- Copy the contents of TEST\EsoUI into AddOns\EsoUI
- Copy the contents of TEST\gamedata into AddOns\gamedata

# Important notice
This repo is migrated to a much free place where there wont be this sentient aggressive false-flag banning robot that we all know as MicroShit ArkosGay: https://codeberg.org/ABJ4403/LuaTar

extra rant: this is the last repo that i have to close down cuz i fully migrated to Codeberg. i know everyone, i fricking know, but the sad reality is you can never be private, secure, and anonymous at the same time, and so does ArkoseLabs with their shitty robot ranking system that thinks my browser/ip is abusive, just because i used firefox on linux with privacy tools doesnt mean i cant use github, but what do you know my friend? its microsoft, ofc they can do anything they ever wanted :(

# LuaTar
![Version 3](https://img.shields.io/badge/Version-3-brightgreen?style=for-the-badge)
[![Report issues here](https://img.shields.io/badge/Report%20issues%20here-brightgreen?style=for-the-badge)](https://github.com/ABJ4403/LuaTar/issues/new)
[![Telegram support group](https://img.shields.io/badge/Telegram%20support%20group-brightgreen?style=for-the-badge)](https://t.me/+jCgcRExlrzExZDc1)

This script allows you to modify Tape Archive (Tar)
with just pure Lua, no external command, no LuaRocks bloat required,
lightweight & small, and even has gameguardian wrapper script
for gameguardian users that also wants to use this

# Add the luaTar code to your script
Just append the luaTar codes to your script, put `load("luaTar.lua")` (or if you want you can also use `load(gg.makeRequest("https://github.com/ABJ4403/luaTar/raw/main/luaTar.lua?raw=true").content)` although this one isn't recommended)

# Usage:
```lua
-- Add
tar.add("archive.tar","a.txt","Alpha")
tar.add("archive.tar","b.txt","Bravo")

-- Add folder (partial TODO)
tar.add("archive.tar","folder/")

-- Remove
tar.remove("archive.tar","b.txt")

-- Query
local fileList = tar.query("archive.tar")
for i=1,#fileList do print(fileList[i]) end

-- Extract
tar.extract("archive.tar","a.txt")

-- Parse header
tar.parseHeader("archive.tar")
```

# Why did i make this?
Well... no one makes an easy to use lua code that modifies Tar file, mostly you will need libraries or external commands, the only native Lua implementation i saw so far either requires libraries, or barely works

# Disadvantages
Because i want this to be dead simple, there will be some features missing:
- Last modified date will always be 01/01/1970_00:00:00 (Unix epoch time set to 0).
- File owner:group will always be 0:0 (root:root).
- File permission will always be 777 (owner/group/everyone will get read/write/execute permission)
- Can't extract or add folder (because Lua limitation)
- Can't modify, remove folder (logic not implemented yet cuz its too complex).
- There will be no UnixStandardTAR header, which means that you might unable to use too long names (more than ~150ish characters)

# License
[![GNU GPL v3](https://www.gnu.org/graphics/gplv3-127x51.png)](https://www.gnu.org/licenses/gpl-3.0.en.html)

LuaTar is Free Software: You can use, study, share, and improve it at
will. Specifically you can redistribute and/or modify it under the terms of the
[GNU General Public License](https://www.gnu.org/licenses/gpl.html) as
published by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

# LuaTar
This allows you to modify Tape Archive (Tar)

# Add the luaTar code to your script
Just append the luaTar codes to your script, put `load("luaTar.lua")` (or if you want you can also use `load(gg.makeRequest("https://github.com/ABJ4403/luaTar/raw/main/luaTar.lua?raw=true").content)` although this one isn't recommended)

# Usage:
```lua
-- Add
tar.add("archive.tar","a.txt","Alpha")
tar.add("archive.tar","b.txt","Bravo")

-- Remove
tar.remove("archive.tar","b.txt")

-- Query
local fileList = tar.query("archive.tar")
for i=1,#fileList do print(fileList[i]) end

-- Extract
tar.extract("archive.tar","a.txt")

-- Header checksum integrity (Experimental, likely returns false even if its not corrupted)
tar.checkHeader("archive.tar")
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

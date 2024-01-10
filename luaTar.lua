--[[

	ABJ4403's LuaTar
	(C) 2022-2024 ABJ4403

	Licensed under GNU GPL v3 License

]]
local tar = {
  VERSION = 2
}
function tar.add(tarPath,fileName,content)
	local tarFile,err = io.open(tarPath,"ab")
	if not tarFile then return err or false end
	local header =
		fileName..("\0"):rep(100 - #fileName)..	 -- File name
		'0000666\0'..										 -- File mode (octal)
		("%07o"):format(0)..'\0'..			 -- Uid (octal)
		("%07o"):format(0)..'\0'..			 -- Gid (octal)
		("%011o"):format(#content)..'\0'..-- File size (octal)
		("%011o"):format(0)..'\0'..			 -- Last modification time (octal)
		("\0"):rep(7)..' '..						 -- Checksum (octal)
		"0"..									 					 -- Type flag (0: file,1: hardlink,2: symlink)
		("\0"):rep(100)..								 -- name of linked file (we dont want those symlinks and stuf so aint using one
		("\0"):rep(88)..								 -- UnixStandardTar header (6b) + version (2b), user + group (64b), device major + minor number (16b)
		("\0"):rep(167)					 				 -- UStar Filename prefix
	-- Checksum
	local sum = 224
	for i=1,512 do
		sum = sum + header:byte(i)
	end
	header =
		header:sub(1,148)..
		("%06o"):format(sum)..
		header:sub(155)
	tarFile:write(
		header..
		content..
		("\0"):rep((512 - #content) % 512) -- Tar file has 512 bytes block size
	)
	tarFile:close()
	return true
end
function tar.extract(tarPath,fileName)
	local file = io.open(tarPath,"rb")
  if not file then return end
	while true do
		local block = file:read(512) -- read every block
		if not block then break end
		local fileSize = tonumber(block:sub(125,135),8) -- get the file size
if not fileSize then print("FILE SIZE CONVERSION BUG DETECTED",block:sub(125,135),1)break end
		if block:sub(1,math.min(100,#fileName)) == fileName then -- if a block starts with filename
			local data = file:read(fileSize) -- read the whole thing
			file:close()
			return data
		end
    local blocksToSkip = math.ceil(fileSize / 512) + 1 -- GameGuardian io bug -- skip to next block where another file header is located
    file:seek("cur",blocksToSkip * 512)
	end
	file:close()
end
function tar.remove(tarPath,fileName)
  local file = io.open(tarPath,"rb")
  if not file then return end
  local output = io.open(tarPath..".tmp","wb")
  while true do
    local block = file:read(512)
    if not block then break end
    if block:sub(1,math.min(100,#fileName)) == fileName then -- ignores the block with the file that is going to be removed
      local fileSize = tonumber(block:sub(125,135),8)
if not fileSize then print("FILE SIZE CONVERSION BUG DETECTED",block:sub(125,135),1)break end
      local blocksToSkip = math.ceil(fileSize / 512) + 1 -- GameGuardian io bug + 1
      file:seek("cur",blocksToSkip * 512)
    else
      output:write(block) -- write the rest of the block to temporary file
    end
  end
  file:close()
  output:close()
  os.remove(tarPath)
  os.rename(tarPath..".tmp",tarPath)
end
function tar.parseHeader(tarPath)
	local ret = {}
	local file = io.open(tarPath,"rb")
	if not file then return end
	while true do
	--read
		local block = file:read(512)
		if not block then break end
		local fileName = block:sub(1,100):gsub("\0+$","")
	--checksum verify
		local sum = 224
		local checksum = tonumber(block:sub(149,154),8)
		block = block:sub(1,148).."\0\0\0\0\0\0"..block:sub(155) -- original was bunch of NULs
		for i=1,#block do
			sum = sum + block:byte(i)
		end
		local checksumValid =
			checksum and
			sum - checksum == 0
	--result
		local header = {
			isValid = checksumValid,
			headerBytes = block,
			mode = block:sub(101,107),
			uid = tonumber(block:sub(109,115),8),
			gid = tonumber(block:sub(117,123),8),
			size = tonumber(block:sub(125,135),8),
			lastModified = tonumber(block:sub(137,147),8),
			["checksum"] = checksum,
			["type"] = tonumber(block:sub(156,156)),
			linkedName = block:sub(157,257),
			ustar = {
				headerBytes = block:sub(158,501),
				ustarHeader = block:sub(258,263),
				version = block:sub(264,265),
				user = block:sub(266,297),
				group = block:sub(298,329),
				devMajor = block:sub(330,337),
				devMinor = block:sub(338,345),
				filenamePrefix = block:sub(346,501),
			}
		}
		ret[fileName] = header
	--seek block
if not header.size then print("FILE SIZE BUG DETECTED! CANNOT CONTINUE!!")break end
    local skipBlk =
    	math.ceil(header.size / 512) + 1 -- GameGuardian io bug
    file:seek("cur",skipBlk * 512)
	end
	file:close()
	return ret
end
function tar.query(tarPath)
	local file = io.open(tarPath,"rb")
	if not file then return end
	local fileList = {}
	while true do
		local block = file:read(512)
		if not block then break end
		local fileName = block:sub(1,100):gsub("\0+$","")
		table.insert(fileList,fileName)
		local fileSize = tonumber(block:sub(125,135),8)
if not fileSize then print("FILE SIZE CONVERSION BUG DETECTED",block:sub(125,135),1)break end
    local blocksToSkip = math.ceil(fileSize / 512) + 1 -- GameGuardian io bug
    file:seek("cur",blocksToSkip * 512)
	end
	file:close()
	return fileList
end
function tar.queryFile(tarPath)
	local fileList = {}
	for k,v in ipairs(tar.query(tarPath)) do
		if v:sub(#v,#v) ~= "/" then
			fileList[k] = v
		end
	end
	return fileList
end
function tar.queryFolder(tarPath)
	local fileList = {}
	for k,v in ipairs(tar.query(tarPath)) do
		if v:sub(#v,#v) == "/" then
			fileList[k] = v
		end
	end
	return fileList
end
return tar

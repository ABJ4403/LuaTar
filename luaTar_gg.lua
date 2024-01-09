-- This is the GameGuardian UI wrapper for luaTar
-- make sure you have the luaTar.lua script as well :D

local tar = loadfile("luaTar.lua")
if type(tar) ~= "function" then print("luaTar.lua is not exist! this GameGuardian wrapper depends on it.") return end
tar = tar()

-- Tests (also acts as an example as well :/)
function runTests()
	local fileName = "Test.tar"
	os.remove(fileName)

	print("\nTar — Add 3 File")
	tar.add(fileName,"a.txt","This is text Alpha.")
	tar.add(fileName,"b.txt","This is text Bravo.")
	tar.add(fileName,"c.txt","This is text Charlie.")

	print("\nTar — Remove Charlie")
	tar.remove(fileName,"c.txt")

	print("\nTar — Query File")
	local fileList = tar.queryFile(fileName)
	for i=1,#fileList do print(i,fileList[i]) end

	print("\nTar — Query Folder")
	local fileList = tar.queryFolder(fileName)
	for i=1,#fileList do print(i,fileList[i]) end

	print("\nTar — Extract")
	print(1,tar.extract(fileName,"a.txt"))
	print(2,tar.extract(fileName,"b.txt"))
	print(3,tar.extract(fileName,"c.txt") or "<removed>")

	print("\nTar — Check Header Integrity")
	print(tar.checkHeader(fileName))

	print("\nTar — End of Test.")
	os.remove(fileName)
end
--runTests()

-- GG Wrapper
io.readFile = function(path,opMode,readMode)
	local file = io.open(path,opMode)
	local content = file:read(readMode)
	file:close()
	return content
end
local opts = {
	tarPath = gg.getFile():match("(.+)/"),
	tarName = "packedStuff.tar",
	filePath = gg.getFile(),
}
while true do
	local CH = gg.choice({
		"1. Add",
		"2. Extract",
		"3. Remove",
		"4. List files",
		"5. Check header integrity",
		"Run tests & Exit",
		"Exit",
	},nil,"ABJ4403's Lua Tape Archive")
	if not CH then
		break
	elseif CH == 1 then
		CH = gg.prompt({
			"Output of the Tar archive",
			"Name of Tar archive",
			"File to be added",
		},{
			opts.tarPath,
			opts.tarName,
			opts.filePath
		},{
			"path",
			"text",
			"file",
		})
		if CH and CH[1] and CH[2] and CH[3] then
			opts.tarPath = CH[1]
			opts.tarName = CH[2]:gsub("%.tar$","")..".tar"
			opts.tarFile = opts.tarPath..'/'..opts.tarName
			opts.filePath = CH[3]
			opts.fileName = CH[3]:gsub('(.+)/','')
			local fileContent = io.readFile(CH[3],'r','*a')
			if not fileContent then gg.toast("File cant be opened")
			elseif tar.add(opts.tarFile,opts.fileName,fileContent) then gg.toast("Archive created!")
			else gg.toast("Cant create archive path, is the path correct?") end
		end
	elseif CH == 2 then
		CH = gg.prompt({
			"Name of Tar archive",
		},{
			opts.tarPath..'/'..opts.tarName,
		},{
			"file",
		})
		if CH and CH[1] then
			opts.tarFile = CH[1]
			local fileList = tar.query(CH[1])
			if fileList[1] then
				local CH = gg.multiChoice(fileList,nil,"Select files to be extracted")
				if CH then
					for i=1,#fileList do
						if CH[i] then
							io.open(opts.tarPath..'/'..fileList[i],"wb"):write(
								tar.extract(opts.tarFile,fileList[i])
							):close()
						end
					end
				end
			else
				gg.toast("Unknown error")
			end
		end
	elseif CH == 3 then
		CH = gg.prompt({
			"Name of Tar archive",
		},{
			opts.tarPath..'/'..opts.tarName,
		},{
			"file",
		})
		if CH and CH[1] then
			opts.tarFile = CH[1]
			local fileList = tar.query(CH[1])
			if fileList[1] then
				local CH = gg.multiChoice(fileList,nil,"Select files to be removed")
				if CH then
					for i=1,#fileList do
						if CH[i] then
							tar.remove(opts.tarFile,fileList[i])
						end
					end
				end
			else
				gg.toast("Unknown error")
			end
		end
	elseif CH == 4 then
		CH = gg.prompt({
			"Name of Tar archive",
		},{
			opts.tarPath..'/'..opts.tarName,
		},{
			"file",
		})
		if CH and CH[1] then
			local fileList = tar.query(CH[1])
			for i=1,#fileList do print(i,fileList[i]) end
			break
		end
	elseif CH == 5 then
		CH = gg.prompt({
			"Name of Tar archive",
		},{
			opts.tarPath..'/'..opts.tarName,
		},{
			"file",
		})
		if CH and CH[1] then
			print(tar.checkHeader(CH[1]))
			break
		end
	elseif CH == 6 then
		runTests()
		break
	elseif CH == 7 then
		break
	end
end
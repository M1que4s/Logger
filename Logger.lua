--[[
  Author: Miqueas Martinez (miqueas2020@yahoo.com)
  Date: 2020/09/12
  License: MIT (see it in the repository)
  Git Repository: https://github.com/M1que4s/Logger
]]

local Logger = {}
local unp = table.unpack or unpack

local function e(...)
  local str = ""
  local esc = string.char(27)
  local va =  {...}
  str = str .. esc .. "["
  for i, v in ipairs(va) do str = str .. tostring(v) .. ";" end
  return str:gsub("%;$", "") .. "m"
end

local Fmt = {
  Out = {
    Console = e(2).."%s ["..e(0,1).."%s %s%s"..e(0,2).."] %s@%s:"..e(0).." %s",
    LogFile = "%s [%s %s] %s@%s: %s"
  },
  File = {
    Name = "%s_%s.log",
    Suffix = "%Y-%m-%d"
  },
  Time = "%H:%M:%S"
}

local function DirExists(path)
  local f = io.open(path)
  if f then
    f:close()
    return true
  end
end

local function DirNormalize(str)
  local str = tostring(str or "")
  local os_check = os.getenv("HOME")

  if _G.jit then os_check = not (_G.jit.os == "Windows") end

  if os_check then
    if not str:find("%/+", -1) then str = str .. "/" end -- POSIX
  else
    if not str:find("%\\+", -1) then str = str .. "\\" end -- Windows
  end

  return str
end

Logger.Path       = ""
Logger.Namespace  = "Logger"
Logger.Console    = false
Logger.DefaultLvl = 1

Logger.Type = {
  { Name = "TRACE", Color = "32" },
  { Name = "DEBUG", Color = "36" },
  { Name = "INFO.", Color = "34" },
  { Name = "WARN.", Color = "33" },
  { Name = "ERROR", Color = "31" },
  { Name = "FATAL", Color = "35" },
  { Name = "OTHER", Color = "30" }
}

local function StrToLogLevel(str)
  if type(str) == "string" then
    for i, v in ipairs(Logger.Type) do 
      if (str:upper() == v.Name) or (str:upper() == v.Name:sub(1, #v.Name-1)) then 
        return i 
      end
    end
    return 7
  else 
    return str 
  end
end

function Logger:new(name, dir, console)
  assert(type(name) == "string" or type(name) == "nil", "Bad argument to #1 'new()', string expected, got " .. type(name))
  assert(type(dir) == "string" or type(dir) == "nil", "Bad argument to #2 'new()', string expected, got " .. type(dir))
  assert(type(console) == "boolean" or type(console) == "nil", "Bad argument to #3 'new()', boolean expected, got " .. type(console))

  local o = setmetatable({}, { __call = Logger.log, __index = self })
  o.Namespace = name or "Logger"
  o.Console   = console

  if not dir or  #dir == 0 then o.Path = "./"
  elseif dir and DirExists(dir) then o.Path = DirNormalize(dir)
  elseif dir and not DirExists(dir) then
    error("Path '" .. dir .. "' doesn't exists or you can't have permissions to use it.")
  else -- idk...
    error("Something's wrong with '"..dir.."'... (argument #2 in 'new()')")
  end

  return o
end

function Logger:setDefaultLvl(lvl)
  self.DefaultLvl = StrToLogLevel(lvl or 7)
end

function Logger:log(msg, exp, lvl, ...)
  assert(type(lvl) == "number" or type(lvl) == "string" or type(lvl) == "nil",
  "Bad argument #2 to 'log()', Level number or string expected, got " .. type(lvl))

  assert(not (type(msg) == "nil"), "Message expected, got nil!")

  local lvl = (lvl or self.DefaultLvl)
  local msg = tostring(msg)

  local va = {...}
  local lvl = StrToLogLevel(lvl)
  local info = debug.getinfo(2, "Sl")
  local file = io.open(self.Path .. Fmt.File.Name:format(self.Namespace, os.date(Fmt.File.Suffix)), "a+")
  local time = os.date(Fmt.Time)

  if not (exp) then
    local fout = Fmt.Out.LogFile:format(
      time,
      self.Namespace,
      self.Type[lvl].Name,
      info.short_src,
      info.currentline,
      msg
        :format(unp(va))
        :gsub("(" .. string.char(27) .. "%[(.-)m)", "") -- Removes ANSI color escape codes
    )

    file:write(fout)
    file:write("\n")
    file:close()

    if self.Console then
      local cout = Fmt.Out.Console:format(
        time,
        self.Namespace,
        e(self.Type[lvl].Color),
        self.Type[lvl].Name,
        info.short_src,
        info.currentline,
        msg:format(unp(va))
      )
      print(cout)
    end

    if lvl >= 5 and lvl <= 7 then 
      if _G.love then
        _G.love.event.quit()
      end
      os.exit(1) 
    else return exp end
  else return exp end
end

return setmetatable(Logger, { __call = Logger.new, __index = Logger})

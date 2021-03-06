package = "Logit"
-- SemVer: 1.0.0
-- Revisión: 0
version = "1.0.0-0"
source  = {
  url = "git://github.com/Miqueas/Logger",
  tag = "v1.0.0"
}

description = {
  summary  = "Logging made easy!",
  detailed = "A small and versatile library to create log files with Lua that you can easily integrate into your projects.",
  homepage = "https://github.com/Miqueas/Logger",
  license  = "zlib"
}

dependencies = {
  "lua >= 5.1"
}

build = {
  type = "builtin",
  modules = {
    Logit = "Logit.lua"
  }
}

function TestApi()
	local lines = {}
	local function out(s)
		lines[#lines + 1] = s
	end

	local function test(name, fn)
		local ok, err = pcall(fn)
		if ok then
			out("[OK] " .. name)
		else
			out("[FAIL] " .. name .. ": " .. tostring(err))
		end
	end

	local function testField(parent, name)
		return parent[name] ~= nil
	end

	out("=== Lua 5.3 Function Availability Test ===")
	out("_VERSION: " .. tostring(_VERSION))

	-- Bitwise operators
	out("--- Bitwise Operators ---")
	test("bitwise AND (&)", function() local v = 5 & 3; assert(v == 1) end)
	test("bitwise OR (|)", function() local v = 5 | 3; assert(v == 7) end)
	test("bitwise XOR (~)", function() local v = 5 ~ 3; assert(v == 6) end)
	test("bitwise NOT (~)", function() local v = ~0; assert(v == -1) end)
	test("bitwise LSHIFT (<<)", function() local v = 1 << 3; assert(v == 8) end)
	test("bitwise RSHIFT (>>)", function() local v = 8 >> 3; assert(v == 1) end)

	-- Globals
	out("--- Globals ---")
	local globals = {
		"_G", "_VERSION",
		"assert", "collectgarbage", "dofile", "error", "getmetatable",
		"ipairs", "load", "loadfile", "next", "pairs", "pcall", "print",
		"rawequal", "rawget", "rawlen", "rawset", "require", "select",
		"setmetatable", "tonumber", "tostring", "type", "xpcall"
	}
	for _, name in ipairs(globals) do
		test("global: " .. name, function()
			assert(_G[name] ~= nil, name .. " is nil")
			assert(type(_G[name]) == "function" or type(_G[name]) == "table" or type(_G[name]) == "string", name .. " is " .. type(_G[name]))
		end)
	end

	-- coroutine
	out("--- coroutine ---")
	test("coroutine (table)", function() assert(type(coroutine) == "table") end)
	local coroutine_funcs = {
		"create", "isyieldable", "resume", "running", "status", "wrap", "yield"
	}
	for _, name in ipairs(coroutine_funcs) do
		test("coroutine." .. name, function()
			assert(coroutine[name] ~= nil, "nil")
			assert(type(coroutine[name]) == "function", "not a function")
		end)
	end

	-- string
	out("--- string ---")
	test("string (table)", function() assert(type(string) == "table") end)
	local string_funcs = {
		"byte", "char", "dump", "find", "format", "gmatch", "gsub",
		"len", "lower", "match", "rep", "reverse", "sub", "upper",
		"pack", "packsize", "unpack"
	}
	for _, name in ipairs(string_funcs) do
		test("string." .. name, function()
			assert(string[name] ~= nil, "nil")
			assert(type(string[name]) == "function", "not a function")
		end)
	end

	-- table
	out("--- table ---")
	test("table (table)", function() assert(type(table) == "table") end)
	local table_funcs = {
		"concat", "insert", "move", "pack", "remove", "sort", "unpack"
	}
	for _, name in ipairs(table_funcs) do
		test("table." .. name, function()
			assert(table[name] ~= nil, "nil")
			assert(type(table[name]) == "function", "not a function")
		end)
	end

	-- math
	out("--- math ---")
	test("math (table)", function() assert(type(math) == "table") end)
	local math_funcs = {
		"abs", "acos", "asin", "atan", "ceil", "cos", "deg", "exp",
		"floor", "fmod", "log", "max", "min", "modf", "rad",
		"random", "randomseed", "sin", "sqrt", "tan",
		"tointeger", "type", "ult"
	}
	for _, name in ipairs(math_funcs) do
		test("math." .. name, function()
			assert(math[name] ~= nil, "nil")
			assert(type(math[name]) == "function", "not a function")
		end)
	end
	-- math constants
	test("math.huge", function() assert(math.huge == math.huge) end)
	test("math.maxinteger", function() assert(type(math.maxinteger) == "number") end)
	test("math.mininteger", function() assert(type(math.mininteger) == "number") end)
	test("math.pi", function() assert(type(math.pi) == "number") end)

	-- io
	out("--- io ---")
	test("io (table)", function() assert(type(io) == "table") end)
	local io_funcs = {
		"close", "flush", "input", "lines", "open", "output",
		"popen", "read", "tmpfile", "type", "write"
	}
	for _, name in ipairs(io_funcs) do
		test("io." .. name, function()
			assert(io[name] ~= nil, "nil")
			assert(type(io[name]) == "function", "not a function")
		end)
	end

	-- os
	out("--- os ---")
	test("os (table)", function() assert(type(os) == "table") end)
	local os_funcs = {
		"clock", "date", "difftime", "execute", "exit",
		"getenv", "remove", "rename", "setlocale", "time", "tmpname"
	}
	for _, name in ipairs(os_funcs) do
		test("os." .. name, function()
			assert(os[name] ~= nil, "nil")
			assert(type(os[name]) == "function", "not a function")
		end)
	end

	-- debug
	out("--- debug ---")
	test("debug (table)", function() assert(type(debug) == "table") end)
	local debug_funcs = {
		"debug", "getinfo", "getlocal", "getmetatable", "getregistry",
		"getupvalue", "getuservalue", "setuservalue", "setlocal",
		"setmetatable", "setupvalue", "traceback", "upvalueid", "upvaluejoin"
	}
	for _, name in ipairs(debug_funcs) do
		test("debug." .. name, function()
			assert(debug[name] ~= nil, "nil")
			assert(type(debug[name]) == "function", "not a function")
		end)
	end

	-- utf8
	out("--- utf8 ---")
	test("utf8 (table)", function()
		if utf8 == nil then
			error("utf8 library not available")
		end
		assert(type(utf8) == "table")
	end)
	if utf8 then
		local utf8_funcs = { "char", "codepoint", "codes", "len", "offset" }
		for _, name in ipairs(utf8_funcs) do
			test("utf8." .. name, function()
				assert(utf8[name] ~= nil, "nil")
				assert(type(utf8[name]) == "function", "not a function")
			end)
		end
		test("utf8.charpattern", function() assert(utf8.charpattern ~= nil) end)
	end

	-- Metamethods
	out("--- Metamethods ---")
	test("__index", function()
		local t = setmetatable({}, { __index = function(_, k) return k .. "_val" end })
		assert(t.foo == "foo_val")
	end)
	test("__newindex", function()
		local log = {}
		local t = setmetatable({}, { __newindex = function(_, k, v) log[k] = v end })
		t.x = 10
		assert(log.x == 10)
	end)
	test("__add", function()
		local a = setmetatable({}, { __add = function(_, o) return 42 + o end })
		assert(a + 8 == 50)
	end)
	test("__sub", function()
		local a = setmetatable({}, { __sub = function(_, o) return 42 - o end })
		assert(a - 2 == 40)
	end)
	test("__mul", function()
		local a = setmetatable({}, { __mul = function(_, o) return 6 * o end })
		assert(a * 7 == 42)
	end)
	test("__div", function()
		local a = setmetatable({}, { __div = function(_, o) return 84 / o end })
		assert(a / 2 == 42)
	end)
	test("__mod", function()
		local a = setmetatable({}, { __mod = function(_, o) return 10 % o end })
		assert(a % 3 == 1)
	end)
	test("__pow", function()
		local a = setmetatable({}, { __pow = function(_, o) return 2 ^ o end })
		assert(a ^ 3 == 8)
	end)
	test("__unm", function()
		local a = setmetatable({}, { __unm = function(_) return -42 end })
		assert(-a == -42)
	end)
	test("__concat", function()
		local a = setmetatable({}, { __concat = function(_, o) return "hello" .. o end })
		assert(a .. " world" == "hello world")
	end)
	test("__len", function()
		local a = setmetatable({}, { __len = function(_) return 42 end })
		assert(#a == 42)
	end)
	test("__eq", function()
		local mt = { __eq = function() return true end }
		local a = setmetatable({}, mt)
		local b = setmetatable({}, mt)
		assert(a == b)
	end)
	test("__lt", function()
		local a = setmetatable({}, { __lt = function(_, o) return true end })
		local b = setmetatable({}, { __lt = function(_, o) return false end })
		assert(a < b)
	end)
	test("__le", function()
		local a = setmetatable({}, { __le = function(_, o) return true end })
		local b = setmetatable({}, { __le = function(_, o) return false end })
		assert(a <= b)
	end)
	test("__call", function()
		local a = setmetatable({}, { __call = function(_, x, y) return x + y end })
		assert(a(10, 32) == 42)
	end)
	test("__tostring", function()
		local a = setmetatable({}, { __tostring = function(_) return "custom42" end })
		assert(tostring(a) == "custom42")
	end)
	test("__gc (skipped - collectgarbage unavailable)", function() end)
	test("__mode (skipped - collectgarbage unavailable)", function() end)
	test("__metatable (getmetatable)", function()
		local a = setmetatable({}, { __metatable = "locked" })
		assert(getmetatable(a) == "locked")
	end)

	-- Environment variables
	out("--- Environment Variables ---")
	test("_ENV exists", function()
		assert(_ENV ~= nil, "_ENV is nil")
		assert(type(_ENV) == "table", "_ENV is " .. type(_ENV))
	end)
	test("_G exists", function()
		assert(_G ~= nil, "_G is nil")
		assert(type(_G) == "table", "_G is " .. type(_G))
	end)
	test("_ENV == _G", function()
		assert(_ENV == _G, "_ENV and _G are different")
	end)
	test("_ENV can be modified", function()
		local old = _ENV._apitest_temp
		_ENV._apitest_temp = 42
		assert(_apitest_temp == 42)
		_ENV._apitest_temp = old
	end)
	test("_ENV as function env (setfenv/getfenv)", function()
		local function f() return myvar end
		local env = { myvar = 99 }
		if setfenv then
			setfenv(f, env)
			assert(f() == 99)
		else
			error("setfenv not available")
		end
	end)
	test("setfenv/getfenv available", function()
		if setfenv == nil then
			error("setfenv is nil")
		end
		if getfenv == nil then
			error("getfenv is nil")
		end
	end)

	-- package
	out("--- package ---")
	test("package (table)", function()
		if package == nil then error("package library not available") end
		assert(type(package) == "table")
	end)
	if package then
		local package_fields = {
			"config", "cpath", "loaded", "loadlib", "path",
			"preload", "searchers", "searchpath"
		}
		for _, name in ipairs(package_fields) do
			test("package." .. name, function()
				assert(package[name] ~= nil, "nil")
			end)
		end
		test("package.loaded is table", function()
			assert(type(package.loaded) == "table")
		end)
		test("package.preload is table", function()
			assert(type(package.preload) == "table")
		end)
		test("package.searchers is table", function()
			assert(type(package.searchers) == "table")
		end)
		test("package.path is string", function()
			assert(type(package.path) == "string")
		end)
		test("package.cpath is string", function()
			assert(type(package.cpath) == "string")
		end)
		test("package.config is string", function()
			assert(type(package.config) == "string")
		end)
		test("package.searchpath works", function()
			local ok, result = pcall(package.searchpath, "no_such_module", package.path)
			-- should return nil + error msg, or error
			assert(ok == false or result == nil or type(result) == "string")
		end)
		test("package.loadlib available", function()
			assert(type(package.loadlib) == "function")
		end)
	end

	-- Functional tests
	out("--- Functional Tests ---")
	test("pcall works", function()
		local ok, err = pcall(function() error("test") end)
		assert(ok == false)
		assert(string.find(tostring(err), "test"))
	end)
	test("xpcall works", function()
		local ok = xpcall(function() error("test") end, function(e) return e end)
		assert(ok == false)
	end)
	test("setmetatable works", function()
		local t = setmetatable({}, { __index = { x = 42 } })
		assert(t.x == 42)
	end)
	test("rawget/rawset works", function()
		local t = {}
		rawset(t, "k", "v")
		assert(rawget(t, "k") == "v")
	end)
	test("rawequal works", function()
		assert(rawequal(1, 1))
	end)
	test("rawlen works", function()
		assert(rawlen({1,2,3}) == 3)
	end)
	test("select works", function()
		local a, b = select(2, 10, 20, 30)
		assert(a == 20 and b == 30)
	end)
	test("string.format works", function()
		assert(string.format("%d", 42) == "42")
	end)
	test("string.pack/unpack works", function()
		local packed = string.pack("I4", 12345)
		local val = string.unpack("I4", packed)
		assert(val == 12345)
	end)
	test("table.pack/unpack works", function()
		local t = table.pack(1, 2, 3)
		assert(t.n == 3)
		local a, b, c = table.unpack(t)
		assert(a == 1 and b == 2 and c == 3)
	end)
	test("math.type works", function()
		assert(math.type(1) == "integer")
		assert(math.type(1.0) == "float")
	end)
	test("math.tointeger works", function()
		assert(math.tointeger(1.0) == 1)
	end)
	test("coroutine create/resume/yield works", function()
		local co = coroutine.create(function()
			coroutine.yield(42)
			return 99
		end)
		local ok, val = coroutine.resume(co)
		assert(ok and val == 42)
		ok, val = coroutine.resume(co)
		assert(ok and val == 99)
	end)
	test("type works", function()
		assert(type(1) == "number")
		assert(type("") == "string")
		assert(type(true) == "boolean")
		assert(type(nil) == "nil")
		assert(type({}) == "table")
		assert(type(function() end) == "function")
	end)
	test("tostring works", function()
		assert(tostring(42) == "42")
		assert(tostring(true) == "true")
		assert(tostring(nil) == "nil")
	end)
	test("tonumber works", function()
		assert(tonumber("42") == 42)
		assert(tonumber("ff", 16) == 255)
	end)

	out("=== Test Complete ===")

	local filename = "apitest_results.txt"
	PreloadGenClear()
	PreloadGenStart()
	for i = 1, #lines do
		Preload(lines[i])
	end
	PreloadGenEnd(filename)
end

function InitGlobals()
end

function InitCustomPlayerSlots()
SetPlayerStartLocation(Player(0), 0)
SetPlayerColor(Player(0), ConvertPlayerColor(0))
SetPlayerRacePreference(Player(0), RACE_PREF_HUMAN)
SetPlayerRaceSelectable(Player(0), true)
SetPlayerController(Player(0), MAP_CONTROL_USER)
end

function InitCustomTeams()
SetPlayerTeam(Player(0), 0)
end

function main()
SetCameraBounds(-3328.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), -3584.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM), 3328.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), 3072.0 - GetCameraMargin(CAMERA_MARGIN_TOP), -3328.0 + GetCameraMargin(CAMERA_MARGIN_LEFT), 3072.0 - GetCameraMargin(CAMERA_MARGIN_TOP), 3328.0 - GetCameraMargin(CAMERA_MARGIN_RIGHT), -3584.0 + GetCameraMargin(CAMERA_MARGIN_BOTTOM))
SetDayNightModels("Environment\\DNC\\DNCLordaeron\\DNCLordaeronTerrain\\DNCLordaeronTerrain.mdl", "Environment\\DNC\\DNCLordaeron\\DNCLordaeronUnit\\DNCLordaeronUnit.mdl")
NewSoundEnvironment("Default")
SetAmbientDaySound("LordaeronSummerDay")
SetAmbientNightSound("LordaeronSummerNight")
SetMapMusic("Music", true, 0)
InitBlizzard()
InitGlobals()
TestApi()
end

function config()
SetMapName("TRIGSTR_001")
SetMapDescription("TRIGSTR_003")
SetPlayers(1)
SetTeams(1)
SetGamePlacement(MAP_PLACEMENT_USE_MAP_SETTINGS)
DefineStartLocation(0, -512.0, -64.0)
InitCustomPlayerSlots()
SetPlayerSlotAvailable(Player(0), MAP_CONTROL_USER)
InitGenericPlayerSlots()
end


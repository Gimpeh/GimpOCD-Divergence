local closures = require("lib.closures")

local function expect(a,b,msg)
    local ok = (a==b)
    print((ok and "PASS" or "FAIL") .. ": " .. (msg or ""), " -> expected", b, "got", a)
    return ok
end

print("=== closures playground ===")

-- counter
local c = closures.counter(10)
expect(c(), 11, "counter increments default")
expect(c(2), 13, "counter increments by 2")

-- once
local ran = 0
local o = closures.once(function(x) ran = ran + 1; return x*2 end)
expect(o(3), 6, "once first run")
expect(o(4), 6, "once cached result")
expect(ran, 1, "once executed only once")

-- memoize
local calls = 0
local mf = closures.memoize(function(x) calls = calls + 1; return x*x end)
expect(mf(3), 9, "memoize compute")
expect(mf(3), 9, "memoize cached")
expect(calls, 1, "memoize called once for same arg")

-- curry
local function add(a,b,c) return a+b+c end
local cur = closures.curry(add, 3)
expect(cur(1)(2)(3), 6, "curry add")

-- lazy
local l = closures.lazy(function() return os.time() end)
local v1 = l(); local v2 = l()
expect(v1, v2, "lazy same value on repeated calls")

-- event emitter
local e = closures.eventEmitter()
local sum = 0
local function inc(x) sum = sum + x end
e.on("tick", inc)
e.emit("tick", 5)
expect(sum, 5, "event emitter calls listener")
e.off("tick", inc)
e.emit("tick", 2)
expect(sum, 5, "listener removed")

-- stateful bank
local b = closures.makeBank(100)
b.deposit(25); expect(b.getBalance(), 125, "bank deposit")
expect(b.withdraw(50), true, "bank withdraw ok")
expect(b.getBalance(), 75, "bank balance after withdraw")
expect(b.withdraw(999), false, "bank withdraw too large")

-- shared state
local s = closures.sharedState(7)
expect(s.get(), 7, "shared state initial")
s.set(42)
expect(s.get(), 42, "shared state mutated")

-- memoizeByKey
local mk = closures.memoizeByKey(function(k) return {val = k} end)
local a = mk("hello")
local b2 = mk("hello")
expect(a, b2, "memoizeByKey returns same table for same key")

print("=== done ===")

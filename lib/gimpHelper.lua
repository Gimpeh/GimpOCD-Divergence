local gimpHelper = {}

function gimpHelper.saveTable(tblToSave, filename)
    local function serialize(tbl)
        local result = "{"
        local first = true
        for k, v in pairs(tbl) do
            if not first then 
                result = result .. ","
            else 
                first = false 
            end

            local key = type(k) == "string" and k or "["..k.."]"
            local value
            if type(v) == "table" then
                value = serialize(v)
            elseif type(v) == "string" then
                value = string.format("%q", v)
            else
                value = tostring(v)
            end
            result = result .. key .. "=" .. value
        end
        return result .. "}"
    end

    local file, err = io.open(filename, "w")
    if not file then
        return false, "Unable to open file for writing"
    end

    file:write("return " .. serialize(tblToSave))
    file:close()
    return true
end

function gimpHelper.loadTable(filename)
    local file, err = io.open(filename, "r")
    if not file then
        return nil, "Unable to open file for reading"
    end

    local content = file:read("*a")
    file:close()
    local func = load(content)
    if not func or type(func) ~= "function" then
        return nil, "Unable to load file content"
    end
    local tbl = func()
    return tbl
end

function gimpHelper.correctCoordinates(xyzTable, xyzTableOffset)
    if not xyzTableOffset then
        return xyzTable
    end
    local correctedTable = {}
    correctedTable.x = xyzTable.x - xyzTableOffset.x
    correctedTable.y = xyzTable.y - xyzTableOffset.y
    correctedTable.z = xyzTable.z - xyzTableOffset.z
    return correctedTable
end

function gimpHelper.mathStats(t)
  local n = #t
  if n == 0 then return {count=0,min=nil,max=nil,mean=nil,median=nil,stdev=nil} end
  local s, mn, mx = 0, t[1], t[1]
  for i=1,n do local v=t[i]; s=s+v; if v<mn then mn=v end; if v>mx then mx=v end end
  local mean = s/n
  -- median (non-allocating copy by simple insertion—n is tiny here)
  local c = {}
  for i=1,n do c[i]=t[i] end
  table.sort(c)
  local median = (n%2==1) and c[(n+1)//2] or (c[n//2] + c[n//2+1])/2
  local var = 0; for i=1,n do local d=t[i]-mean; var=var+d*d end; var = var/(n)
  return {count=n, min=mn, max=mx, mean=mean, median=median, stdev=math.sqrt(var)}
end


return gimpHelper

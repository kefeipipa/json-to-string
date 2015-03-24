package.path = package.path .. ";/home/momo/MyProject/lua/?.lua"



function pResult(re)
    local str = {}
--    print(tostring(re))
    if "table" == type(re) then
    --print("\n table type")
        --table.insert(str,'{')
	print("========================")
        for i,k in pairs(re) do
	    --print(i,k)
            
            print(i,k,type(i),type(k))
	    table.insert(str,'[' .. tostring(i) .. ']'.. '=' .. pResult(k))
            --print("===================")
	    --print("in the table for")
            --print(table.concat(str,','))
            --print("===================")
        end
	print("========================")
        --table.insert(str,'}')
	return '{' .. table.concat(str,',') .. '}'

    else
        --table.insert(str,tostring(re))
        --print(re)
        return tostring(re)
    end
--    print("-------------------")
--    print(table.concat(str,','))
--    print("-------------------")
    --return table.concat(str,',')

end
--print(pResult(32))

local json = require 'json'
test = {}
table.insert(test,json.Marshal('   {  \"nnnnn\"  :  "asd"  ,  "2"  :  91  }  '))
--[[
table.insert(test,json.Marshal('[56,57,""]'))
table.insert(test,json.Marshal("[1,2,3,[7,8,9],\"32\"]"))
table.insert(test,json.Marshal('{"aa":"1\\\"1,1]1","1":90,"5":"v\\\",vv","45":333,"bb":[2,[3,4],88]}'))
table.insert(test,json.Marshal('[{"aa":"aa\\naa","gg":[0,9,8]},66]'))
table.insert(test,json.Marshal('{"1":90,"2":80,"true":70,"{\\\"2\\\":3}":"bb\\nbb"},"5":66}'))

table.insert(test,json.Marshal('{"1":{"cc":3,"dd":4},"2":91}'))
]]
for i,k in pairs(test) do
    print(table.maxn(k))
    print(pResult(k))
end

--[[
print(json.json2string("aaa\\aaaa"))
print(json.json2string("nnn\\n,nnn"))
print(json.json2string("fff\\ffff"))
print(json.json2string("vvv\\vvvv"))
print(json.json2string("rrr\\rrrr"))
print(json.json2string("ttt\\tttt"))
print(json.json2string("ccc\\/ccc"))
print(json.json2string("hhh\\\\hhh"))
print(json.json2string("aaa\\\","))
print("rrr\arrr")
]]
--[[
a = "[[sss[sadf]ssadsf]1244]"
mm = 2
nn = json.find_match2(a,mm,'[')
print(string.sub(a,mm,nn))
]]
--[==[

table1 = {3,4,nil,8999,test1 ={76,test2 = {"44",true},4},true,789,"23",a = "ee",b = "32"}
table2 = {"ase/.,\"",234}
--M2 = json.Marshal("[\"a\",\"b\",\"c\",\"\\u0300\"]")
--M4 = json.Marshal("{\"a1a2\":22}")
M5 = json.Marshal("{\"ab\\\\cd\":111,\"ac\\ncc12\":[2,3,4],\"1\":\"222\",\"3\":345678,\"4\":null,\"a32\":100000}")
M3 = json.Marshal("{\"d\\\"xfa[[ggg]]aarb\nbb\\bccc\\nx\\\"d\\/d\\\\r\\teee\\u0034\":4,\"sss\":\"dd\\\"de\",\"1\":1,\"2\":2,\"3\":3}")
M6 = json.Marshal("[\"a\\\\sd\",\"ssssssssssssssss\\\n1\\\"1\\\\11\\f111\\n11\"11111\"]")
--print("M2 is: ")
--pResult(M2)    
--print(json.Unmarshal(M2))
--print("M4 is: ")
--pResult(M4)
--print(json.Unmarshal(M4))
print("M3 is: ")
pResult(M3)
--print(json.Unmarshal(M3))
print("M5 is: ")
pResult(M5)
--print(json.Unmarshal(M5))
print("M6 is: ")
pResult(M6)
--print(json.Unmarshal(M6))
print("22222222222222222")
print(json.json2string("a1\\a1\\n1\v1\\\\1\\\"1aaaa\\u1234gggg"))
print()
json_str = "\\u16"
local num = tonumber(string.sub(json_str,3,-1))
lua_val = 0
local i = 0
while(num ~= 0) do
    local last = num%10
    lua_val = lua_val + last*(16^i)
    num = (num-last)/10
    i = i + 1
end
print("cccccccccccccccccccccccccc")
s = '\"\\\\'
print(s)
print(string.format("%q",s))
]==]



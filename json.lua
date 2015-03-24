json = {}

function json.trim (s)
    return (string.gsub(s, "^%s*(.-)%s*$", "%1"))
end

function json.unicode2utf8(unic_str)
    local unicode_str = '0x' .. unic_str
    --print(unicode_str)
    local num = tonumber(unicode_str)
    local utf8_num = 0
    if num < 0x80 then
        utf8_num = num
    elseif num >= 0x80 and num < 0x800  then
        local low = bit32.bor(0x80,(bit32.band(0x3f,num)))
        local high = bit32.bor(0xc0,(bit32.rshift(bit32.band(0x7c0,num),6)))
        utf8_num = low + bit32.lshift(high,8)
    elseif num >= 0x800 and num < 0x10000 then
        local low = bit32.bor(0x80,(bit32.band(0x3f,num)))
        local middle = bit32.bor(0x80,bit32.rshift(bit32.band(0xfc0,num),6))
        local high = bit32.bor(0xe0,bit32.rshift(bit32.band(0x7000,num),12))
        utf8_num = low + bit32.lshift(middle,8) + bit32.lshift(high,16)
    else
        return ""
        --print("error unicode")
    end
    return string.format("%x",utf8_num)
end
function json.json2string(unicode)
    local unicode_str = unicode
    local utf8string = ''

    
    i = 1
    while(i <= string.len(unicode_str)) do
        local src_char = string.sub(unicode_str,i,i)
        if '\\'== src_char then
            i = i+1
            if '\"'==string.sub(unicode_str,i,i) then
                utf8string = utf8string .. '\"'
            elseif '\'' == string.sub(unicode_str,i,i) then
                utf8string = utf8string .. '\''
            elseif 'b' == string.sub(unicode_str,i,i) then
                utf8string = utf8string .. '\b'
            elseif '\\'==string.sub(unicode_str,i,i) then
                utf8string = utf8string .. '\\'
            elseif 'f'==string.sub(unicode_str,i,i) then
                utf8string = utf8string .. '\f'
            elseif 'n'==string.sub(unicode_str,i,i) then
                utf8string = utf8string .. '\n'
            elseif 'v'==string.sub(unicode_str,i,i) then
	        utf8string = utf8string .. '\v'
            elseif 'a'==string.sub(unicode_str,i,i) then
	        utf8string = utf8string .. '\a'
	    elseif 'r'==string.sub(unicode_str,i,i) then
                utf8string = utf8string .. '\r'
            elseif 't'==string.sub(unicode_str,i,i) then
                utf8string = utf8string .. '\t'
            elseif '/'==string.sub(unicode_str,i,i) then
                utf8string = utf8string .. '/'
            elseif 'u'==string.sub(unicode_str,i,i) then
                utf8string = utf8string .. json.unicode2utf8(string.sub(unicode_str,i+1,i+4))
                i = i+4
            else
	        --utf8string = utf8string .. '\\'
		--i = i-1
            end
	
	else
            utf8string = utf8string .. tostring(src_char)
        end
        i = i+1
    end
    
    return tostring(utf8string)
end

function json.string2json(src_str)
    local dst_str = ''
    for i = 1,string.len(src_str) do
        local src_char = string.sub(src_str,i,i)
        if src_char == '\"' then
	    dst_str = dst_str .. "\\\""
	elseif src_char == '\\' then
	    dst_str = dst_str .. "\\\\"
        elseif src_char == '\b' then
            dst_str = dst_str .. "\\b"
        elseif src_char == '\f' then
            dst_str = dst_str .. "\\f"
        elseif src_char == '\n' then
            dst_str = dst_str .. "\\n"
        elseif src_char == '\r' then
            dst_str = dst_str .. "\\r"
        elseif src_char == '\t' then
            dst_str = dst_str .. "\\t"
        elseif src_char == '/' then
            dst_str = dst_str .. "\\/"
        else
            dst_str = dst_str .. src_char
	end
    end
    return dst_str
end


function json.find_match1(json_str,pos)
    --find ""
    local i = 0
    local j = 0
    i,j = string.find(json_str,'[^\\]\"',pos)
    if nil ~= j then
        return j
    else
        return nil
        --error()
    end
end


function json.find_match2(json_str,pos,seq)
    --return where {} and [] is 
    local q1 = ''
    local q2 = ''
    if '{' == seq then
        q1 = '{'
	_q1 = '{'
	q2 = '}'
	_q2 = '}'
    else 
        q1 = '['
	_q1 = '%['
	q2 = ']'
	_q2 = '%]'
    end
    local match = pos
    while match do
        match = string.find(json_str,q2,match+1)
	re = string.sub(json_str,pos,match)
        --print("re is ".. re)
        _, num1 = string.gsub(re,_q1,q1)
	_, num2 = string.gsub(re,_q2,q2)
	--print("num1 is " .. tostring(num1))
	--print("num2 is " .. tostring(num2))
	if num1 == num2 then
	    break
	end
    end
    if match then
        return match
    else
        return nil
        --error()
    end
end


function json.Marshal(json_str)
    
    --print(json_str)
    --local json_str = json_str0
    org_josn_str = json_str
    json_str = json.trim(json_str)

    --empty "" or empty {}
    if(''==json_str or '""' == json_str) then
        return ''
    
 --   elseif("\\\"\\\"" == json_str) then
 --       return ''
    
    elseif("{}" == json_str or "[]" == json_str) then
        return {}
    end


    local lua_val = {}
    local element = ""
    local key = ""
    local pos = 1
    local e = 1
    local Mkey = nil

    --handle table
    if("{" == string.sub(json_str,1,1)) then
        if '}' ~= string.sub(json_str,-1,-1) then
	    return nil
	    --error()
	end
    json_str = string.sub(json_str,1,-2) .. ',' .. '}' 
    local i = 1
    local j = 2
	local k = 1
    --local match = json.find_match(1,json_str)
	local last_j = j
	local value = ""
	--print("bbb")
	--print(json_str)
    while (nil ~= k and k+1 ~= string.len(json_str)) do
	    --print("aaa")
	    i,j = string.find(json_str,'\".-\"%s-:',j)
	    -- get key
        j2 = j
	    key = string.sub(json_str,i+1,j-2)
	    while ('\\' == string.sub(key,-1,-1)) do 
	        j1,j2 = string.find(json_str,'\"%s-:',j)  
              
    		if nil == j2 then
    		    return lua_val
    		end
    	    key = string.sub(json_str,i+1,j1-1)
            
                    --e,_ =string.find(element,"\":") 
    	end
             
            --print("++++++++++++++++++++++++") 
            --print("the key is " .. key)
            --print("++++++++++++++++++++++++") 
            --local key_i = 0
	    --local key_j = 0
        print("key_str is:   ".. key)
	    Mkey = json.Marshal(key)
            --print(Mkey,type(Mkey))
        j = string.find(json_str,'[^%s]',j2+1)
        if ('\"' == string.sub(json_str,j,j)) then
	        k0 = json.find_match1(json_str,j)  --\"
	    elseif ('['== string.sub(json_str,j,j)) then
	        k0 = json.find_match2(json_str,j,'[') --]
	    elseif ('{' == string.sub(json_str,j,j) )then
	        k0 = json.find_match2(json_str,j,'{') --}
	    else
	        k0 = j    		
	    end
        k = string.find(json_str,',',k0)
	    --get value 
	    if nil == k then
	        value = string.sub(json_str,j+1,-2)
        else
	        value = string.sub(json_str,j+1,k-1)
        end
            --print("the value is "..value)
	    --[[
            if(tonumber(key)) then
	        print("next call is ".. key .. '\t' .. value)
                lua_val[tonumber(key)] = json.Marshal(value)
            else   
                lua_val[json.json2string(key)] = json.Marshal(value)
                --lua_val[tostring(key)] = json.Marshal(string.sub(element,pos +1,-1))
            end
	    ]]
	    lua_val[Mkey] = json.Marshal(value)
        j = k
    	 
		
    end
	--if(nil == last_j) then
	    --i,j = string.find(json_str,'\".-\":..-')
	    --last_j =     
	--    last_j = 1
	--end
	--print("aaaaa",element)
        --element = (string.sub(json_str,last_j,-2))
        --print("aaaaa",element)
       -- print("++++++++++++++++++++++++") 
        --print("last element is " .. tostring(element))
        --print("++++++++++++++++++++++++") 
        --pos = string.find(element,':')
	--key = string.sub(element,2, pos-2)
        --if(tonumber(key)) then
	--    lua_val[tonumber(key)] = json.Marshal(string.sub(element,pos +1,-1))
	--else
	--    lua_val[json.json2string(key)] = json.Marshal(string.sub(element,pos +1,-1))
	    --lua_val[tostring(key)] = json.Marshal(string.sub(element,pos +1,-1))
	--end

            
    elseif("[" == string.sub(json_str,1,1)) then
        local pos1 = 2
        local pos2 = 2
        local json_str_1 = '[,'.. string.sub(json_str,2,string.len(json_str))
        --print(json_str1)
        local i = 1
        local isend = true
        while(isend) do
	
            --pos2 = json.findposb(pos1,json_str)
            --if(not pos2) then 
            --    break
            --end
--            print("++++++++++++++++++++++++") 
            isend = string.find(json_str_1,',',pos1+1) 
	    if '\"' == string.sub(json_str_1,pos1+1,pos1+1) then
	        pos2 = json.find_match1(json_str_1,pos1+1) +1
                print('in "" is' .. string.sub(json_str_1,pos1,pos2))
	    elseif ('['== string.sub(json_str_1,pos1+1,pos1+1)) then
	        pos2 = json.find_match2(json_str_1,pos1+1,'[') +1
                print('in [] is' .. string.sub(json_str_1,pos1,pos2))
	    elseif ('{' == string.sub(json_str_1,pos1+1,pos1+1)) then
	        pos2 = json.find_match2(json_str_1,pos1+1,'{') +1
                print('in {} is' .. string.sub(json_str_1,pos1,pos2))
	    else
	        pos2 = string.find(json_str_1,',',pos1+1)
                print('in ,, is ' .. string.sub(json_str_1,pos1,pos2))
	    end
	    --pos2 = string.find(json_str,",",pos1+1)
	    if nil == isend then
                --print("++++++++++++++++++++++++")
                --print("in [...] last element is " .. tostring(string.sub(json_str_1, pos1 + 1, -2)))
                lua_val[i] = json.Marshal(string.sub(json_str_1, pos1 + 1, -2)) 
                print('last is: ' ..string.sub(json_str_1,pos1+1,-1)..' ,return is',lua_val[i])
	    else
                --print("in [...] element is " .. tostring(string.sub(json_str_1, pos1 + 1, pos2 - 1)))
                --print("++++++++++++++++++++++++") 
                lua_val[i] = json.Marshal(string.sub(json_str_1, pos1 + 1, pos2 - 1))
                print('not last is: ' .. string.sub(json_str_1,pos1+1,pos2-1)..'return is',lua_val[i],type(lua_val[i]))
                
            end
            pos1 = pos2
            i = i+1
        end
        --lua_val[i] = json.Marshal(string.sub(json_str1,pos1+1,-2))
        --print("++++++++++++++++++++++++") 
        --print("last in [] element is " .. tostring(string.sub(json_str1, pos1 + 1, -2)))
        --print("++++++++++++++++++++++++") 
    --elseif("\"" == string.sub(tostring(json_str),1,1)) then tostring(json_str)
    elseif("true" == json_str) then
	lua_val = true
    elseif("false" == json_str) then
	lua_val = false
    elseif("null" == json_str) then
	lua_val = nil
    elseif(tonumber(json_str)) then
        --print(json_str,tonumber(json_str),type(json_str),type(tonumber(json_str)))
	lua_val = tonumber(json_str)
    else
        --print("----------------------")
        --print(json_str)
        lua_val = json.json2string(string.sub(json_str,1,-1))
        --lua_val = tostring(string.sub(json_str,2,-2))
    end
    return lua_val
end
function json.findposb(posa,json_str)
    local posb = 1
    if("[" == string.sub(json_str,posa + 1,posa + 1)) then
	posb = string.find(json_str, "]", posa + 1)+1
	if(not posb) then
	    --print("\"[]\" not match")
	end
    elseif("{" == string.sub(json_str,posa + 1, posa + 1)) then
	posb = string.find(json_str,"}",posa + 1) +1
	if(not posb) then
	    --print("\"{}\" not match")
	end
    else
	posb = string.find(json_str,",",posa + 1)
    end
    return posb
end

function json.Unmarshal(lua_val)
    local json_str = ""
    if("boolean"== type(lua_val)) then
        json_str = json_str .. tostring(lua_val) 
    elseif(nil == lua_val) then
        json_str = json_str .. "null"
    elseif("number" == type(lua_val)) then
	json_str = json_str ..tonumber(lua_val)
    elseif("string" == type(lua_val))then
        json_str = json_str .. "\"" .. json.string2json(lua_val) .. "\""
        --json_str = json_str .. "\"" .. tostring(lua_val) .. "\""
    elseif("table" == type(lua_val)) then
        local isarray = true
        for i,k in pairs(lua_val) do
            isarray = isarray and ("number" == type(i))   
        end
	if(isarray) then
	    json_str = "["
	    for i = 1,table.maxn(lua_val) do
                json_str = json_str .. json.Unmarshal(lua_val[i]) .. ","
	    end	        
	    json_str = string.sub(json_str,1,-2) .."]"
	else
	    json_str = "{"
            local j = 1
            for i = 1,table.maxn(lua_val) do
                
                json_str = json_str .. "\"" .. j .. "\":"
                json_str = json_str .. json.Unmarshal(lua_val[i]) .. ","
                j = j+1
            end
	    for i,k in pairs(lua_val) do
                if(not tonumber(i)) then
	            json_str = json_str .."\"" .. json.string2json(i) .. "\":"
	            --json_str = json_str .."\"" .. tostring(i) .. "\":"
	            json_str = json_str .. json.Unmarshal(k) .. ","
                end
	    end
	    json_str = string.sub(json_str,1,-2) .."}"
	end

    else
        return ""
        --print("other types")
    end
    --json_str = string.sub(json_str,1,-2)
    return json_str

end
 
return json

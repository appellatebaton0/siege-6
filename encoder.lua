code = {
        'A', 'B', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'J', 
        'K', 'L', 'M', 'N', 'O', 'P', 'Q', 'R', 'S', 'T', 
        'U', 'V', 'W', 'X', 'Y', 'Z', 'a', 'b', 'c', 'd', 
        'e', 'f', 'g', 'h', 'i', 'j', 'k', 'l', 'm', 'n', 
        'o', 'p', 'q', 'r', 's', 't', 'u', 'v', 'w', 'x', 
        'y', 'z', '!', '@', '#', '$', '%', '^', '&', '*',
        '(', ')', '[', ']', '{', '}', ':', ';', ',', '.',
        '<', '>', '/', '?', '~', '`', '-', '_', '+', '+' 
    }

//num_as_code=function(value)
//    if value <= 9 then return tostr(value) end
//    return code[value - 9]
//end

code_as_num=function(value)
    if tonum(value) != nil then
        if tonum(value) <= 9 then return tonum(value) end
    end

    inverse={}
    for k,v in pairs(code) do
        inverse[v]=k
    end

    return inverse[value] + 9
end

//encode=function(table)
//    // Encodes a table of color values 
//    grid_size = #table
//
//    // Get the table as a hex-like string.
//    hex = ''
//    for i=1,grid_size do
//        for j=1,grid_size do
//            hex = hex..num_as_code(table[j][i])
//        end
//    end
//
//    // Compress the string.
//
//    compress = ''
//    last = ''
//    last_value = 1
//    for i=1,#hex do
//            if last == '' then last = hex[i]
//        elseif last == hex[i] then last_value += 1
//        elseif last != hex[i] then 
//            compress = compress..last..num_as_code(last_value)
//            last = hex[i]
//            last_value = 1
//        end
//    end
//    compress = compress..last..num_as_code(last_value)
//
//    printh(compress..",", 'encoded.txt')
//
//    
//    return compress
//end

// Decodes an art string into a usable array
decode=function(string)

    response = {}

    for i=1,#string/2 do
        color = code_as_num(string[(i * 2) - 1])
        count = code_as_num(string[i * 2])

        for i=1,count do
            response[#response + 1] = color
        end
    end
    
    return response


end
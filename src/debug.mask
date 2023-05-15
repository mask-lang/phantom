--[[ Debugging helper functions ]]--
local finfo = debug.getinfo
return setmetatable({
    --[[ Get function param count ]]
    f_num_args = function(func)
        return finfo(func).nparams
    end,

    --[[ Dump table contents to string for debugging purposes ]]
    inspect = function(self, variable, indent)
        if type(variable) ~= 'table' then
            if type(variable) == 'string' then
                return '\'' .. variable .. '\''
            end
            return tostring(variable)
        end
        indent = indent or ''
        local indented = indent .. '  '
        local result = { '{' }
        for key,val in pairs(variable) do
            if type(key) ~= 'number' then
                result[#result+1] = indented .. key .. ' = ' .. self:inspect(val, indented) .. ','
            end
        end
        for _,val in ipairs(variable) do
            result[#result+1] = indented .. self:inspect(val, indented) .. ','
        end
        result[#result+1] = indent .. '}'
        return table.concat(result, '\n')
    end,

    --[[ Printing debug messages.
        Inspect variable's value if provided
        Function arguments:
            verbose_level (optional) : number
            message : string
            variable (optional) : any
    ]]
    verbose = 0, -- global verbose level, determines which debug values should be printed
    print = function(self, ...)
        local args = {...}
        local verbose_level = 1
        local message = args[1]
        local variable = nil
        if #args > 1 then
            variable = args[2]
            if #args > 2 then
                verbose_level = args[1]
                message = args[2]
                variable = args[3]
            end
        end
        if self.verbose < verbose_level then return end
        io.output(io.stdout)
        if variable ~= nil then
            io.write(message .. ': ' .. self:inspect(variable))
        else
            if type(message) ~= 'string' then
                io.write(self:inspect(message))
            else
                io.write(message)
            end
        end
        io.write('\n')
        io.flush()
    end,
}, {
    __call = function(self, ...)
        self:print(...)
    end
})

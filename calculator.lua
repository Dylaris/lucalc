local VM     = require("vm")
local Lexer  = require("lexer")
local Parser = require("parser")

local function run(source)
    local vm = VM:new()
    local lexer = Lexer:new(source)
    local parser = Parser:new(vm, lexer.tokens)

    if not lexer:scan() then return end
    if not parser:parse_expression() then return end
    vm:interpret()
end

local function repl()
    while true do
        -- prompt
        io.write(">> ")
        io.flush()

        -- read the input
        local input = io.read("l")
        if input == "exit" then break end

        -- execute the input
        run(input)
    end
end

repl()

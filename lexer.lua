local Lexer = {}
Lexer.__index = Lexer
setmetatable(Lexer, Lexer)

TK_NUMBER = 0
TK_PLUS   = 1
TK_MINUS  = 2
TK_STAR   = 3
TK_SLASH  = 4
TK_LPAREN = 5
TK_RPAREN = 6

function Lexer:new(source)
    local obj = {}
    setmetatable(obj, self)
    obj.source = source or ""
    obj.tokens = {}
    return obj
end

local function make_token(type, value)
    local token = {}
    token.type = type
    token.value = value
    return token
end

function Lexer:scan()
    local i = 1
    while i <= #self.source do
        local ch = self.source:sub(i, i)

        -- skip whitespace
        if ch == " " or ch == "\t" or ch == "\n" or ch == "\r" then
            i = i + 1
        -- number
        elseif ch:match("%d") then
            local num = ch
            i = i + 1
            while i <= #self.source and self.source:sub(i, i):match("%d") do
                num = num .. self.source:sub(i, i)
                i = i + 1
            end
            table.insert(self.tokens, make_token(TK_NUMBER, tonumber(num)))
        -- '+'
        elseif ch == "+" then
            table.insert(self.tokens, make_token(TK_PLUS, ch))
            i = i + 1
        -- '-'
        elseif ch == "-" then
            table.insert(self.tokens, make_token(TK_MINUS, ch))
            i = i + 1
        -- '*'
        elseif ch == "*" then
            table.insert(self.tokens, make_token(TK_STAR, ch))
            i = i + 1
        -- '/'
        elseif ch == "/" then
            table.insert(self.tokens, make_token(TK_SLASH, ch))
            i = i + 1
        -- '('
        elseif ch == "(" then
            table.insert(self.tokens, make_token(TK_LPAREN, ch))
            i = i + 1
        -- ')'
        elseif ch == ")" then
            table.insert(self.tokens, make_token(TK_RPAREN, ch))
            i = i + 1
        else
            print("LEXER ERROR: Unexpected character: " .. ch)
            return false;
        end
    end

    return true
end

return Lexer

require("vm")
require("lexer")

local Parser = {}
Parser.__index = Parser
setmetatable(Parser, Parser)

function Parser:new(vm, tokens)
    local obj = {}
    setmetatable(obj, self)
    obj.vm = vm or {}
    obj.tokens = tokens or {}
    obj.prev = 0
    obj.cur  = 1
    return obj
end

local PREC_NONE       = 0
local PREC_ASSIGNMENT = 1   -- '='
local PREC_TERM       = 2   -- '+' '-'
local PREC_FACTOR     = 3   -- '*' '/'
local PREC_UNARY      = 4   -- '-'

local Rules = {}

local function get_rule(type)
    return Rules[type]
end

local parse_grouping = function (self)
    self:parse_expression()
    if not self:match(TK_RPAREN) then
        print("PARSER ERROR: unclosed paren")
    end
end

local parse_unary = function (self)
    local operator_type = self:prev_token().type

    self:parse_prec(PREC_UNARY)

    if operator_type == TK_MINUS then
        self.vm:append_code(OP_NEG)
    end
end

local parse_binary = function (self)
    local operator_type = self:prev_token().type
    local rule = get_rule(operator_type)
    self:parse_prec(rule[3] + 1)

    if operator_type == TK_PLUS then
        self.vm:append_code(OP_ADD)
    elseif operator_type == TK_MINUS then
        self.vm:append_code(OP_SUB)
    elseif operator_type == TK_STAR then
        self.vm:append_code(OP_MUL)
    elseif operator_type == TK_SLASH then
        self.vm:append_code(OP_DIV)
    end
end

local parse_number = function (self)
    local token = self:prev_token()
    local constant_idx = self.vm:append_constant(token.value)
    self.vm:append_code(OP_LD)
    self.vm:append_code(constant_idx)
end

function Parser:current_token()
    return self.tokens[self.cur]
end

function Parser:prev_token()
    return self.tokens[self.prev]
end

function Parser:advance()
    self.prev = self.cur
    self.cur = self.cur + 1
end

function Parser:match(type)
    if self.cur > #self.tokens then return false end
    if self:current_token().type == type then
        self:advance()
        return true
    end
    return false
end

function Parser:parse_expression()
    Rules[TK_LPAREN] = {parse_grouping, nil, PREC_NONE}
    Rules[TK_RPAREN] = {nil, nil, PREC_NONE}
    Rules[TK_PLUS]   = {nil, parse_binary, PREC_TERM}
    Rules[TK_MINUS]  = {parse_unary, parse_binary, PREC_TERM}
    Rules[TK_SLASH]  = {nil, parse_binary, PREC_FACTOR}
    Rules[TK_STAR]   = {nil, parse_binary, PREC_FACTOR}
    Rules[TK_NUMBER] = {parse_number, nil, PREC_NONE}

    if self.cur > #self.tokens then 
        return false 
    end
    return self:parse_prec(PREC_ASSIGNMENT)
end

function Parser:parse_prec(precedence)
    self:advance()
    local parse_prefix = get_rule(self:prev_token().type)[1]
    if not parse_prefix then
        print("PARSER ERROR: Expect expression")
        return false
    end
    parse_prefix(self)

    local cur_tok = self:current_token()
    while cur_tok and precedence <= get_rule(cur_tok.type)[3] do
        self:advance()
        local parse_infix = get_rule(self:prev_token().type)[2]
        if parse_infix then
            parse_infix(self)
        end
        cur_tok = self:current_token()
    end

    return true
end

return Parser

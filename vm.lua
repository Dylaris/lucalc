local VM = {}
VM.__index = VM
setmetatable(VM, VM)

OP_ADD = 0
OP_SUB = 1
OP_DIV = 2
OP_MUL = 3
OP_NEG = 4
OP_LD  = 5

function VM:new(source)
    local obj = {}
    setmetatable(obj, self)

    obj.chunk = {
        codes = {},
        constants = {},
    }
    obj.stack = {}
    obj.pc = 1
    obj.sp = 1

    return obj
end

local function is_stack_empty(vm)
    return vm.sp == 1
end

function VM:push(value)
    self.stack[self.sp] = value
    self.sp = self.sp + 1
end

function VM:pop()
    if is_stack_empty(self) then
        error("pop error: stack is empty")
    end
    self.sp = self.sp - 1
    return self.stack[self.sp]
end

function VM:append_code(code)
    self.chunk.codes[#self.chunk.codes + 1] = code
end

function VM:append_constant(value)
    self.chunk.constants[#self.chunk.constants + 1] = value
    return #self.chunk.constants
end

function VM:read_byte()
    return self.chunk.codes[self.pc]
end

function VM:get_constant(index)
    return self.chunk.constants[index]
end

function VM:interpret()
    while self.pc <= #self.chunk.codes do
        if self:read_byte() == OP_ADD then
            self.pc = self.pc + 1
            local b = self:pop()
            local a = self:pop()
            self:push(a + b)
        elseif self:read_byte() == OP_SUB then
            self.pc = self.pc + 1
            local b = self:pop()
            local a = self:pop()
            self:push(a - b)
        elseif self:read_byte() == OP_DIV then
            self.pc = self.pc + 1
            local b = self:pop()
            local a = self:pop()
            self:push(a / b)
        elseif self:read_byte() == OP_MUL then
            self.pc = self.pc + 1
            local b = self:pop()
            local a = self:pop()
            self:push(a * b)
        elseif self:read_byte() == OP_NEG then
            self.pc = self.pc + 1
            local a = self:pop()
            self:push(-a)
        elseif self:read_byte() == OP_LD then
            self.pc = self.pc + 1
            local index = self:read_byte()
            self.pc = self.pc + 1
            self:push(self:get_constant(index))
        else
            return
        end
    end
    print("RESULT: " .. tostring(self:pop()))
end

return VM

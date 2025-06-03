local VM = {}
VM.__index = VM
setmetatable(VM, VM)

function VM:new(source)
    local obj = {}
    setmetatable(obj, self)

    obj.source = source or {}
    obj.codes = {}
    obj.constants = {}

    return obj
end

function VM:interpret()
    print("todo: VM:interpret()")
end

function VM:debug()
end

return VM

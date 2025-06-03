local vm = {}
vm.__index = vm
setmetatable(vm, vm)

function vm:new(source)
    local obj = {}
    setmetatable(obj, self)

    obj.source = source or {}
    obj.codes = {}
    obj.constants = {}

    return obj
end

function vm:interpret()
    print("todo: vm:interpret()")
end

function vm:debug()
end

return vm

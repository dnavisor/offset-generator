local config = {
    assembly = "Assembly-CSharp.dll",
    classes = {
        { namespace = nil, name = "BasePlayer" },
        { namespace = nil, name = "BaseNetworkable" }
    }
}

local function format_string(str)
    return str:gsub(">", "_"):gsub("<", "_"):gsub('(%S)(%u)', '%1_%2'):lower()
end

local function handle_image(image)
    local image_name = mono_image_get_name(image)

    if image_name == config.assembly then
        for _, class_info in ipairs(config.classes) do
            local class_namespace = class_info.namespace
            local class_name = class_info.name
            local class = mono_findClass(class_namespace or "", class_name)
            local fields = mono_class_enumFields(class)

            if class_namespace then
                print(string.format("namespace engine::%s::%s::offsets\n{", format_string(class_namespace), format_string(class_name)))
            else
                print(string.format("namespace engine::%s::offsets\n{", format_string(class_name)))
            end

            for _, field in ipairs(fields) do
                local offset_hex = string.format("%X", field.offset)
                print(string.format("    constexpr auto %s = 0x%s;", format_string(field.name), offset_hex))
            end

            print("}\n")
        end
    end
end

mono_enumImages(handle_image)

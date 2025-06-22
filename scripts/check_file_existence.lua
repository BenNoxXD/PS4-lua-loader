--[[
 *
 * Copyright (c) 2025 BenNox_XD
 *
 * This file is part of PS4-lua-loader and is licensed under the MIT License.
 * See the LICENSE file in the root of the project for full license information.
 *
]]
-- Based on the code from 0x1iii1ii: https://github.com/0x1iii1ii/ps4_autoLL/blob/4edb8d04b0721f0151edad0005f5f6ae0d938bc3/savedata/autoload.lua#L93-L143

autoload = {}
autoload.options = {
    autoload_hen= "payload.bin",
}

function file_exists(name)
    local f = io.open(name, "r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end
function file_read(filename)
    local file = io.open(filename, "rb")
    if not file then return nil end
    local content = file:read("*all")
    file:close()
    return content
end


function main()

    local existing_internal = "/data/payload.bin"
    local payload_paths = {}
    for usb = 0, 7 do
        table.insert(payload_paths, string.format("/mnt/usb%d/", usb))
    end

    local usb_path = nil
    for _, path in ipairs(payload_paths) do
        local full_path = path .. autoload.options.autoload_hen
        if file_exists(full_path) then
            usb_path = full_path
            break
        end
    end

    -- No USB payload AND no internal payload
    if not usb_path and not file_exists(existing_internal) then
        send_ps_notification("No payload found!\nExiting...")
        print("Payload not found!")
        return
    end

    -- No USB payload BUT internal payload exists
    if not usb_path and file_exists(existing_internal) then
        --print("No USB payload found. Using internal payload: " .. existing_internal)
        return
    end

    -- If USB and internal payloads are both available, check if they differ
    if file_exists(existing_internal) then
        local internal_data = file_read(existing_internal)
        local usb_data = file_read(usb_path)
        if internal_data and usb_data and internal_data == usb_data then
            send_ps_notification("Payload already up to date!")
            --print("Payload already up to date in /data/payload.bin")
            return
        end
    end

    -- Copy USB payload to internal
    local new_payload = file_read(usb_path)
    if not new_payload then
        print("Failed to read payload from: " .. usb_path)
        return
    end

    local dest_path = io.open(existing_internal, "wb")
    if not dest_path then
        print("Failed to open destination: " .. existing_internal)
        return
    end

    dest_path:write(new_payload)
    dest_path:close()

    send_ps_notification("Payload copied successfully!")
    --print("Payload copied successfully to /data/payload.bin")
end

main()

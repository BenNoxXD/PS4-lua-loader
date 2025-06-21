--[[
 *
 * Copyright (c) 2025 BenNox_XD
 *
 * This file is part of PS4-lua-loader and is licensed under the MIT License.
 * See the LICENSE file in the root of the project for full license information.
 *
]]

local path = "/data/payload.bin"

function main()
    local file = io.open(path, "r")
    if file then
        file:close()
        --print(path .. " exists")
    else
        print("HEN does not exist")
    end
end

main()
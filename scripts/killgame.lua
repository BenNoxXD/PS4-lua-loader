--[[
 *
 * Copyright (c) 2025 BenNox_XD
 *
 * This file is part of PS4-lua-loader and is licensed under the MIT License.
 * See the LICENSE file in the root of the project for full license information.
 *
]]

local SIGTERM = 15
local SIGKILL = 9

function main()

    local pid = syscall.getpid():tonumber()

    syscall.resolve({
        kill = 37,
    })

    printf("pid = %d", pid)

    local result = syscall.kill(pid, SIGTERM)
    print(string.format("Sent SIGTERM to game process (PID %d), syscall result: %s", pid, tostring(result)))

    if not result then
        local result_kill = syscall.kill(pid, SIGKILL)
        print(string.format("Sent SIGKILL to game process (PID %d), syscall result: %s", pid, tostring(result_kill)))
    end

end

main()

local config = require("config.app")
local cron = require("cron")
local log = require("log")
local process = require("process")

function porla.init()
    log.info("Checking availability of sqlite3")

    local sqlite3 = process.search_path("sqlite3")

    if #sqlite3 == 0 then
        log.warning("No sqlite3 binary found in path")
    else
        log.info("Found sqlite3 at " .. sqlite3)

        cron.schedule({
            -- run the backup at 03:30:30 every night

            expression = "30 30 3 * * *",
            callback   = function()
                local backup_file = os.date("%Y%m%d%H%M%S_porla.backup.sqlite")

                log.info("Performing database backup to " .. backup_file)

                process.launch({
                    file = sqlite3,
                    args = {
                        config.db_file,
                        string.format(".backup '%s'", backup_file)
                    },
                    done = function(exit_code, std_out, std_err)
                        if exit_code ~= 0 then
                            log.error("Failed to backup Porla database - " .. std_err)
                        end
                    end
                })
            end
        })
    end
end

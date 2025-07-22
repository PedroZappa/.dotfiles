-- Core
-- Global options
require("zedro.core.global")
-- Options
require("zedro.core.options")
-- Key Mappings
require("zedro.core.mappings")
-- Auto Commands
require("zedro.core.autocmd")
-- Macros
require("zedro.core.macros")

-- Lazy Plugin Manager
require("zedro.lazy")

require("strudel-integration").setup()

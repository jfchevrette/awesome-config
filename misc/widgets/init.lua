local wrequire     = require("lain.helpers").wrequire
local setmetatable = setmetatable

local widgets = { _NAME = "misc.widgets" }

return setmetatable(widgets, { __index = wrequire })

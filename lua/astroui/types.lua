---@meta

---@alias AstroUIIconHighlight (fun(self:table):boolean)|boolean
---@alias AstroUIIconTable table<string,string>

---@class AstroUIFullIconHighlights
---@field tabline AstroUIIconHighlight?
---@field statusline AstroUIIconHighlight?
---@field winbar AstroUIIconHighlight?

---@class AstroUIIconHighlights
---@field breadcrumbs AstroUIIconHighlight?
---@field file_icon AstroUIFullIconHighlights?

---@class AstroUIStatusOpts
---@field attributes table<string,table>?
---@field buf_matchers table<string,fun(pattern_list:string[],bufnr:integer):boolean>?
---@field colors table<string,string>?
---@field fallback_colors table<string,string>?
---@field icon_hignlights AstroUIIconHighlights?
---@field modes table<string,string[]>?
---@field separators table<string,string[]|string>?
---@field setup_colors (fun():table)?
---@field sign_handlers table<string,fun(args:table)>?

---@class AstroUIConfig
---@field colorscheme string?
---@field highlights table<string,table<string,table>>?
---@field icons AstroUIIconTable?
---@field text_icons AstroUIIconTable?
---@field status AstroUIStatusOpts?

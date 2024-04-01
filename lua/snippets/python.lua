local ls = require("luasnip")
local s = ls.snippet
local i = ls.insert_node
local t = ls.text_node
local c = ls.choice_node
local sn = ls.snippet_node
local fmta = require("luasnip.extras.fmt").fmta

local newline = t({ "", "" })
local altitem = function(name, channel, class)
  return s(name, {
    t(channel .. "=alt." .. class .. '("'),
    i(1),
    t('"'),
    c(2, {
      t(""),
      sn(nil, {
        i(1),
        t(', type="'),
        c(2, { t("quantitative"), t("nominal"), t("temporal"), t("ordinal") }),
        t('"'),
      }),
    }),
    t("),"),
  })
end

return {
  s("ac", {
    t("alt.Chart("),
    i(1, "df"),
    t(").mark_"),
    c(2, { t("bar"), t("circle"), t("line") }),
    t("().encode("),
    newline,
    t("    "),
    i(3),
    newline,
    t(")"),
  }),
  altitem("acx", "x", "X"),
  altitem("acy", "y", "Y"),
  altitem("acx2", "x2", "X"),
  altitem("acy2", "y2", "Y2"),
  altitem("acc", "colour", "Colour"),
  altitem("acf", "fill", "Fill"),
  altitem("acs", "size", "Size"),
  altitem("act", "text", "Text"),
  altitem("actt", "tooltip", "Tooltip"),
  altitem("acfr", "row", "Row"),
  altitem("acfc", "column", "Column"),
  -- s("ax", {
  --   t('    x=alt.X("'),
  --   i(3),
  --   t('"'),
  --   c(4, {
  --     t(""),
  --     sn(nil, {
  --       i(1),
  --       t(', type="'),
  --       c(2, { t("quantitative"), t("nominal"), t("temporal"), t("ordinal") }),
  --       t('"'),
  --     }),
  --   }),
  --   t("),"),
  -- }),
  -- s("ay", {
  --   t('    y=alt.Y("'),
  --   i(3),
  --   t('"'),
  --   c(4, {
  --     t(""),
  --     sn(nil, {
  --       i(1),
  --       t(', type="'),
  --       c(2, { t("quantitative"), t("nominal"), t("temporal"), t("ordinal") }),
  --       t('"'),
  --     }),
  --   }),
  --   t("),"),
  -- }),
}

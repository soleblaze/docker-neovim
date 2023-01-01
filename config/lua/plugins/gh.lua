return {
  "ldelossa/gh.nvim",
  dependencies = { "ldelossa/litee.nvim" },
  config = function()
    require('litee.lib').setup({
      icon_set = "nerd",
      panel = {
        orientation = "right",
      },
      term = {
        position = "bottom"
      }
    })
    require('litee.gh').setup({
      icon_set = "nerd",
      map_resize_keys = true
    })
  end,
}

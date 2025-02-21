local M = {}

function M.add_boxed_comment()
  -- Detect the file type
  local filetype = vim.bo.filetype
  local comment_start, comment_end, fill_char

  -- Determine comment style and fill character based on file type
  if filetype == "make" or filetype == "sh" then
    comment_start = "# "
    comment_end = " #"
    fill_char = "*"
  elseif filetype == "c" or filetype == "cpp" or filetype == "h" then
    comment_start = "/* "
    comment_end = " */"
    fill_char = "*"
  elseif filetype == "py" then
    comment_start = "# "
    comment_end = " #"
    fill_char = "*"
  elseif filetype == "lua" then
    comment_start = "-- "
    comment_end = " --"
    fill_char = "-"
  elseif filetype == "conf" then
    comment_start = "# "
    comment_end = "# "
    fill_char = "-"
  else
    comment_start = "// "
    comment_end = " //"
    fill_char = "*"
    vim.notify("File type ** filetype ** is not configured. Using '//' style. Add your preferences to commenter plugin",
      vim.log.levels.WARN)
  end

  -- Ask the user for input
  vim.ui.input({ prompt = "Enter comment: " }, function(input)
    if input == nil or input == "" then return end

    -- Define box parameters
    local box_width = 80
    local content_width = box_width - #comment_start - #comment_end
    local padding_width = math.floor((content_width - #input) / 2)

    -- Adjust for odd padding to keep it centered
    local left_padding = padding_width
    local right_padding = content_width - #input - left_padding

    -- Construct the comment box
    local comment_lines = {
      comment_start .. string.rep(fill_char, content_width) .. comment_end,
      -- comment_start .. string.rep(" ", content_width) .. comment_end,
      comment_start .. string.rep(" ", left_padding) .. input .. string.rep(" ", right_padding) .. comment_end,
      -- comment_start .. string.rep(" ", content_width) .. comment_end,
      comment_start .. string.rep(fill_char, content_width) .. comment_end,
    }

    -- Insert the comment box into the buffer
    vim.api.nvim_buf_set_lines(0, vim.fn.line(".") - 1, vim.fn.line("."), false, comment_lines)
  end)
end

return M

-- TODO not really efficient to run the shell command every refresh of the statusline...
local function GitBranch()
    local branch = ""
    if vim.api.nvim_buf_get_option(vim.current_buffer, 'modifiable') then
        vim.cmd('lcd %:p:h')
        temp = syscmd('git rev-parse --abbrev-ref HEAD')
        vim.cmd('lcd -')
        if temp ~= 'fatal: no git repository' then
            branch = temp:gsub("\n", "")
        end
    end
    if branch ~= "" then
        return "[" .. branch .. "]"
    end
    return ""
end

local function WordCount()
    if vim.api.nvim_buf_get_option(vim.current_buffer, 'filetype') ~= "markdown" then
        return ""
    end
    words = vim.fn.wordcount().words
    if vim.fn.wordcount().visual_words then
        words = vim.fn.wordcount().visual_words
    end
    return " | " .. words .. " words"
end

local function CharCount()
    if vim.api.nvim_buf_get_option(vim.current_buffer, 'filetype') ~= "markdown" then
        return ""
    end
    chars = vim.fn.wordcount().chars
    if vim.fn.wordcount().visual_chars then
        chars = vim.fn.wordcount().visual_chars
    end
    return " | " .. chars .. " chars"
end

function ModeColor(mode)
    if mode == "i" then
        vim.cmd("hi ModeMsg ctermfg=red ctermbg=NONE cterm=bold")
    elseif mode == "r" then
        vim.cmd("hi ModeMsg ctermfg=magenta ctermbg=NONE cterm=bold")
    else
        vim.cmd("hi ModeMsg ctermfg=yellow ctermbg=NONE cterm=bold")
    end
end

-- TODO call to the different function seems to be cached... and not reloaded when needed
function StatusLine()
    return table.concat {
        "%#Visual#",
        "%r", --Readonly flat
        "%#DiffChange#",
        " %t",
        "%#Visual#",
        " %m",
        "%#TabLineFill#",
        " %=",
        GitBranch(),
        " %l/%L %p%%",
        WordCount(),
        CharCount(),
        " | Buf %n"
    }
end

vim.o.statusline = StatusLine()

vim.cmd([[
augroup Mode
    autocmd!
    au InsertEnter * lua ModeColor(vim.api.nvim_eval('v:insertmode'))
    au InsertLeave * hi ModeMsg ctermfg=yellow ctermbg=NONE cterm=bold
    au WinEnter,BufEnter * lua vim.o.statusline = StatusLine()
    au WinLeave,BufLeave * lua vim.o.statusline = StatusLine()
augroup END
]])
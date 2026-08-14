-- Pull in the wezterm API
local wezterm = require 'wezterm'
local mux = wezterm.mux

-- This will hold the configuration.
local config = wezterm.config_builder()
local act = wezterm.action

-- Session persistence: save/restore windows, tabs and panes across restarts.
-- First load git-clones the plugin, so it needs network and may briefly block.
local resurrect = wezterm.plugin.require 'https://github.com/StephenGemin/resurrect.wezterm'

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'nord'
-- config.window_background_gradient = {
--   orientation = { Linear = { angle = 225.0 } },
--   colors = { '#2e3440', '#2e3440', '#323844', '#2e3440', '#2e3440' },
--   interpolation = 'Linear',
--   blend = 'Rgb',
-- }
-- Explicit chain: CoreText's automatic fallback missed the installed CJK fonts.
config.font = wezterm.font_with_fallback {
  'Fira Code Retina',           -- primary; ligatures, Latin only
  'JetBrains Mono',             -- WezTerm builtin; ligatures, Latin/symbol gaps
  'Hiragino Sans GB',           -- Simplified Chinese
  'Hiragino Kaku Gothic ProN',  -- Japanese kana + halfwidth forms
  'Apple SD Gothic Neo',        -- Korean
  'Arial Unicode MS',           -- last: broad coverage, no ligatures
}
-- Respect emoji/text presentation selectors (e.g. VS16 U+FE0F) so that
-- dual-presentation glyphs like the info icon (U+2139 + U+FE0F, "info")
-- render as full-size color emoji instead of a tiny monochrome text glyph
-- that FiraCode provides at 1-cell width. Requires unicode_version >= 14.
config.unicode_version = 14
config.use_fancy_tab_bar = false
config.tab_max_width = 32
config.colors = {
  split = '#88c0d0',
  visual_bell = '#88c0d0',
  scrollbar_thumb = '#4c566a',
  tab_bar = {
    active_tab = {
      fg_color = '#073642',
      bg_color = '#2aa198',
    },
    inactive_tab = {
      fg_color = '#d8dee9',
      bg_color = '#3b4252',
    },
    inactive_tab_hover = {
      fg_color = '#eceff4',
      bg_color = '#4c566a',
    },
    new_tab = {
      fg_color = '#d8dee9',
      bg_color = '#2e3440',
    },
    new_tab_hover = {
      fg_color = '#eceff4',
      bg_color = '#4c566a',
    },
  },
}
config.hide_tab_bar_if_only_one_tab = true
config.default_cursor_style = 'BlinkingBar'
config.window_decorations = 'RESIZE'
config.freetype_load_target = 'Light'
config.freetype_render_target = 'HorizontalLcd'
-- config.window_background_opacity = 0.95
-- config.macos_window_background_blur = 20
config.enable_scroll_bar = true
config.visual_bell = {
  fade_in_duration_ms = 75,
  fade_out_duration_ms = 75,
  target = 'BackgroundColor',
}
config.switch_to_last_active_tab_when_closing_tab = true
config.unix_domains = {
  {
    name = 'unix',
  },
}
config.inactive_pane_hsb = {
  saturation = 0.8,
  brightness = 0.6,
}


config.scrollback_lines = 5000

-- I don't really have need for padding between panes
config.window_padding = {
  left = 0,
  right = 0,
  top = 0,
  bottom = 0,
}

config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }
config.keys = {
  -- Clear scrollback
  {
    key = 'k',
    mods = 'CMD',
    action = act.ClearScrollback 'ScrollbackAndViewport',
  },
  -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
  {
    key = 'LeftArrow',
    mods = 'OPT',
    action = act.SendString '\x1bb',
  },
  -- Make Option-Right equivalent to Alt-f; forward-word
  {
    key = 'RightArrow',
    mods = 'OPT',
    action = act.SendString '\x1bf',
  },
  -- Change tab name
  {
    key = ',',
    mods = 'LEADER',
    action = act.PromptInputLine {
      description = 'Enter new name for tab',
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:active_tab():set_title(line)
        end
      end),
    },
  },
  -- Show all tabs
  {
    key = 'w',
    mods = 'LEADER',
    action = act.ShowTabNavigator,
  },
  -- Scroll tab as text
  {
    key = '[',
    mods = 'LEADER',
    action = act.ActivateCopyMode,
  },
  -- Switch tab left
  {
    key = 'n',
    mods = 'LEADER',
    action = act.ActivateTabRelative(1),
  },
  -- Switch tab right
  {
    key = 'p',
    mods = 'LEADER',
    action = act.ActivateTabRelative(-1),
  },
  -- Vertical split
  {
    -- |
    key = '|',
    mods = 'LEADER|SHIFT',
    action = act.SplitPane {
      direction = 'Right',
      size = { Percent = 50 },
    },
  },
  -- Horizontal split
  {
    -- -
    key = '-',
    mods = 'LEADER',
    action = act.SplitPane {
      direction = 'Down',
      size = { Percent = 50 },
    },
  },
  -- Zoom in on a page
  {
    key = 'f',
    mods = 'LEADER',
    action = wezterm.action.TogglePaneZoomState,
  },
  -- Create new tab
  {
    key = 'c',
    mods = 'LEADER',
    action = act.SpawnTab 'CurrentPaneDomain',
  },
  -- CTRL + (h,j,k,l) to move between panes.
  -- The handlers below are process-aware: when the foreground program needs
  -- these keys itself (Helix, vim, less, TUIs), the keystroke is passed
  -- through instead of navigating panes. This returns Ctrl+h (Helix
  -- backspace), Ctrl+j (newline), etc. to the editor while keeping pane
  -- navigation in shells. (Kept on CTRL so Cmd+K clear-scrollback is unaffected.)
  {
      key = 'h',
      mods = 'CTRL',
      action = act({ EmitEvent = "move-left" }),
  },
  {
      key = 'j',
      mods = 'CTRL',
      action = act({ EmitEvent = "move-down" }),
  },
  {
      key = 'k',
      mods = 'CTRL',
      action = act({ EmitEvent = "move-up" }),
  },
  {
      key = 'l',
      mods = 'CTRL',
      action = act({ EmitEvent = "move-right" }),
  },
  -- ALT + (h,j,k,l) to resize panes
  {
      key = 'h',
      mods = 'ALT',
      action = act({ EmitEvent = "resize-left" }),
  },
  {
      key = 'j',
      mods = 'ALT',
      action = act({ EmitEvent = "resize-down" }),
  },
  {
      key = 'k',
      mods = 'ALT',
      action = act({ EmitEvent = "resize-up" }),
  },
  {
      key = 'l',
      mods = 'ALT',
      action = act({ EmitEvent = "resize-right" }),
  },
  -- Close/kill active pane
  {
      key = 'x',
      mods = 'LEADER',
      action = act.CloseCurrentPane { confirm = true },
  },
  --  Switch to previous pane
  {
    key = ';',
    mods = 'LEADER',
    action = act.ActivatePaneDirection('Prev'),
  },
  -- Switch to next pane
  {
    key = 'o',
    mods = 'LEADER',
    action = act.ActivatePaneDirection('Next'),
  },
  -- Attach to muxer
  {
    key = 'a',
    mods = 'LEADER',
    action = act.AttachDomain 'unix',
  },
  -- Detach from muxer
  {
    key = 'd',
    mods = 'LEADER',
    action = act.DetachDomain { DomainName = 'unix' },
  },
  -- Rename current session; analagous to command in tmux
  {
    key = '$',
    mods = 'LEADER',
    action = act.PromptInputLine {
      description = 'Enter new name for session',
      action = wezterm.action_callback(
        function(window, pane, line)
          if line then
            mux.rename_workspace(
              window:mux_window():get_workspace(),
              line
            )
          end
        end
      ),
    },
  },
  -- Show list of workspaces
  {
    key = 's',
    mods = 'LEADER',
    action = act.ShowLauncherArgs { flags = 'WORKSPACES' },
  },
}

wezterm.on('format-tab-title', function(tab, tabs, panes, config, hover, max_width)
  local title = tab.tab_title
  -- If no custom title set, use current directory name
  if not title or #title == 0 then
    local cwd = tab.active_pane.current_working_dir
    if cwd then
      title = cwd.file_path:match("([^/]+)/?$") or cwd.file_path
    else
      title = tab.active_pane.title
    end
  end

  -- Truncate long titles
  local max_title = max_width - 4 -- account for index prefix and separator
  if #title > max_title and #title > 12 then
    title = title:sub(1, max_title - 1) .. '…'
  end

  -- Per-tab colors based on tab index or title
  local bg_color = '#3b4252'
  local fg_color = '#8896a8'
  
  if tab.is_active then
    bg_color = '#2aa198'
    fg_color = '#073642'
  elseif hover then
    bg_color = '#4c566a'
    fg_color = '#eceff4'
  end

  if tab.is_active then
    return {
      { Background = { Color = '#2e3440' } },
      { Foreground = { Color = '#ffffff' } },
      { Text = '⋮' },
      { Background = { Color = bg_color } },
      { Foreground = { Color = fg_color } },
      { Attribute = { Intensity = 'Bold' } },
      { Text = (tab.tab_index + 1) .. '|' .. title },
    }
  end

  return {
    { Background = { Color = '#2e3440' } },
    { Foreground = { Color = '#4c566a' } },
    { Text = '⋮' },
    { Background = { Color = bg_color } },
    { Foreground = { Color = fg_color } },
    { Attribute = { Intensity = 'Bold' } },
    { Text = (tab.tab_index + 1) .. '|' .. title },
  }
end)

-- Pane navigation handlers (process-aware).
-- If the pane's foreground program is one that needs Ctrl+h/j/k/l for itself,
-- forward the keystroke to it; otherwise use the key to switch panes.
-- Note: get_foreground_process_name() may return nil for remote/mux panes;
-- in that case we fall through to pane navigation.
local passthrough_procs = {
  ['hx'] = true, ['nvim'] = true, ['vim'] = true, ['vi'] = true,
  ['less'] = true, ['more'] = true, ['man'] = true, ['nano'] = true,
  ['fzf'] = true, ['sk'] = true, ['btop'] = true, ['htop'] = true,
  ['gitui'] = true, ['lazygit'] = true, ['bat'] = true, ['emacs'] = true,
}

local function nav_or_passthrough(window, pane, direction, key)
  local proc = pane:get_foreground_process_name()
  if proc then
    proc = proc:gsub('.*[/\\]', '') -- basename
    if passthrough_procs[proc] then
      window:perform_action(act.SendKey { key = key, mods = 'CTRL' }, pane)
      return
    end
  end
  window:perform_action(act.ActivatePaneDirection(direction), pane)
end

wezterm.on('move-left', function(window, pane)
  nav_or_passthrough(window, pane, 'Left', 'h')
end)

wezterm.on('move-down', function(window, pane)
  nav_or_passthrough(window, pane, 'Down', 'j')
end)

wezterm.on('move-up', function(window, pane)
  nav_or_passthrough(window, pane, 'Up', 'k')
end)

wezterm.on('move-right', function(window, pane)
  nav_or_passthrough(window, pane, 'Right', 'l')
end)

-- Pane resize handlers
wezterm.on('resize-left', function(window, pane)
  window:perform_action(act.AdjustPaneSize({'Left', 5}), pane)
end)

wezterm.on('resize-down', function(window, pane)
  window:perform_action(act.AdjustPaneSize({'Down', 5}), pane)
end)

wezterm.on('resize-up', function(window, pane)
  window:perform_action(act.AdjustPaneSize({'Up', 5}), pane)
end)

wezterm.on('resize-right', function(window, pane)
  window:perform_action(act.AdjustPaneSize({'Right', 5}), pane)
end)

-- Session persistence, wired manually instead of via resurrect.setup().
-- setup() unconditionally registers event_driven_save (which hooks
-- pane-focus-changed + window-focus-changed) and periodic_save, with no opt-out.
-- That serialized the whole multi-MB state on every pane switch and every
-- alt-tab. Below: NO periodic save, NO focus/pane-driven save. State is written
-- only on an explicit quit (Cmd+Q) or a manual save (Alt+W).

-- Restore the last saved workspace on startup.
wezterm.on('gui-startup', resurrect.state_manager.resurrect_on_gui_startup)

-- Cap saved scrollback per pane; keeps the state file small and saves fast.
resurrect.state_manager.set_max_nlines(1000)

-- Relaunch these on restore (added to the built-in vim/nvim/less/... allowlist).
resurrect.pane_tree.add_safe_restore_processes { 'hx', 'btop', 'gitui' }

local function save_session(window)
  resurrect.state_manager.save_state(resurrect.workspace_state.get_workspace_state())
  if window then
    resurrect.state_manager.save_state(resurrect.window_state.get_window_state(window:mux_window()))
  end
end

-- Save once on exit: intercept Cmd+Q so state is written, then quit.
table.insert(config.keys, {
  key = 'q',
  mods = 'CMD',
  action = wezterm.action_callback(function(window, pane)
    save_session(window)
    window:perform_action(act.QuitApplication, pane)
  end),
})

-- Manual save / restore / delete.
table.insert(config.keys, {
  key = 'w',
  mods = 'ALT',
  action = wezterm.action_callback(function(window, _pane)
    save_session(window)
  end),
})
table.insert(config.keys, {
  key = 'r',
  mods = 'ALT',
  action = resurrect.fuzzy_loader.restore_action(),
})
table.insert(config.keys, {
  key = 'd',
  mods = 'ALT',
  action = resurrect.fuzzy_loader.delete_action(),
})

-- and finally, return the configuration to wezterm
return config

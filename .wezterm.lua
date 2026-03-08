-- Pull in the wezterm API
local wezterm = require 'wezterm'
local mux = wezterm.mux

-- This will hold the configuration.
local config = wezterm.config_builder()
local act = wezterm.action

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'nord'
config.font = wezterm.font 'Fira Code Retina'
config.use_fancy_tab_bar = false
config.tab_max_width = 32
config.colors = {
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
config.switch_to_last_active_tab_when_closing_tab = true
config.unix_domains = {
  {
    name = 'unix',
  },
}
config.pane_focus_follows_mouse = true
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
  -- Ensure Ctrl+D is passed through (for EOF/scrolling)
  {
    key = "d",
    mods = "CTRL",
    action = act.SendKey { key = "d", mods = "CTRL" },
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
  -- CTRL + (h,j,k,l) to move between panes
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

  -- Per-tab colors based on tab index or title
  local bg_color = '#3b4252'
  local fg_color = '#d8dee9'
  
  if tab.is_active then
    bg_color = '#2aa198'
    fg_color = '#073642'
  elseif hover then
    bg_color = '#4c566a'
    fg_color = '#eceff4'
  end

  return {
    { Background = { Color = bg_color } },
    { Foreground = { Color = fg_color } },
    { Attribute = { Intensity = 'Bold' } },
    { Text = (tab.tab_index + 1) .. '|' .. title },
    { Background = { Color = '#2e3440' } },
    { Foreground = { Color = '#4c566a' } },
    { Text = '⋮' },
  }
end)

-- Pane navigation handlers
wezterm.on('move-left', function(window, pane)
  window:perform_action(act.ActivatePaneDirection('Left'), pane)
end)

wezterm.on('move-down', function(window, pane)
  window:perform_action(act.ActivatePaneDirection('Down'), pane)
end)

wezterm.on('move-up', function(window, pane)
  window:perform_action(act.ActivatePaneDirection('Up'), pane)
end)

wezterm.on('move-right', function(window, pane)
  window:perform_action(act.ActivatePaneDirection('Right'), pane)
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

-- and finally, return the configuration to wezterm
return config

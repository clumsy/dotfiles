-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()
local act = wezterm.action

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'nord'
config.font = wezterm.font 'Fira Code Retina'
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
  -- Map Ctrl+W to delete the current word
  {
    key = "w",
    mods = "CTRL",
    action = act.SendString '\x17',
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
    mods = 'LEADER|SHIFT',
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

wezterm.on('format-tab-title', function(tab)
  -- Prefer tab_title if set, otherwise fall back to the pane title
  local title = tab.tab_title
  if title and #title > 0 then
    return { { Text = ' ' .. title .. ' ' } }
  end
  return { { Text = ' ' .. tab.active_pane.title .. ' ' } }
end)

-- and finally, return the configuration to wezterm
return config

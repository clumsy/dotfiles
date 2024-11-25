-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'nord'
config.font = wezterm.font 'Fira Code Retina'

local act = wezterm.action
config.keys = {
-- Map Ctrl+W to delete the current word
  {
    key = "w",
    mods = "CTRL",
    action = wezterm.action.SendString '\x17',
  },
-- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
  {
    key = 'LeftArrow',
    mods = 'OPT',
    action = wezterm.action.SendString '\x1bb',
  },
-- Make Option-Right equivalent to Alt-f; forward-word
  {
    key = 'RightArrow',
    mods = 'OPT',
    action = wezterm.action.SendString '\x1bf',
  },
-- Change tab name
  {
    key = 'E',
    mods = 'CTRL|SHIFT',
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
-- close split pane
  --{key="c", mods="CTRL|SHIFT", action=wezterm.action.CloseCurrentPane},
}

-- and finally, return the configuration to wezterm
return config

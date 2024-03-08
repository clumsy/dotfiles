-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

-- This is where you actually apply your config choices

-- For example, changing the color scheme:
config.color_scheme = 'nord'
config.font = wezterm.font 'Fira Code Retina'
config.keys = {
  {
    key = 'LeftArrow',
    mods = 'OPT',
    action = wezterm.action.SendString '\x1bb',
  },
  {
    key = 'RightArrow',
    mods = 'OPT',
    action = wezterm.action.SendString '\x1bf',
  },
}

-- and finally, return the configuration to wezterm
return config

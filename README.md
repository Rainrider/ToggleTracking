# ToggleTracking

## Features
  - Hides tracked quests and achievements during boss encounters and restores them afterwards
  - Supports 5-man instances and raids
  - Does not hide super tracked (e.g. dungeon progress) and zone-in quests
  - Slash commands for (un)tracking - `/ttrack track` (or `/toggletracking track`), `/ttrack untrack` (or `/toggletracking untrack`)

## Limitations:
  - Due to how the API provides information about encounter start in 5-man instances there is a problem detecting a boss fight if the boss was pulled during combat. A possible workaround is beeing tested.
  - If you make progress on a certain quest during a boss encounter and have "Automatic quest tracking" toggled on, than the quest will re-appear.

## Planned:
  - Options
  - Automatic tracking of incompleted encounter or zone achievements
  

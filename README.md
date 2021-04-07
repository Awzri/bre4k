# bre4k
A 4K rhythm game that breaks the rules

## About

TODO: Add proper About section.

probably won't get done ngl

ig this is a moddable 4k rhythm game built in love2d

best engine 10/10 but idk how to do it any different

## "Installing"
The game can easily be "installed" by doing the following.

Dependencies:
- [love2d](https://love2d.org)

To run the game, simply clone the repo, and run the *folder* (**NOT** main.lua) with love.
```
git clone https://github.com/NullCat/bre4k.git
love bre4k
```

For the game to run, you will need a `song.lua` file in the root directory.
Rename/copy `song-default.lua` and modify it to get the song you want.
Editor is coming soon™

Binaries won't exist until the game is playable.

## Mapping
You can create maps manually (please dont) or you can convert .sm Stepmania maps into song.lua files.

You can do this by using the sm-convert.lua file.
`lua sm-convert.lua song.sm`
Please not the converter was made with Lua 5.4. Older/newer versions may not work.

**! CONVERTER CURRENTLY CANNOT HANDLE !**
- Irregular Measures (Can be done manually)
- Maps with multiple difficulties (Remove other difficulties before converting)

*Please don't create an issue for any of those. They'll be in the converter/game eventually.*

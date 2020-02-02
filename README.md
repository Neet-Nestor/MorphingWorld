# MorphingWorld

A game inspired by winner game World Collector on Ludum Dare 45.

## Install dependencies

To build this project, you need to first download [Haxe](https://haxe.org/).

Then, install the latest stable version of HaxeFlixel:

```bash
haxelib install lime
haxelib install openfl
haxelib install flixel
```

After the installation is complete, you can compile games to HTML5, Flash and Neko out of the box.
To easily install additional libraries (addons, ui, demos, tools, templates...) in a single step, just run:

```bash
haxelib run lime setup flixel
```

You can run this command to make `lime` vailable as a command (alias for `haxelib run lime`).

```bash
haxelib run lime setup
```

Run the following two commands to install [flixel-tools](http://haxeflixel.com/documentation/flixel-tools/) (needed for project templates among other things):

```bash
haxelib install flixel-tools
haxelib run flixel-tools setup
```

## Test

```bash
lime test windows
lime test mac
lime test linux
lime test neko
lime test html5
lime test flash
lime test ios
lime test android
lime test air
```

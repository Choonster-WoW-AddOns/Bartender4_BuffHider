## 1.03
- Update to Battle for Azeroth/Classic
- Fix `SpellEditBox` strata issues
- Add debug messages
- Add readme and changelog
- Update library URLs in .pkgmeta
- Add .travis.yml file and TOC properties for the BigWigs packager script
	- https://www.wowinterface.com/forums/showthread.php?t=55801

## 1.02
- No changes

## 1.01
- Add custom `SpellEditBox` widget for auras
	- Known issue: EditBoxes may get stuck on `MEDIUM` strata when the options frame is on `HIGH`. To solve this, select another bar option and then select the original bar option.
- Update shown states when user changes a setting in the GUI
- Allow the user to shift-click spell links into the aura inputs
	- Spell links are replaced with spell names when the Okay button is clicked
- Add missing type field for invert options
- Make slash command call `InterfaceOptionsFrame_OpenToCategory` twice on first use so the category is opened properly
- Update TOC Notes field to reflect new functionality
- Explicitly check if each bar has an aura before updating its shown state
- Correctly pass `DB` to `ns.InitOptions`
- Add config GUI and allow every bar to be controlled

## 1.00
- AddOn created
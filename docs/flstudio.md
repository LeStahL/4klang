# Using Sointu with FL Studio

To write a Sointu track using FL studio that a coder can include into a 4k intro, several things need to be kept in mind. This document aims at covering these.

## Project setup

Before writing a track, you need to set up FL Studio correctly to be able to work with Sointu. The following steps are necessary:

### Add the plugin to FL Studio

* Choose `Options` -> `Manage Plugins` from the main menu.
* Add the folder you extracted Sointu in to the `Plugin search paths`.
* Click `Find installed plugins`. The plugin list on the right of the dialog should now contain `Sointu` and `Sointu Native`.

### Remove the fruity limiter from the master channel 

* FL Studio has a `Fruity Limiter` on the master chanel by default. Remove it by selecting the master channel in the mixer, then clicking the small arrow next to the fruity limiter. In the dropdown menu that opens, choose `delete`.

### Add Sointu to the channel rack and configure

* Open the channel rack and click `+`. Choose `Sointu Native`, if you want to be able to export your track to a 4k intro.
* Click the `Sointu Native` channel, then click the gear icon in its title bar. A toolbar opens. Click the icon with gear and plug.
* In `MIDI` section in the lower left corner, select an output port.

### Remove default instruments from the channel rack

* Right-click all the default 808 channels in the channel rack and choose `delete`.

### Add instrument channels

* For each instrument in Sointu, add one `MIDI Out` channel to the channel rack.
* Configure those instruments to use the MIDI port you configured Sointu to use by clicking the channel in the channel rack, then the gear icon in its title bar, and the plug icon on the toolbar that opens then.
* Configure the instrument to use MIDI channels in the same order the instruments have in the Sointu plugin.

### Save the project

* Save the Sointu track YAML file using `File` -> `Save Song As...` from the plugin UI.
* Save the FL Studio project file using `File` -> `Save As...`. Disable the `Create new project folder` radio button.

## Write the track

You can now write the track, using only the piano roll and no automations.

* Make sure to save both the YAML and the FL Studio project when saving.
* Using some kind of version control on both the YAML and the FL Studio project is a good idea.

## Record the track for a 4k intro

To get the notes of your track into the YAML file, use the `record` feature in Sointu.

* Press the record button in the Sointu UI.
* Reset playback in FL Studio and play the track once. Make sure that playback does not loop immediately after playing the track; You can do this by adding a pattern after a long pause at the end of the track.
* Open the Sointu tracker while the playback is running.
* After the playback finishes, stop recording. Note that any and all silence and fade-out that you allow to pass before pressing the record button again will be added to the end of the track.
* Save the YAML file.

Congratulations! You can now send your track YAML file to the coder.

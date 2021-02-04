# MIDIHero
### MIDIHero is an iOS application that connects to a GuitarHero® Bluetooth Low Energy controller, and converts the controller events into General MIDI 1.0 messages.

## Project History

| Date          | Description                                                                                                                    |
|:------------- | ------------------------------------------------------------------------------------------------------------------------------:|
| July 2018     | Project was created as a university assignment. This version is targeted at iPhone and iPad, running iOS 11/12.                |
| January 2021  | Project is updated to target iOS 14 and SwiftUI. This is a completely rewritten version of MIDIHero using SwiftUI (iOS 14 Only)|

## About
MIDIHero was conceptualised as an assignment project for a university module called Sensing Systems. The module focused on embedded systems and microcontroller/hardware interconnectiviry.
For the module's final project, we had to create some embedded system, which could accept commands from a mobile phone application.
MIDIHero was presented as a project that documented my reverse engineering attempt into utilising an undocumented bluetooth accessory for a purpose other than it's untended use.
The grade was good and the project was a success.

## What and Why
MIDIHero acts as a bluetooth host for a standard GuitarHero® Bluetooth Low Energy controller - bleGuitar - and transmits MIDI 1.0 messages in response to hardware controller changes.  
The guitar exposes a bluetooth characteristic which can periodically notify the host of new or updated data.
The data from the guitar can be decoded into physical controller events, for example `fret_0_pressed`.  
These events are then used to trigger the transmission of General MIDI 1.0 messages to a given MIDI Destination.  

The project was the least boring idea that I came up with for the university assignment.

## TODO:
There's a lot left to do in the overhauled version, as not all features from the old version have been reimplemented.
* SwiftUI interface for controlling application functionality.
* Pitch Bend, Modulation, and Controller Change messages have been tested, but need implemented.
* I plan to completely restructure the method in which controller events are transcoded to midi events as the current method is clunky.
* Update livery and naming to something less trademark infringing.

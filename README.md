# animated-set
Stanford CS193P Developing Application for iOS Fall 2017-18 Assignment 4

This is an app version of the card game called Set, as well as the game Concentration. It is my project for Stanford CS193P assignment 4.

It builds on Assignment 3 by including animation and by including a previously made Concentration game by implementing multiple MVCs.

The only external tool I'm using is the Grid utility created by the instructor (see Grid.swift).

## Known Issues

If a mixed splitview device is rotated from landscape to portrait while a Concentration game is being played, the game goes back to the theme chooser screen.

## Possible Improvements

Handling Set game animation in the SetViewController instead of the CardGridView would allow for less delegation.
As is, I have to get UI location info from the SetViewController to the CardGridView, converting coordinates. I also have to get the superview itself.

If I handled animation in the superview I would need less code and less confusing delegation.

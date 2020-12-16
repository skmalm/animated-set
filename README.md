# animated-set
Assignment project for Stanford CS193P: Developing Applications for iOS.

This is an app version of the card game called Set, as well as the game Concentration.

It builds on Assignment 3 by including animation and by including a previously made Concentration game by implementing multiple MVCs.

The only external tool I'm using is the Grid utility created by the instructor (see Grid.swift).

## Known Issues

Rotating the device during Set animation breaks the Set game (probably need to override viewWillTransition to fix this).

If a mixed splitview device is rotated from landscape to portrait while a Concentration game is being played, the game goes back to the theme chooser screen.

## Possible Improvements

Handling Set game animation in the SetViewController instead of the CardGridView would allow for less delegation.
As is, I have to get UI location info from the SetViewController to the CardGridView, converting coordinates. I also have to get the superview itself.

If I handled animation in the superview I would need less code and less confusing delegation.

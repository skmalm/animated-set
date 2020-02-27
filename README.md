# animated-set
Stanford CS193P Developing Application for iOS Fall 2017-18 Assignment 4

This is an app version of the card game called Set, as well as the game Concentration. It is my project for Stanford CS193P assignment 4.

It builds on Assignment 3 by including animation and by including a previously made Concentration game by implementing multiple MVCs.

The only external tool I'm using is the Grid utility created by the instructor (see Grid.swift).

# Issues

It would be better to manage all of the animation from within the SetViewController rather than the CardGridView; this way I wouldn't need the CardGridView to access the VC, breaking MVC somewhat.

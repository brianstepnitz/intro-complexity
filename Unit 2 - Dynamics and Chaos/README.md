## WHAT IS IT?

A population of "turtles" roam their environment looking for food "pellets" that randomly show up but in a constant amount. Various parameters for the turtles and environment can be set. When a turtle eats enough food, it produces a new turtle by "budding". Turtles may "die" of either old age, or not finding enough food. The result is an Agent-Based Model that seems to somewhat realistically almost show a [Logistic map](https://en.wikipedia.org/wiki/Logistic_map) of population birth/death rates.

It was completed as part of the coursework for the "Introduction to Complexity" class held by Complexity Explorer ( https://www.complexityexplorer.org/courses/119-introduction-to-complexity ) Unit 2 "Dynamics and Chaos"

## HOW IT WORKS

An initial population of turtles are randomly placed around the model world. Throughout the world, a random amount of "food pellets" are randomly strewn about. A patch may have more than one food and more than one turtle.

If a turtle is on a patch with a food pellet, it eats one food pellet. Otherwise, turtles see in a given "sight radius" up to a given "sight range" and always move to the closest food they can see. If they don't see any food, they move in a random direction.

Each step a turtle takes uses up a given amount of "energy". Eating one food pellet gives the turtle one unit of "energy". If the turtle than has more energy than the given "reproduce threshold", it will spawn a new turtle. Each turtle will then have half the amount of energy that the original turtle started with.

All turtles start at an age of "zero" and go up in age at each tick. Each turtle has its own built-in lifespan, normally distributed around the given "life expectancy" and standard deviation. Once a turtle reaches its lifespan, it dies. If a turtle's energy drops to zero, it dies.

Food then randomly drops on the world up to the given number of pellets and the cycle begins anew.

## HOW TO USE IT

Sliders:
`initial-population` - the initial number of turtles in the model
`num-pellets` - how many pellets in the world
`reproduce-threshold` - how much food a turtle needs before it reproduces
`energy-usage` - how many food units it takes to move one step
`sight-range` - how far a turtle can see for finding food
`sight-radius` - what radius a turtle can see for finding food
`life-expectancy` - how many "ticks" a turtle can expect to live, on average
`std-dev`- the standard deviation for the `life-expectancy`

Buttons:
`Clear` - calls the `clear-all` command
`Setup` - resets the world, creates the initial population of turtles, and the initial drop of food pellets
`Step` - moves the model one "tick" forward
`Go🔁`- continuously moves the model forward one "tick" at a time

Output:
`Num. Turtles` - the number of turtles in the model at the current "tick"
`Generations` - the most number of times that a line of turtles has reproduced so far this run
`Population Over Time` - a plot of the number of turtles at each "tick"

## THINGS TO NOTICE

For many natural-seeming values for the input parameters, the `Population Over Time` plot looks a lot like the plot of a Logistic map. The population will climb to a high level. Starvation and life-expectancy will cause the population to crash back down, from which it will climb back up to start the cycle again.

## THINGS TO TRY

What initial values leads to the most "realistic" Logistic map?

## EXTENDING THE MODEL

Each initial turtle starts out a random color, and when a turtle reproduces it copies the color of its parent.

One extension could be to just plot the population of each "lineage" of turtles to see how the grow or die out.

Going further, one could give each "lineage" of turtles different capabilities, and see what capabilities are most successful.

## NETLOGO FEATURES

As a sort of "introduction to NetLogo", this model uses many of the basic principles of Agent Based Modeling like creating a population, moving them through a space, etc.

## CREDITS AND REFERENCES

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)

## COPYRIGHT AND LICENSE

### The MIT License (MIT)

Copyright 2021 Brian Stepnitz

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
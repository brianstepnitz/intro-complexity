## WHAT IS IT?

Very simple model of ant foraging mostly just learning the extreme basics of the NetLogo modeling environment.

It was completed as part of the coursework for the "Introduction to Complexity" class held by Complexity Explorer ( https://www.complexityexplorer.org/courses/119-introduction-to-complexity ) Unit 1 "What is Complexity?".

## HOW IT WORKS

The nine center patches form the ant nest. Ants wander around, and when an ant finds a patch of food it collects it and returns to the nest before it wanders out again. When returning to the nest, the ant leaves a pheromone trail (that is, the patches that it traverses each gain a unit of pheromone). The pheromone evaporates over time (that is, at every time step each patch with pheromone has a probability of losing its pheromone). If a wandering ant encounters a patch with pheromone, it follows the trail as long as it can sense pheromone.

## HOW TO USE IT

Sliders:
`population` - the number of ants in the model
`max-step-size` - each ant my only move a random integer distance between zero (inclusive) and this amount (exclusive) at every tick
`max-turn-angle` - when the ant is foraging for food and does not sense a pheromone trail, this is the maximum angle that it will turn left or right in its wanderings
`evaporation-chance` - the percentage chance each tick that a unit of pheromone will "evaporate" from a patch

Buttons:
`Setup` - resets the model world
`Go🔁` - runs the model

## THINGS TO TRY

How does changing the parameters affect how long it takes before the ants find all of the food?

## CREDITS AND REFERENCES

This model is based on the "Multiple Ants" model used in the Complexity Explorer course, and the "Ants" model in NetLogo.

* Wilensky, U. (1997). NetLogo Ants model. http://ccl.northwestern.edu/netlogo/models/Ants. Center for Connected Learning and Computer-Based Modeling, Northwestern University, Evanston, IL.
* “Multiple Ants” model, Complexity Explorer project, http://complexityexplorer.org

## COPYRIGHT AND LICENSE

### The MIT License (MIT)

Copyright 2021 Brian Stepnitz

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
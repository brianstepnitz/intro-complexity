## WHAT IS IT?

This model proposes an agent-based explanation for the behavior explored in "The Regulation of Ant Colony Foraging Activity without Spatial Information" by Prabhaka et al (2012). It was completed as part of the coursework for the "Introduction to Complexity" class held by Complexity Explorer ( https://www.complexityexplorer.org/courses/119-introduction-to-complexity ) Unit 7: "Models of Biological Self-Organization".

## HOW IT WORKS

The world consists of a central nest area surrounded by ground area. Randomly strewn about the ground area are patches of food. The turtles represent ants, which can take on one of three roles: **idlers**, **foragers**, or **transporters**. On setup, all ants start as **idlers** spread out randomly in the nest.

Every **idler** moves randomly around the nest while tracking its own _activation level_. Each tick, its _activation level_ increases by the configured _activation minimum_ amount. Once its _activation level_ crosses the configured _activation threshold_, it independently becomes a **forager**.

**Foragers** walk directly out of the nest, and then randomly walk in the ground area until they walk onto a food patch. Then they turn into a **transporter**. The food patch becomes a regular ground patch, but a new food patch randomly appears in the ground area to maintain a constant amount of food in the world.

The **transporter** then moves directly back to the nest. When it reaches the nest, it turns back into an **idler** at zero _activation level_ but it has the configured _number of idlers to tell_ that it found food. As it randomly moves around the nest, if it is on a  patch with other **idlers**, it increases their _activation level_ by the configured _activation increase_ amount until it has told all of the **idlers** it was configured to tell. That _activation increase_ may also trigger an **idler** to become a **forager**.

## HOW TO USE IT

* `max-food` controls the number of patches in the ground area that should be food patches.
* `initial-population-size` controls the number of ants in the model.
* `left-right-wiggle-angle-max` controls how much an ant's heading can change each tick if its is moving randomly.
* `activation-threshold` controls how "activated" an **idler** needs to become before it turns into a **forager**.
* `num-idlers-to-tell` controls how many **idlers** a returning **transporter** should "tell" about the food it found.
* `activation-increase` controls how much more "activated" an **idler** becomes after another ant "tells" it about finding food.
* `min-activation-increase` controls how much more "activated" an **idler** becomes each tick even without hearing about another ant coming back with food.
* `tick-window` controls how many ticks should pass before updating the plots.

## THINGS TO NOTICE

As time passes, after each _tick window_, the plot updates with the number of _**Arrivals**_ (the number of **transporters** that made it back to become **idlers** in the nest) and the number of _**Departures**_ (the number of **idlers** that "activated" into **foragers**). A standard _correlation_ and _covariance_ is then computed for those values. Under reasonable configurations, fairly strong covariances and correlations can be seen.

However, even if the ants are configured to tell zero other ants about food and ants are left to their own independent _activation increase_ to reach the _activation threshold_, it is easy to show that the values still closely follow a Poisson distribution as seen in the referenced paper. Upon reflection, this makes sense, because then the ants in the nest closely model something like radioactive decay, which is known to follow a Poisson distribution.

## THINGS TO TRY

What parameters show the strongest correlation between _**Arrivals**_ and _**Departures**_?

Can one derive a formula from the parameters to the distribution of _**Arrivals**_ and _**Departures**_?

## EXTENDING THE MODEL

The amount of food in the world was held constant in order to easily see the correlation between _**Arrivals**_ and _**Departures**_. We could allow the amount of food to vary to see how that also affected the distribution of values.

The ants are both immortal and sterile. Adding some birth/death processes, maybe based on the amount of food found, may show its own interesting behavior.

## RELATED MODELS

This model was specifically made to contrast with the basic NetLogo model "Ants". Whereas the ants in that model utilize pheromone trails in order to more efficiently find clusters of food, the ants in this model have zero spatial information on the location of scattered food and instead communicate with each other locally to convey the presence of food in the environment.

Each ant having its own internal activation counter was inspired by the NetLogo model "Fireflies".

## CREDITS AND REFERENCES

Prabhakar B, Dektar KN, Gordon DM (2012) The Regulation of Ant Colony Foraging Activity without Spatial Information. PLoS Comput Biol 8(8): e1002670. doi:10.1371/journal.pcbi.1002670

## COPYRIGHT AND LICENSE

### The MIT License (MIT)

Copyright 2021 Brian Stepnitz

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
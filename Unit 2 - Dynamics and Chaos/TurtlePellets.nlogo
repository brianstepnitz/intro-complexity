turtles-own [age lifespan food generation]
patches-own [pellets]
globals [curr-pellets]

to setup
  clear-all
  set-default-shape turtles "turtle"
  create-turtles initial-population
  [
    set food (reproduce-threshold / 2)
    setxy random-xcor random-ycor
    set lifespan (random-normal life-expectancy std-dev)
  ]

  drop-pellets

  reset-ticks
end

to drop-pellets ; drop pellets into world randomly up to num-pellets
  repeat (num-pellets - curr-pellets)
  [
    ask patch random-pxcor random-pycor
    [
      set pellets (pellets + 1)
    ]
  ]

  set curr-pellets num-pellets

  ask patches
  [
    set pcolor scale-color blue pellets 0 5
  ]
end

to step
  ask turtles
  [
    find-food
    reproduce
    expire
  ]

  drop-pellets

  tick
end

to go
  step
end

to find-food
  ifelse (pellets > 0) ; if on a patch with pellets
  [
    set pellets (pellets - 1) ; eat the food
    set curr-pellets (curr-pellets - 1)
    set food (food + 1)
  ]
  [ ; else find the food
    let destination min-one-of (patches in-cone sight-range sight-radius with [pellets > 0]) [distance myself]
    if destination = nobody
    [
      ; move to a random destination
      set destination one-of neighbors
    ]
    face destination
    while [not can-move? 1] [right 1]

    set food (food - energy-usage) ; moving eats some food
    set age (age + 1)
    forward 1
  ]
end

to reproduce
  if food > reproduce-threshold
  [
    set food (reproduce-threshold / 2)
    hatch 1
    [
      set food (reproduce-threshold / 2)
      set generation (generation + 1)
      set age 0
      set lifespan (random-normal life-expectancy std-dev)
    ]
  ]
end

to expire
  if food < 1
  [
    ; die of starvation
    die
  ]

  if (age > lifespan)
  [
    ; die of old age
    die
  ]
end
@#$#@#$#@
GRAPHICS-WINDOW
234
10
671
448
-1
-1
13.0
1
10
1
1
1
0
0
0
1
-16
16
-16
16
0
0
1
ticks
30.0

BUTTON
410
470
474
503
Setup
setup
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
565
470
628
503
Go
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SLIDER
26
10
198
43
initial-population
initial-population
1
100
5.0
1
1
NIL
HORIZONTAL

PLOT
15
353
215
503
Population Over Time
Time
Population
0.0
10.0
0.0
10.0
true
false
"" ""
PENS
"default" 1.0 0 -16777216 true "" "plot count turtles"

SLIDER
27
45
199
78
num-pellets
num-pellets
1
100
75.0
1
1
NIL
HORIZONTAL

SLIDER
27
81
199
114
reproduce-threshold
reproduce-threshold
2
100
20.0
1
1
NIL
HORIZONTAL

MONITOR
24
303
107
348
Num. Turtles
count turtles
17
1
11

SLIDER
27
117
199
150
energy-usage
energy-usage
0
1
0.1
0.01
1
NIL
HORIZONTAL

SLIDER
26
153
198
186
sight-range
sight-range
1
10
10.0
1
1
NIL
HORIZONTAL

MONITOR
122
304
202
349
Generations
[generation] of (max-one-of turtles [generation])
17
1
11

SLIDER
28
189
200
222
sight-radius
sight-radius
1
360
360.0
1
1
NIL
HORIZONTAL

SLIDER
28
227
200
260
life-expectancy
life-expectancy
100
1000
500.0
10
1
NIL
HORIZONTAL

SLIDER
26
265
198
298
std-dev
std-dev
1
100
5.0
1
1
NIL
HORIZONTAL

BUTTON
335
470
398
503
Clear
clear-all
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
490
470
553
503
Step
step
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

@#$#@#$#@
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

[Logistic Map (Wikipedia)](https://en.wikipedia.org/w/index.php?title=Logistic_map&oldid=1241051940)

## COPYRIGHT AND LICENSE

### The MIT License (MIT)

Copyright 2021 Brian Stepnitz

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
@#$#@#$#@
default
true
0
Polygon -7500403 true true 150 5 40 250 150 205 260 250

airplane
true
0
Polygon -7500403 true true 150 0 135 15 120 60 120 105 15 165 15 195 120 180 135 240 105 270 120 285 150 270 180 285 210 270 165 240 180 180 285 195 285 165 180 105 180 60 165 15

arrow
true
0
Polygon -7500403 true true 150 0 0 150 105 150 105 293 195 293 195 150 300 150

box
false
0
Polygon -7500403 true true 150 285 285 225 285 75 150 135
Polygon -7500403 true true 150 135 15 75 150 15 285 75
Polygon -7500403 true true 15 75 15 225 150 285 150 135
Line -16777216 false 150 285 150 135
Line -16777216 false 150 135 15 75
Line -16777216 false 150 135 285 75

bug
true
0
Circle -7500403 true true 96 182 108
Circle -7500403 true true 110 127 80
Circle -7500403 true true 110 75 80
Line -7500403 true 150 100 80 30
Line -7500403 true 150 100 220 30

butterfly
true
0
Polygon -7500403 true true 150 165 209 199 225 225 225 255 195 270 165 255 150 240
Polygon -7500403 true true 150 165 89 198 75 225 75 255 105 270 135 255 150 240
Polygon -7500403 true true 139 148 100 105 55 90 25 90 10 105 10 135 25 180 40 195 85 194 139 163
Polygon -7500403 true true 162 150 200 105 245 90 275 90 290 105 290 135 275 180 260 195 215 195 162 165
Polygon -16777216 true false 150 255 135 225 120 150 135 120 150 105 165 120 180 150 165 225
Circle -16777216 true false 135 90 30
Line -16777216 false 150 105 195 60
Line -16777216 false 150 105 105 60

car
false
0
Polygon -7500403 true true 300 180 279 164 261 144 240 135 226 132 213 106 203 84 185 63 159 50 135 50 75 60 0 150 0 165 0 225 300 225 300 180
Circle -16777216 true false 180 180 90
Circle -16777216 true false 30 180 90
Polygon -16777216 true false 162 80 132 78 134 135 209 135 194 105 189 96 180 89
Circle -7500403 true true 47 195 58
Circle -7500403 true true 195 195 58

circle
false
0
Circle -7500403 true true 0 0 300

circle 2
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240

cow
false
0
Polygon -7500403 true true 200 193 197 249 179 249 177 196 166 187 140 189 93 191 78 179 72 211 49 209 48 181 37 149 25 120 25 89 45 72 103 84 179 75 198 76 252 64 272 81 293 103 285 121 255 121 242 118 224 167
Polygon -7500403 true true 73 210 86 251 62 249 48 208
Polygon -7500403 true true 25 114 16 195 9 204 23 213 25 200 39 123

cylinder
false
0
Circle -7500403 true true 0 0 300

dot
false
0
Circle -7500403 true true 90 90 120

face happy
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 255 90 239 62 213 47 191 67 179 90 203 109 218 150 225 192 218 210 203 227 181 251 194 236 217 212 240

face neutral
false
0
Circle -7500403 true true 8 7 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Rectangle -16777216 true false 60 195 240 225

face sad
false
0
Circle -7500403 true true 8 8 285
Circle -16777216 true false 60 75 60
Circle -16777216 true false 180 75 60
Polygon -16777216 true false 150 168 90 184 62 210 47 232 67 244 90 220 109 205 150 198 192 205 210 220 227 242 251 229 236 206 212 183

fish
false
0
Polygon -1 true false 44 131 21 87 15 86 0 120 15 150 0 180 13 214 20 212 45 166
Polygon -1 true false 135 195 119 235 95 218 76 210 46 204 60 165
Polygon -1 true false 75 45 83 77 71 103 86 114 166 78 135 60
Polygon -7500403 true true 30 136 151 77 226 81 280 119 292 146 292 160 287 170 270 195 195 210 151 212 30 166
Circle -16777216 true false 215 106 30

flag
false
0
Rectangle -7500403 true true 60 15 75 300
Polygon -7500403 true true 90 150 270 90 90 30
Line -7500403 true 75 135 90 135
Line -7500403 true 75 45 90 45

flower
false
0
Polygon -10899396 true false 135 120 165 165 180 210 180 240 150 300 165 300 195 240 195 195 165 135
Circle -7500403 true true 85 132 38
Circle -7500403 true true 130 147 38
Circle -7500403 true true 192 85 38
Circle -7500403 true true 85 40 38
Circle -7500403 true true 177 40 38
Circle -7500403 true true 177 132 38
Circle -7500403 true true 70 85 38
Circle -7500403 true true 130 25 38
Circle -7500403 true true 96 51 108
Circle -16777216 true false 113 68 74
Polygon -10899396 true false 189 233 219 188 249 173 279 188 234 218
Polygon -10899396 true false 180 255 150 210 105 210 75 240 135 240

house
false
0
Rectangle -7500403 true true 45 120 255 285
Rectangle -16777216 true false 120 210 180 285
Polygon -7500403 true true 15 120 150 15 285 120
Line -16777216 false 30 120 270 120

leaf
false
0
Polygon -7500403 true true 150 210 135 195 120 210 60 210 30 195 60 180 60 165 15 135 30 120 15 105 40 104 45 90 60 90 90 105 105 120 120 120 105 60 120 60 135 30 150 15 165 30 180 60 195 60 180 120 195 120 210 105 240 90 255 90 263 104 285 105 270 120 285 135 240 165 240 180 270 195 240 210 180 210 165 195
Polygon -7500403 true true 135 195 135 240 120 255 105 255 105 285 135 285 165 240 165 195

line
true
0
Line -7500403 true 150 0 150 300

line half
true
0
Line -7500403 true 150 0 150 150

pentagon
false
0
Polygon -7500403 true true 150 15 15 120 60 285 240 285 285 120

person
false
0
Circle -7500403 true true 110 5 80
Polygon -7500403 true true 105 90 120 195 90 285 105 300 135 300 150 225 165 300 195 300 210 285 180 195 195 90
Rectangle -7500403 true true 127 79 172 94
Polygon -7500403 true true 195 90 240 150 225 180 165 105
Polygon -7500403 true true 105 90 60 150 75 180 135 105

plant
false
0
Rectangle -7500403 true true 135 90 165 300
Polygon -7500403 true true 135 255 90 210 45 195 75 255 135 285
Polygon -7500403 true true 165 255 210 210 255 195 225 255 165 285
Polygon -7500403 true true 135 180 90 135 45 120 75 180 135 210
Polygon -7500403 true true 165 180 165 210 225 180 255 120 210 135
Polygon -7500403 true true 135 105 90 60 45 45 75 105 135 135
Polygon -7500403 true true 165 105 165 135 225 105 255 45 210 60
Polygon -7500403 true true 135 90 120 45 150 15 180 45 165 90

sheep
false
15
Circle -1 true true 203 65 88
Circle -1 true true 70 65 162
Circle -1 true true 150 105 120
Polygon -7500403 true false 218 120 240 165 255 165 278 120
Circle -7500403 true false 214 72 67
Rectangle -1 true true 164 223 179 298
Polygon -1 true true 45 285 30 285 30 240 15 195 45 210
Circle -1 true true 3 83 150
Rectangle -1 true true 65 221 80 296
Polygon -1 true true 195 285 210 285 210 240 240 210 195 210
Polygon -7500403 true false 276 85 285 105 302 99 294 83
Polygon -7500403 true false 219 85 210 105 193 99 201 83

square
false
0
Rectangle -7500403 true true 30 30 270 270

square 2
false
0
Rectangle -7500403 true true 30 30 270 270
Rectangle -16777216 true false 60 60 240 240

star
false
0
Polygon -7500403 true true 151 1 185 108 298 108 207 175 242 282 151 216 59 282 94 175 3 108 116 108

target
false
0
Circle -7500403 true true 0 0 300
Circle -16777216 true false 30 30 240
Circle -7500403 true true 60 60 180
Circle -16777216 true false 90 90 120
Circle -7500403 true true 120 120 60

tree
false
0
Circle -7500403 true true 118 3 94
Rectangle -6459832 true false 120 195 180 300
Circle -7500403 true true 65 21 108
Circle -7500403 true true 116 41 127
Circle -7500403 true true 45 90 120
Circle -7500403 true true 104 74 152

triangle
false
0
Polygon -7500403 true true 150 30 15 255 285 255

triangle 2
false
0
Polygon -7500403 true true 150 30 15 255 285 255
Polygon -16777216 true false 151 99 225 223 75 224

truck
false
0
Rectangle -7500403 true true 4 45 195 187
Polygon -7500403 true true 296 193 296 150 259 134 244 104 208 104 207 194
Rectangle -1 true false 195 60 195 105
Polygon -16777216 true false 238 112 252 141 219 141 218 112
Circle -16777216 true false 234 174 42
Rectangle -7500403 true true 181 185 214 194
Circle -16777216 true false 144 174 42
Circle -16777216 true false 24 174 42
Circle -7500403 false true 24 174 42
Circle -7500403 false true 144 174 42
Circle -7500403 false true 234 174 42

turtle
true
0
Polygon -10899396 true false 215 204 240 233 246 254 228 266 215 252 193 210
Polygon -10899396 true false 195 90 225 75 245 75 260 89 269 108 261 124 240 105 225 105 210 105
Polygon -10899396 true false 105 90 75 75 55 75 40 89 31 108 39 124 60 105 75 105 90 105
Polygon -10899396 true false 132 85 134 64 107 51 108 17 150 2 192 18 192 52 169 65 172 87
Polygon -10899396 true false 85 204 60 233 54 254 72 266 85 252 107 210
Polygon -7500403 true true 119 75 179 75 209 101 224 135 220 225 175 261 128 261 81 224 74 135 88 99

wheel
false
0
Circle -7500403 true true 3 3 294
Circle -16777216 true false 30 30 240
Line -7500403 true 150 285 150 15
Line -7500403 true 15 150 285 150
Circle -7500403 true true 120 120 60
Line -7500403 true 216 40 79 269
Line -7500403 true 40 84 269 221
Line -7500403 true 40 216 269 79
Line -7500403 true 84 40 221 269

wolf
false
0
Polygon -16777216 true false 253 133 245 131 245 133
Polygon -7500403 true true 2 194 13 197 30 191 38 193 38 205 20 226 20 257 27 265 38 266 40 260 31 253 31 230 60 206 68 198 75 209 66 228 65 243 82 261 84 268 100 267 103 261 77 239 79 231 100 207 98 196 119 201 143 202 160 195 166 210 172 213 173 238 167 251 160 248 154 265 169 264 178 247 186 240 198 260 200 271 217 271 219 262 207 258 195 230 192 198 210 184 227 164 242 144 259 145 284 151 277 141 293 140 299 134 297 127 273 119 270 105
Polygon -7500403 true true -1 195 14 180 36 166 40 153 53 140 82 131 134 133 159 126 188 115 227 108 236 102 238 98 268 86 269 92 281 87 269 103 269 113

x
false
0
Polygon -7500403 true true 270 75 225 30 30 225 75 270
Polygon -7500403 true true 30 75 75 30 270 225 225 270
@#$#@#$#@
NetLogo 6.4.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
default
0.0
-0.2 0 0.0 1.0
0.0 1 1.0 0.0
0.2 0 0.0 1.0
link direction
true
0
Line -7500403 true 150 150 90 180
Line -7500403 true 150 150 210 180
@#$#@#$#@
1
@#$#@#$#@

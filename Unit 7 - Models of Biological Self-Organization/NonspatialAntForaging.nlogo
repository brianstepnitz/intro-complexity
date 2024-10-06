breed [ants ant]

ants-own [
  num-idlers-left-to-tell
  activation-level
]

globals [
  ground-color
  nest-color
  food-color

  idler-color
  forager-color
  transporter-color

  talker-color

  arrivals-this-window
  departures-this-window

  list-arrivals
  list-departures
]

to setup
  clear-all

  set ground-color brown
  set nest-color yellow
  set food-color green

  set idler-color red
  set forager-color pink
  set transporter-color violet

  ask patches [ set pcolor ground-color ]

  let nest-radius 5

  ask patch 0 0 [
    ask patches in-radius nest-radius [
      set pcolor nest-color
    ]
  ]

  ask up-to-n-of max-food patches with [pcolor = ground-color] [
    set pcolor food-color
  ]

  set-default-shape ants "bug"
  let ants-left-to-place initial-population-size
  while [ants-left-to-place > 0] [
    let nest-patches (patches with [ pcolor = nest-color ])
    ask up-to-n-of ants-left-to-place nest-patches [
      sprout-ants 1 [
        set color idler-color
      ]
    ]

    set ants-left-to-place (ants-left-to-place - count nest-patches)
  ]

  ask ants [
    set num-idlers-left-to-tell 0
    set activation-level (random activation-threshold)
  ]

  set arrivals-this-window 0
  set departures-this-window 0

  set list-arrivals []
  set list-departures []

  reset-ticks
end

to go
  let curr-turtles turtle-set turtles

  ask curr-turtles [

    ; Move all ants first, before changing roles.

    if (color = idler-color) [
      idle-move
    ]
    if (color = forager-color) [
      forage-move
    ]
    if (color = transporter-color) [
      transport-move
    ]

    ; Now check if it's time to change roles.

    if (color = forager-color and [pcolor] of patch-here = food-color) [
      ; found food! return it to the nest and tell the others

      ask patch-here [ set pcolor ground-color ]

      ; constant food
      ask one-of patches with [pcolor = ground-color] [ set pcolor food-color ]

      set color transporter-color
      set num-idlers-left-to-tell num-idlers-to-tell
    ]

    if (color = transporter-color and [pcolor] of patch-here = nest-color) [
      set arrivals-this-window (arrivals-this-window + 1)
      set color idler-color
    ]

    if (color = idler-color) [

      ; if we're in the nest and have other ants left to tell about food, tell them
      if (num-idlers-left-to-tell > 0) [
        let idlers-to-tell up-to-n-of num-idlers-left-to-tell other ants-here with [color = idler-color]
        set num-idlers-left-to-tell (num-idlers-left-to-tell - count idlers-to-tell)
        ask idlers-to-tell [
          set activation-level (activation-level + activation-increase)
        ]
      ]

      set activation-level (activation-level + min-activation-increase)

      if (activation-level > activation-threshold) [

        set departures-this-window (departures-this-window + 1)

        set color forager-color
        set activation-level 0
      ]
    ]
  ] ; end ask

  if (ticks mod tick-window = 0) [
    set-current-plot "Arrivals and Departures"
    if (arrivals-this-window > plot-y-max) [ set-plot-y-range 0 arrivals-this-window ]
    if (departures-this-window > plot-y-max) [ set-plot-y-range 0 departures-this-window ]
    set-plot-x-range 0 (plot-x-max + 1)
    set-current-plot-pen "arrivals"
    plot arrivals-this-window
    set-current-plot-pen "departures"
    plot departures-this-window

    set list-arrivals (lput arrivals-this-window list-arrivals)
    set list-departures (lput departures-this-window list-departures)

    if (length list-arrivals > 3) [
      clear-output
      output-print (word "correlation(arrivals_t, departures_t) = " (correlation list-arrivals list-departures) )
      output-print (word "covariance(arrivals_t, departures_t) = " (covariance list-arrivals list-departures))
    ]

    set arrivals-this-window 0
    set departures-this-window 0
  ]

  tick
end

to-report covariance [xs ys]
  let mean-x (mean xs)
  let mean-y (mean ys)
  let n (length xs)

  let numerator 0
  (foreach xs ys [ [x y] ->
    set numerator ( numerator + (x - mean-x) * (y - mean-y) )
    ])

  report numerator / (n - 1)
end


to-report correlation [xs ys]
  let mean-x (mean xs)
  let stdev-x (standard-deviation xs)
  let mean-y (mean ys)
  let stdev-y (standard-deviation ys)
  let N (length xs)

  let r 0
  if (stdev-x != 0 and stdev-y != 0) [
  (foreach xs ys [ [x y] ->
    set r ( r + ( ( x - mean-x) * ( y - mean-y) ) / ( (N - 1) * stdev-x * stdev-y ) )
    ])
  ]

  report r
end

to wiggle
  ifelse (random 2 = 0) [
    right random left-right-wiggle-angle-max
  ] [
    left random left-right-wiggle-angle-max
  ]
end

to idle-move
  wiggle

  while [ not ([pcolor] of patch-ahead 1 = nest-color) ] [ wiggle ]

  forward 1
end

to forage-move

  ifelse ([pcolor] of patch-here = nest-color) [

    ; If in the nest, move directly out of the nest.
    face min-one-of ( patches with [pcolor != nest-color] ) [distance self]
  ]
  [

    ; Else if out of the nest, randomly move around the world outside the nest.
    wiggle
    while [patch-ahead 1 = nobody or [pcolor] of patch-ahead 1 = nest-color ] [ wiggle ]
  ]

  forward 1
end

to transport-move
  face min-one-of ( patches with [pcolor = nest-color] ) [distance self]

  forward 1
end
@#$#@#$#@
GRAPHICS-WINDOW
265
11
936
683
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
-25
25
-25
25
0
0
1
ticks
30.0

SLIDER
8
51
180
84
initial-population-size
initial-population-size
1
100
100.0
1
1
NIL
HORIZONTAL

BUTTON
6
332
70
365
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

SLIDER
8
91
208
124
left-right-wiggle-angle-max
left-right-wiggle-angle-max
0
180
45.0
1
1
NIL
HORIZONTAL

BUTTON
80
333
143
366
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
8
129
180
162
activation-threshold
activation-threshold
1
1000
500.0
1
1
NIL
HORIZONTAL

SLIDER
9
168
181
201
num-idlers-to-tell
num-idlers-to-tell
0
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
9
10
181
43
max-food
max-food
1
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
0
207
172
240
activation-increase
activation-increase
1
100
100.0
1
1
NIL
HORIZONTAL

SLIDER
6
246
184
279
min-activation-increase
min-activation-increase
1
100
1.0
1
1
NIL
HORIZONTAL

PLOT
949
13
1558
378
Arrivals and Departures
tick window
count
0.0
0.5
0.0
0.5
false
true
"" ""
PENS
"departures" 1.0 0 -2064490 true "" ""
"arrivals" 1.0 0 -8630108 true "" ""

OUTPUT
949
390
1560
481
11

SLIDER
7
290
179
323
tick-window
tick-window
1
100
30.0
1
1
NIL
HORIZONTAL

@#$#@#$#@
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
0
@#$#@#$#@

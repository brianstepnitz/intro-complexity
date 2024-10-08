globals [
  color-coopToCoop
  color-coopToDefect
  color-defectToCoop
  color-defectToDefect

  strategy-coop
  strategy-defect
]

turtles-own [
  strategy
  points
]

to setup-prisoners-dilemma
  clear-all

  set-default-shape turtles "square"

  set color-coopToCoop blue
  set color-coopToDefect yellow
  set color-defectToCoop green
  set color-defectToDefect red

  set strategy-coop "coop"
  set strategy-defect "defect"

  reset-ticks
end

to setup-special
  setup-prisoners-dilemma

  set world-size 99
  resize-world 0 98 0 98

  ask patches [
    sprout 1 [
      ifelse (xcor = 49 and ycor = 49) [
        initialize-defect
      ]
      [
        initialize-coop
      ]
    ]
  ]

  set interaction-radius 1.5
  ask turtles [
    create-links-with other turtles in-radius interaction-radius
  ]

  set defector-advantage 1.9
  set deterministic? true
  set synchronous? true
end

to setup-spatial
  setup-prisoners-dilemma

  resize-world 0 (world-size - 1) 0 (world-size - 1)

  ask patches [
    if (random-float 1 < density) [
      sprout 1 [
        ifelse (random-float 1 < coop-chance) [
          initialize-coop
        ] [
          initialize-defect
        ]
      ]
    ]
  ]

  ask turtles [
    create-links-with other turtles in-radius interaction-radius
  ]
end

to setup-network
  setup-prisoners-dilemma

  set world-size (1 / 3) * population-size
  resize-world 0 (world-size - 1) 0 (world-size - 1)

  create-turtles population-size [
    ifelse random-float 1 < coop-chance [ initialize-coop ] [ initialize-defect ]
  ]

  ask one-of turtles [
    create-link-with one-of other turtles
  ]

  ask turtles with [count my-links = 0] [
    create-link-with [one-of both-ends] of one-of links
  ]

  layout-radial turtles links ( max-one-of turtles [count link-neighbors] )
end

to layout-network
  layout-spring turtles links 0.2 5 1
end

to async-step
  ask turtles [
    ask my-neighborhood [
      compete-with-my-neighborhood
    ]

    resolve-my-competitions

    if (color = color-coopToDefect) [set strategy strategy-defect]
    if (color = color-defectToCoop) [set strategy strategy-coop]
  ]
end

to sync-step
  ask turtles [
    compete-with-my-neighborhood
  ]

  ask turtles [
    resolve-my-competitions
  ]

  ask turtles [
    if (color = color-coopToDefect) [set strategy strategy-defect]
    if (color = color-defectToCoop) [set strategy strategy-coop]
  ]
end

to step
  ifelse (synchronous?) [ sync-step ] [ async-step ]
  tick
  if not any? turtles with [strategy = strategy-defect] or not any? turtles with [strategy = strategy-coop] [
    stop
  ]
end

;;;;;;;;;;;;;;;;;;;;
;; Turtle Procedures
;;;;;;;;;;;;;;;;;;;;

to initialize-coop
  set strategy strategy-coop
  set color color-coopToCoop
end

to initialize-defect
  set strategy strategy-defect
  set color color-defectToDefect
end

to-report my-neighborhood
  report (turtle-set self link-neighbors)
end

to compete-with-my-neighborhood
  let num-coop-neighbors (count my-neighborhood with [strategy = strategy-coop])

  ifelse (strategy = strategy-coop) [
    set points num-coop-neighbors
  ]
  [
    set points (defector-advantage * num-coop-neighbors)
  ]
end

to resolve-my-competitions
  let winning-strategy strategy
  ifelse (deterministic?) [
    let best-neighbor max-one-of my-neighborhood [points]
    if (points < [points] of best-neighbor) [set winning-strategy [strategy] of best-neighbor]
  ]
  [
    let coop-points-sum 0
    let points-sum (2 ^ -1024)
    ask my-neighborhood [
      set points-sum (points-sum + points ^ determinism-degree)
      if (strategy = strategy-coop) [set coop-points-sum (coop-points-sum + points ^ determinism-degree)]
    ]

    let probability-coop (coop-points-sum / points-sum)
    ifelse (random-float 1 < probability-coop) [set winning-strategy strategy-coop] [set winning-strategy strategy-defect]
  ]

  if (strategy = strategy-coop and winning-strategy = strategy-coop) [set color color-coopToCoop]
  if (strategy = strategy-coop and winning-strategy = strategy-defect) [set color color-coopToDefect]
  if (strategy = strategy-defect and winning-strategy = strategy-coop) [set color color-defectToCoop]
  if (strategy = strategy-defect and winning-strategy = strategy-defect) [set color color-defectToDefect]
end
@#$#@#$#@
GRAPHICS-WINDOW
245
10
847
613
-1
-1
6.0
1
10
1
1
1
0
0
0
1
0
98
0
98
1
1
1
ticks
30.0

SLIDER
5
500
177
533
world-size
world-size
2
200
99.0
1
1
NIL
HORIZONTAL

SLIDER
5
250
177
283
coop-chance
coop-chance
0
1
0.75
0.01
1
NIL
HORIZONTAL

SLIDER
5
290
177
323
defector-advantage
defector-advantage
1.01
3
1.9
0.01
1
NIL
HORIZONTAL

BUTTON
120
765
183
798
Go
step
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

BUTTON
50
765
113
798
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

BUTTON
10
170
115
203
Predefined Setup
setup-special
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
5
410
175
443
synchronous?
synchronous?
0
1
-1000

SLIDER
5
535
177
568
density
density
0.01
1
1.0
0.01
1
NIL
HORIZONTAL

SLIDER
5
572
177
605
interaction-radius
interaction-radius
1.5
11
1.5
0.5
1
NIL
HORIZONTAL

SLIDER
5
370
177
403
determinism-degree
determinism-degree
0
100
100.0
0.5
1
NIL
HORIZONTAL

BUTTON
35
610
142
643
Spatial Setup
setup-spatial
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

SWITCH
6
330
176
363
deterministic?
deterministic?
0
1
-1000

TEXTBOX
15
10
195
161
Choose the Predefined Setup XOR\nOne of the two Custom Setups:\n--------------------------------------------\nPredefined Setup:\n\nworld-size = 99\ncheater-advantage = 1.90\ninteraction-radius = 1.5\n\none central Defector\nall others Cooperators
11
0.0
1

TEXTBOX
10
205
175
261
----------------\nCustom Setup\nOptions common to both setups:
11
0.0
1

TEXTBOX
5
455
210
496
Choose Spatial Setup XOR Network Setup\n\nSpatial Setup options:
11
0.0
1

SLIDER
35
670
207
703
population-size
population-size
2
2048
1605.0
1
1
NIL
HORIZONTAL

BUTTON
5
710
117
743
Network Setup
setup-network
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
120
710
237
743
Layout Network
layout-network
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

TEXTBOX
5
650
155
668
Network Setup options:
11
0.0
1

@#$#@#$#@
## WHAT IS IT?

This model presents a two-dimensional world of agents which iteratively play the Prisoner's Dilemma among their neighbors with only the strategies "Always Cooperate" or "Always Defect". After each contest, depending on the rules defined during setup, agents may change their strategy for the subsequent round.

It was completed as part of the coursework for the "Introduction to Complexity" class held by Complexity Explorer ( https://www.complexityexplorer.org/courses/119-introduction-to-complexity ) Unit 8: Models of Cooperation in Social Systems.

## HOW IT WORKS

Agents are arranged into fixed neighborhoods, and play The Prisonner's Dilemma with each neighbor in their neighborhood as well as with themselves.

Agents may be arranged **spatially** or **networked**. In the **spatial** case, agents are arranged in a grid. Their neighborhood is defined as all agents within their `interaction-radius`.

In the **networked** case, agents are arranged in a scale-free network through preferential attachment.

Agents are color-coded as follows:

1. Agents who stayed "Always Cooperate" are <span style="color: blue">Blue</span>.
2. Agents who stayed "Always Defect" are <span style="color: red">Red</span>.
3. Agents who changed to "Always Cooperate" are <span style="color: green">Green</span>.
4. Agents who changed to "Always Defect" are <span style="color: yellow; background-color: #D3D3D3">Yellow</span>.


Each interaction gives them a payout as indicated in the table below, and their final reward is equal to the sum of the payouts from all of their interactions.

<div align="center">
	<table style="border: 1px solid; border-collapse: collapse">
		<tr>
			<td style="border:1px solid"></td>
			<td style="border:1px solid;text-align:center"><strong>Defect</strong></td>
			<td style="border:1px solid;text-align:center"><strong>Cooperate</strong></td>
		</tr>
		<tr>
			<td style="padding:5px;border:1px solid"><strong>Defect</strong></td>
			<td style="border:1px solid;text-align:center">0</td>
			<td style="padding:5px;border:1px solid"><code>defector-advantage</code></td>
		</tr>
		<tr>
			<td style="padding:5px;border:1px solid"><strong>Cooperate</strong></td>
			<td style="padding:5px;border:1px solid"><code>defector-advantage</code></td>
			<td style="border:1px solid;text-align:center">1</td>
		</tr>
	</table>
</div>

Agents may then change their strategy either **deterministically** or **probabilistically** as configured during setup.

In the **deterministic** case, an agent always sets its strategy to the strategy of the agent in its neighborhood (including itself) with the highest total reward.

In the **probabilistic** case, as defined in (Nowak 1994), the chance that an agent will set its strategy to "Always Cooperate" is given by the formula:

SUM<sub>(every "Always Cooperate" agent in the neighborhood)</sub> (reward <sup>`determinism-degree`</sup>)
/ SUM<sub>(every agent in the neighborhood)</sub> (reward <sup>`determinism-degree`</sup>)

That is, the sum of the total reward of every "Always Cooperate" agent in the neighborhood raised to the `determinism-degree`, divided by the sum of the total reward of every agent in the neighborhood raised to the `determinism-degree`. Remember that "neighborhood" here also includes the agent in question as well. As `determinism-degree` increases, the model behaves more and more like in the **deterministic** case.

The agent will then randomly set its strategy to "Always Cooperate" or "Always Defect" using this computed probability.

These interactions are configured during setup to happen either **synchronously** or **asynchronously**.

In the **synchronous** case, all agents run their games with their neighbors. Then, only after all agents have finished their games, each agent decides on how to set their strategy according to the rules described above. After each agent has decided on its strategy, the next round begins.

In the **asynchronous** case, rounds instead proceed as follows:

1. Arbitrarily choose an agent that hasn't been chosen yet this round.
2. That agent and each of its neighbors all play The Prisoner's Dilemma within their neighborhood. (Those neighbors playing the Prisoner's Dilemma here do not count as being "chosen" yet this round.)
3. The chosen agent then sets its strategy according to the rules described above. Note that this may change the agent's strategy before some of its neighbors have been chosen this round, so that by the time they are chosen they "see" a different strategy here than they may have seen this time.
4. Once all agents have been chosen for this round, move on to the next round following these steps.

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

### Predefined Setup

Sets up a grid of 99x99 agents, where the center one is a defector and all of the rest are cooperators. The `defector-advantage` is set to 1.9, `deterministic?` is set to `true`, and `synchronous?` is set to `true`.

### Custom Setups

`coop-chance` - the chance at start that an agent is a cooperator instead of a defector
`defector-advantage` - the payoff that a defector agent receives against a cooperator.
`deterministic?`- whether or not agents change strategy deterministically or probabilistically
`determinism-degree` - if agents are not deterministic, this is the degree to which they are deterministic
`synchronous?` - whether or not agents play their games in synch with the other agents

#### Spatial Setup

`world-size` - the size of the grid
`density` - the proportion of cells in the grid that have agents in them
`interation-radius` - the distance at which agents can interact with other agents in their Prisoners Dilemma games

#### Network Setup

`population-size` - how many agents to put into the scale-free network

## THINGS TO NOTICE

(suggested things for the user to notice while running the model)

## THINGS TO TRY

(suggested things for the user to try to do (move sliders, switches, etc.) with the model)

## EXTENDING THE MODEL

(suggested things to add or change in the Code tab to make the model more complicated, detailed, accurate, etc.)

## NETLOGO FEATURES

(interesting or unusual features of NetLogo that the model uses, particularly in the Code tab; or where workarounds were needed for missing features)

## RELATED MODELS

(models in the NetLogo Models Library and elsewhere which are of related interest)

## CREDITS AND REFERENCES

1. Nowak, M. A. & May, R. M. 1992 Evolutionary games and spatial chaos. _Nature_ **359**, 826-829.
2. Huberman, B. A. & Glance, N. S. 1993 Evolutionary games and computer siumulations. _Proc. Natl. Acad. Sci, USA_ **90**, 7716-7718.
3. Nowak, M. A., Bonhoeffer, S. & May, R. M. 1994 Spatial games and the maintenance of cooperation. _Proc Natl. Acad. Sci, USA_ **91**, 4877-4881.
4. Santos, F. C., Rodrigues, J. F. & Pacheco, J. M. 2005 Graph topology plays a determinant role in the evolution of cooperation. _Proc. R. Soc. B_ (doi:10.1098/rspb.2005.3272.)
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

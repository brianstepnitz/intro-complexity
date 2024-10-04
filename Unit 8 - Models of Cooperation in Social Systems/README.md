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
;;The Evolution of Parochial Altruism
;;Paul E. Smaldino


globals [
  learning-strategies
  ;; UT = unbiased transmission
  ;; CT = conformist transmission
  ;; PT = payoff-biased transmission
]

breed [atraits atrait] ;;adaptive traits
breed [learners learner] ;;the agents

atraits-own [group]

learners-own [
 ;HERITABLE CHARACTERISTICS
  group ;;the adaptive trait that is optimal for this agent.
  groupID ;;the group marker
  parochial?
  reliance-soc-learn
  learning-strategy
  ;DYNAMIC CHARACTERISTICS
  payoff
  trait
  ;adaptive-trait?
  old? ;;are they a member of the parent generation
  models ;;the set of learning models
  indiv-x ;;coordinates from individual learning
  indiv-y
  social-x ;;coordinates from social learning
  social-y
]



;;-----------------------------------------------------------------------
;; SETUP PROCEDURES
;;-----------------------------------------------------------------------


to setup
  clear-all
  ;;set up adaptive traits
  setup-adaptive-traits

  ;;setup list of learning strategies
  set learning-strategies ["UT"]
  if conformism? [set learning-strategies lput "CT" learning-strategies]
  if payoff-bias? [set learning-strategies lput "PT" learning-strategies]
  ;;establish the two group
  let bigger-group-size round (freq-big-group * pop-size)
  let smaller-group-size (pop-size - bigger-group-size)
  set-default-shape learners "circle"
  create-learners bigger-group-size [
    set group 0
    set size 0.5
    set color blue
    ifelse (probability? identity-correlation)
    [
      set groupID 0
    ]
    [
      ifelse (probability? freq-big-group)
      [ set groupID 0 ] [set groupID 1]
    ]
  ]
  create-learners smaller-group-size [
    set group 1
    set size 0.5
    set color red
    ifelse (probability? identity-correlation)
    [
      set groupID 1
    ]
    [
      ifelse (probability? freq-big-group)
      [ set groupID 0 ] [set groupID 1]
    ]
  ]
 ;;initialize turtle characteristics
  ask learners [
    initialize-agent
    individual-learning
    receive-payoffs
    ;;since everyone is initially an individual learner, they acquire the trait with the
    ;;probability of the individual learning efficacy and get corresponding payoffs
  ]
  reset-ticks
end


;;initialize adaptive traits
to setup-adaptive-traits
  set-default-shape atraits "target"
  ask patches [set pcolor black]
  ask patches with [pxcor = 0] [set pcolor 1]
  ask patches with [pycor = 0] [set pcolor 1]
  create-atraits 1 [ ;;create trait 0
    set color sky
    set size 4
    setxy 10 0 ;;Scale is multiplied by 10 for visualization - make sure to account for this in the analysis!
    set group 0
  ]
 create-atraits 1 [ ;;create trait 1
    set color orange
    set size 4
    setxy (polar-to-cartesian-x 10 theta-dist-traits) (polar-to-cartesian-y 10 theta-dist-traits)
    set group 1
  ]
end

to-report polar-to-cartesian-x [r theta]
  report r * (cos theta)
end

to-report polar-to-cartesian-y [r theta]
  report r * (sin theta)
end


;;initialize a newly created agent
to initialize-agent
  set parochial? false ;;default to no parochialism
  set learning-strategy "UT" ;; defaul to to individual learning
  set old? false ;;all agents start young
  set models no-turtles ;;empty list for their set of learning models
end


;;turtle-level procedure: an individual learner acquires a trait
to individual-learning
  let x [xcor] of atrait group
  let y [ycor] of atrait group
  setxy (random-normal x sigma-indiv-learning) (random-normal y sigma-indiv-learning)
end

;;turtle-level procedure: translate traits into payoffs
to receive-payoffs
  let d distance atrait group ;;distance from group-relevant adaptive trait
  let exponent -1 * (d ^ 2) / (2 * selection-intensity)
  set payoff e ^ exponent ;; precision (e ^ exponent) 5 ;;round to 5 decimal places
end


;;reports true with probabilty prob, otherwise reports false
to-report probability? [prob]
  ifelse random-float 1 < prob
  [report true]
  [report false]
end



;;-----------------------------------------------------------------------
;; DYNAMICS PROCEDURES
;;-----------------------------------------------------------------------


to go
  reproduction
  model-choice
  learning
  ask learners with [old?][die]
  ask learners [receive-payoffs]
  tick
end


;;A new generation is formed. Group sizes are held constant, but parochialism and social learning
;;strategies are inherited with probability proportional to parental fitness.
to reproduction
  ask learners [set old? true];;now they're the parents.
  ;;reproduce group 0
  let max-i0 (count learners with [group = 0])
  let i0 0
  let max-payoff0 (max [payoff] of (learners with [group = 0])) ;;max payoff in group
  while [i0 < max-i0] [
   ask one-of (learners with [group = 0 and old?]) [
      if probability? (payoff / max-payoff0) ;;reproduce if high payoff
      [
        hatch 1 [
          set old? false
          set models no-turtles
          setxy 0 0
        ]
        set i0 (i0 + 1)
      ]
    ]
  ]
  ;;reproduce group 1
  let max-i1 (count learners with [group = 1])
  let i1 0
  let max-payoff1 (max [payoff] of (learners with [group = 1 and old?])) ;;max payoff in group
  while [i1 < max-i1] [
   ask one-of (learners with [group = 1]) [
      if probability? (payoff / max-payoff1) ;;reproduce if high payoff
      [
        hatch 1 [
          set old? false
          set models no-turtles
          setxy 0 0
        ]
        set i1 (i1 + 1)
      ]
    ]
  ]
  mutation ;;mutate turtles
end


;;mutate turtles
to mutation
  ask learners with [not old?] [
    ;;mutate social learning reliance, strategy, parochialism
    if probability? mutation-reliance ;;mutation on social learning reliance
    [
      set reliance-soc-learn (reliance-soc-learn + (random-normal 0 sigma-social-learn-reliance))
      if reliance-soc-learn < 0 [set reliance-soc-learn 0]
      if reliance-soc-learn > 1 [set reliance-soc-learn 1]
    ]
    if probability? mutation-learn ;;mutation on social learning strategy
    [
      set learning-strategy one-of learning-strategies
    ]
    if probability? mutation-parochialism ;;mutation on parochialism
    [
      set parochial? one-of [true false]
    ]
  ]
end


;;agents choose a set of models for learning
;;all new agents have an empty list of models
;;note that it's possible for parochial agents to have a zero
to model-choice
  ask learners with [not old?][
    let potential-models (n-of num-learning-models (learners with [old?])) ;;choose n random other learners
    ifelse parochial?
    [set models potential-models with [color = [color] of myself]]
    [set models potential-models]
    ;;make sure there's at least one agent to copy
    ;if (count models = 0) [
    ;  set models (turtle-set one-of learners with [old? and groupID = [groupID] of myself])
    ;]
  ]
end


;;agents use their learning strategies to acquire traits
to learning
  ;;first, individual learning.
  ask learners with [not old?][
    let x [xcor] of atrait group
    let y [ycor] of atrait group
    set indiv-x (random-normal x sigma-indiv-learning)
    set indiv-y (random-normal y sigma-indiv-learning)
    set social-x indiv-x ;;do this for parochial learners who don't have any models.
    set social-y indiv-y
  ]
;;next, do the social learning
  ask learners with [not old? and learning-strategy = "UT" and count models > 0]
  [
    let m one-of models
    set social-x [xcor] of m
    set social-y [ycor] of m
  ]
  ;;conformist transmission
  ask learners with [not old? and learning-strategy = "CT" and count models > 0]
  [
    set social-x median [xcor] of models
    set social-x median [xcor] of models
  ]
 ;;payoff-biased transmission
  ask learners with [not old? and learning-strategy = "PT" and count models > 0]
  [
    let m max-one-of models [payoff]
    set social-x [xcor] of m
    set social-y [ycor] of m
  ]

  ;;now integrate the learning.
  ask learners with [not old? and count models > 0]
  [
    set xcor (reliance-soc-learn * social-x) + ((1 - reliance-soc-learn) * indiv-x)
    set ycor (reliance-soc-learn * social-y) + ((1 - reliance-soc-learn) * indiv-y)
  ]

  ask learners with [not old? and count models = 0]
  [
    set xcor indiv-x
    set ycor indiv-y
  ]



end



;;-----------------------------------------------------------------------
;; OUTCOMES PROCEDURES
;;-----------------------------------------------------------------------


;;avg reliance on social learning
to-report avg-reliance-0
  report mean [reliance-soc-learn] of learners with [group = 0]
end

to-report avg-reliance-1
  report mean [reliance-soc-learn] of learners with [group = 1]
end


;;parochial social learners in group 0
to-report freq-parochial-social-learning-0
  report (count learners with [group = 0 and parochial?]) /  (count learners with [group = 0])
end

;;parochial social learners in group 1
to-report freq-parochial-social-learning-1
  report (count learners with [group = 1 and parochial?]) /  (count learners with [group = 1])
end


;;payoffs
to-report avg-payoff-0
  report mean [payoff] of learners with [group = 0]
end

to-report avg-payoff-1
  report mean [payoff] of learners with [group = 1]
end

;;learning strategies
to-report UT-0
  report (count learners with [group = 0 and learning-strategy = "UT"]) /  (count learners with [group = 0])
end

to-report UT-1
  report (count learners with [group = 1 and learning-strategy = "UT"]) /  (count learners with [group = 1])
end

to-report CT-0
  report (count learners with [group = 0 and learning-strategy = "CT"]) /  (count learners with [group = 0])
end

to-report CT-1
  report (count learners with [group = 1 and learning-strategy = "CT"]) /  (count learners with [group = 1])
end

to-report PT-0
  report (count learners with [group = 0 and learning-strategy = "PT"]) /  (count learners with [group = 0])
end

to-report PT-1
  report (count learners with [group = 1 and learning-strategy = "PT"]) /  (count learners with [group = 1])
end
@#$#@#$#@
GRAPHICS-WINDOW
257
19
661
424
-1
-1
9.66
1
10
1
1
1
0
1
1
1
-20
20
-20
20
0
0
1
ticks
30.0

BUTTON
53
17
119
50
NIL
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
126
17
189
50
NIL
go
T
1
T
OBSERVER
NIL
NIL
NIL
NIL
0

SLIDER
54
59
241
92
pop-size
pop-size
100
1000
100.0
10
1
NIL
HORIZONTAL

SLIDER
54
97
241
130
freq-big-group
freq-big-group
.1
1
0.5
.05
1
NIL
HORIZONTAL

SLIDER
55
180
240
213
num-learning-models
num-learning-models
1
100
5.0
1
1
NIL
HORIZONTAL

SWITCH
124
446
251
479
conformism?
conformism?
1
1
-1000

SWITCH
123
483
252
516
payoff-bias?
payoff-bias?
1
1
-1000

SLIDER
52
295
247
328
mutation-learn
mutation-learn
0
.1
0.0
.001
1
NIL
HORIZONTAL

SLIDER
54
256
249
289
mutation-parochialism
mutation-parochialism
0
.1
0.01
.001
1
NIL
HORIZONTAL

PLOT
662
19
1097
214
Reliance on social learning
time
Avg reliance
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"group 0" 1.0 0 -13791810 true "" "if update-plots? and (ticks mod ticks-to-update = 0) [ \nplotxy ticks avg-reliance-0 ]"
"group 1" 1.0 0 -955883 true "" "if update-plots? and (ticks mod ticks-to-update = 0) [ \nplotxy ticks avg-reliance-1 ]"

SLIDER
54
135
242
168
theta-dist-traits
theta-dist-traits
0
180
0.0
1
1
NIL
HORIZONTAL

SLIDER
54
218
239
251
sigma-indiv-learning
sigma-indiv-learning
0
3
1.0
.1
1
NIL
HORIZONTAL

SLIDER
50
366
252
399
sigma-social-learn-reliance
sigma-social-learn-reliance
0
1
0.05
.05
1
NIL
HORIZONTAL

SLIDER
68
406
240
439
selection-intensity
selection-intensity
0
1
0.5
.01
1
NIL
HORIZONTAL

SLIDER
51
330
249
363
mutation-reliance
mutation-reliance
0
.1
0.01
.001
1
NIL
HORIZONTAL

BUTTON
194
17
249
50
go once
go
NIL
1
T
OBSERVER
NIL
NIL
NIL
NIL
1

PLOT
662
216
1097
424
Parochialism
time
Freq parochialism
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"group 0" 1.0 0 -13791810 true "" "if update-plots? and (ticks mod ticks-to-update = 0)[ \nplotxy ticks freq-parochial-social-learning-0 ]"
"group 1" 1.0 0 -955883 true "" "if update-plots? and (ticks mod ticks-to-update = 0)[ \nplotxy ticks freq-parochial-social-learning-1 ]"

PLOT
662
426
1097
613
Payoffs
time
Avg payoff
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"group 0" 1.0 0 -13791810 true "" "if update-plots? and (ticks mod ticks-to-update = 0)[ \nplotxy ticks avg-payoff-0 ]"
"group 1" 1.0 0 -955883 true "" "if update-plots? and (ticks mod ticks-to-update = 0)[ \nplotxy ticks avg-payoff-1 ]"

SWITCH
85
523
228
556
update-plots?
update-plots?
0
1
-1000

SLIDER
118
559
246
592
ticks-to-update
ticks-to-update
1
100
20.0
1
1
NIL
HORIZONTAL

PLOT
259
433
459
583
Learning Strategy - Group 0
time
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"UT" 1.0 0 -408670 true "" "plot UT-0"
"CT" 1.0 0 -817084 true "" "plot CT-0"
"PT" 1.0 0 -6995700 true "" "plot PT-0"

PLOT
463
433
663
583
Learning Strat - Group 1
time
NIL
0.0
10.0
0.0
1.0
true
true
"" ""
PENS
"UT" 1.0 0 -5516827 true "" "plot UT-1"
"CT" 1.0 0 -11033397 true "" "plot CT-1"
"PT" 1.0 0 -14985354 true "" "plot PT-1"

SLIDER
25
407
58
562
identity-correlation
identity-correlation
0
1
0.0
.01
1
NIL
VERTICAL

@#$#@#$#@
## WHAT IS IT?

(a general understanding of what the model is trying to show or explain)

## HOW IT WORKS

(what rules the agents use to create the overall behavior of the model)

## HOW TO USE IT

(how to use the model, including a description of each of the items in the Interface tab)

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

(a reference to the model's URL on the web if it has one, as well as any other necessary credits, citations, and links)
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
NetLogo 6.3.0
@#$#@#$#@
@#$#@#$#@
@#$#@#$#@
<experiments>
  <experiment name="exp01-indiv-learn-uncertain" repetitions="100" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <metric>avg-reliance-0</metric>
    <metric>avg-reliance-1</metric>
    <metric>freq-parochial-social-learning-0</metric>
    <metric>freq-parochial-social-learning-1</metric>
    <metric>avg-payoff-0</metric>
    <metric>avg-payoff-1</metric>
    <enumeratedValueSet variable="mutation-parochialism">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma-social-learn-reliance">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-learn">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ticks-to-update">
      <value value="20"/>
    </enumeratedValueSet>
    <steppedValueSet variable="sigma-indiv-learning" first="0" step="0.05" last="3"/>
    <enumeratedValueSet variable="selection-intensity">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="update-plots?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="freq-big-group">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-learning-models">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="payoff-bias?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="conformism?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="theta-dist-traits">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-reliance">
      <value value="0"/>
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="identity-correlation">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="exp02-social-learn-uncorrelated" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <metric>avg-reliance-0</metric>
    <metric>avg-reliance-1</metric>
    <metric>avg-payoff-0</metric>
    <metric>avg-payoff-1</metric>
    <enumeratedValueSet variable="mutation-parochialism">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma-social-learn-reliance">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-learn">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ticks-to-update">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma-indiv-learning">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="selection-intensity">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="update-plots?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="freq-big-group">
      <value value="0.5"/>
      <value value="0.6"/>
      <value value="0.7"/>
      <value value="0.8"/>
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-learning-models">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="payoff-bias?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="conformism?">
      <value value="false"/>
    </enumeratedValueSet>
    <steppedValueSet variable="theta-dist-traits" first="0" step="5" last="180"/>
    <enumeratedValueSet variable="mutation-reliance">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="identity-correlation">
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="exp03-parochial-social-learn-uncorrelated-onemodel" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <metric>avg-reliance-0</metric>
    <metric>avg-reliance-1</metric>
    <metric>avg-payoff-0</metric>
    <metric>avg-payoff-1</metric>
    <metric>freq-parochial-social-learning-0</metric>
    <metric>freq-parochial-social-learning-1</metric>
    <enumeratedValueSet variable="mutation-parochialism">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma-social-learn-reliance">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-learn">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ticks-to-update">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma-indiv-learning">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="selection-intensity">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="update-plots?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="freq-big-group">
      <value value="0.5"/>
      <value value="0.7"/>
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-learning-models">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="payoff-bias?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="conformism?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="theta-dist-traits">
      <value value="0"/>
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
      <value value="20"/>
      <value value="30"/>
      <value value="45"/>
      <value value="60"/>
      <value value="75"/>
      <value value="90"/>
      <value value="120"/>
      <value value="150"/>
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-reliance">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="identity-correlation">
      <value value="0"/>
      <value value="0.25"/>
      <value value="0.5"/>
      <value value="0.75"/>
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="exp03-parochial-social-learn-uncorrelated-fivemodels-test" repetitions="10" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="100"/>
    <metric>avg-reliance-0</metric>
    <metric>avg-reliance-1</metric>
    <metric>avg-payoff-0</metric>
    <metric>avg-payoff-1</metric>
    <metric>freq-parochial-social-learning-0</metric>
    <metric>freq-parochial-social-learning-1</metric>
    <enumeratedValueSet variable="mutation-parochialism">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma-social-learn-reliance">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-learn">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ticks-to-update">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma-indiv-learning">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="selection-intensity">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="update-plots?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="freq-big-group">
      <value value="0.5"/>
      <value value="0.7"/>
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-learning-models">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="payoff-bias?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="conformism?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="theta-dist-traits">
      <value value="0"/>
      <value value="15"/>
      <value value="30"/>
      <value value="60"/>
      <value value="90"/>
      <value value="120"/>
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-reliance">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="identity-correlation">
      <value value="0"/>
      <value value="0.5"/>
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
  <experiment name="exp03a-parochial-social-learn-uncorrelated-fivemodels" repetitions="100" sequentialRunOrder="false" runMetricsEveryStep="false">
    <setup>setup</setup>
    <go>go</go>
    <timeLimit steps="10000"/>
    <metric>avg-reliance-0</metric>
    <metric>avg-reliance-1</metric>
    <metric>avg-payoff-0</metric>
    <metric>avg-payoff-1</metric>
    <metric>freq-parochial-social-learning-0</metric>
    <metric>freq-parochial-social-learning-1</metric>
    <enumeratedValueSet variable="mutation-parochialism">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma-social-learn-reliance">
      <value value="0.05"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-learn">
      <value value="0"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="ticks-to-update">
      <value value="20"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="sigma-indiv-learning">
      <value value="1"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="selection-intensity">
      <value value="0.5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="update-plots?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="freq-big-group">
      <value value="0.5"/>
      <value value="0.7"/>
      <value value="0.9"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="num-learning-models">
      <value value="5"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="payoff-bias?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="pop-size">
      <value value="100"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="conformism?">
      <value value="false"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="theta-dist-traits">
      <value value="0"/>
      <value value="5"/>
      <value value="10"/>
      <value value="15"/>
      <value value="20"/>
      <value value="30"/>
      <value value="45"/>
      <value value="60"/>
      <value value="75"/>
      <value value="90"/>
      <value value="120"/>
      <value value="150"/>
      <value value="180"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="mutation-reliance">
      <value value="0.01"/>
    </enumeratedValueSet>
    <enumeratedValueSet variable="identity-correlation">
      <value value="0"/>
      <value value="0.25"/>
      <value value="0.5"/>
      <value value="0.75"/>
      <value value="1"/>
    </enumeratedValueSet>
  </experiment>
</experiments>
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

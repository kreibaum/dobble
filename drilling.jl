# Analysis for the Dobble Drilling variant. (Drilling = Triplet)
# In this variant, there are 9 open dobble cards and a player has to find three
# cards which share a symbol. They then take the three cards and three new cards
# are added to the game.

# https://en.wikipedia.org/wiki/Dobble

# This is using a projective space over Z/7Z, cards correspond to points and
# symbols correspond to lines.

using JuMP
import GLPK

# Question: How many cards can we choose such that no Drilling appears?

maximumOnALine = 2

model = Model(GLPK.Optimizer)

# Regular points
@variable(model, p[1:7, 1:7], Bin)

# Infinite points, on slope (1, d)
@variable(model, pi[1:7], Bin)

# Infinite infinite on slope (0, 1)
@variable(model, pii, Bin)

# Lines are Constraints
# There is the infinite line which does not touch any regular point
@constraint(model, sum(pi) + pii <= maximumOnALine)

# Then there are lines with a delta of (0, 1) through p[x, 1] and pii
for x in 1:7
    @constraint(model, sum(p[x, 1:7]) + pii <= maximumOnALine)
end

# # All other lines have a slope of (1, d), start at p[1, y] and go through pi[d]

for y in 1:7, d in 0:6
    line = pi[(d + 6) % 7 + 1]
    for t in 0:6
        line = line + p[1 + t, (y + t * d - 1) % 7 + 1]
    end
    @constraint(model, line <= maximumOnALine)
end

# Now the objective is to place as many cards as possible

@objective(model, Max, sum(p) + sum(pi) + pii)

@show "Starting to optimize"

optimize!(model)

@show termination_status(model)
@show objective_value(model)

# Running this shows, that there is a possibility to choose 8 cards such that
# no Drilling occurs, but that this is also optimal. This means 9 cards always
# have a Drilling.

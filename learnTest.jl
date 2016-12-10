println("Samuel Colbran - CS238 Final Project")
if length(ARGS) < 1
	println("Usage: julia evaluate.jl <input csv file>")
	exit(1)
end
csv = ARGS[1]
println("Using ", csv, " as input csv")
#-------------------------------------------------------

# Load the BayesNets library [includes readtable]
println("Loading BayesNets")

# Change this line to configure which version you want to use
include("BayesNets.jl/src/BayesNets.jl")
using BayesNets # Install using Pkg.add("BayesNets")
import LightGraphs: is_cyclic, in_neighbors

# Load the CSV
println("Reading CSV")
input = readtable(csv)
n = length(input)
function findsymbol(sym, names) 
	i = 1
	while i <= length(names)
		if string(names[i]) == strip(string(sym))
			return i
		end
		i += 1
	end
	return 0
end

##### GreedyHillClimbing #####
function runGreedy()
	params = GreedyHillClimbing(ScoreComponentCache(input), max_n_parents=n, prior=UniformPrior())
	bn = fit(DiscreteBayesNet, input, params)
end
runGreedy() # Run once to force compile

# Evaluate
tic()
runGreedy()
toc()

##### K2Search #####
#=
function runK2()
	params = K2GraphSearch(names(input), 
                       ConditionalLinearGaussianCPD,
                       max_n_parents=2)

	#params = K2GraphSearch(ScoreComponentCache(input), max_n_parents=n, prior=UniformPrior())
	bn = fit(DiscreteBayesNet, input, params)
end
runK2() # Run once to force compile

# Evaluate
tic()
runK2()
toc()
=#
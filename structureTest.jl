println("Samuel Colbran - CS238 Final Project")
if length(ARGS) < 1
	println("Usage: julia project1.jl <input csv file>")
	exit(1)
end
csv = ARGS[1]
println("Using ", csv, " as input file")
#-------------------------------------------------------

# Load the BayesNets library [includes readtable]
println("Loading BayesNets")

include("BayesNets.jl/src/BayesNets.jl")
using .BayesNets # Install using Pkg.add("BayesNets")


# Load the CSV
println("Reading CSV")
data = readtable(csv)


# Custom cache
println(ncol(data))
function ScoreComponentHashCache(data::DataFrame)
    cache = Array(PriorityQueue{Vector{Int}, Float64}, ncol(data))
    for i in 1 : ncol(data)
        cache[i] = PriorityQueue{Vector{Int}, Float64, Base.Order.ForwardOrdering}()
    end
    cache
end

function profile_test(n)
	# Fit parameters using various techniques
	println("Using ScanGreedyHillClimbing")
	tic();
	#params = GreedyHillClimbing(ScoreComponentCache(data), max_n_parents=2, prior=UniformPrior())
    params = ScanGreedyHillClimbing(ScoreComponentCache(data), max_n_parents=10, max_depth=1, prior=UniformPrior())
	bn = fit(DiscreteBayesNet, data, params)
	toc()
	
	# Output the score
	#println("GreedyHillClimbing score: ", bayesian_score(bn, data, params.prior))
end

profile_test(50)  # run once to trigger compilation
Profile.clear()  # in case we have any previous profiling data
@profile profile_test(50)

using ProfileView
ProfileView.view()
ProfileView.svgwrite("profile_results.svg")

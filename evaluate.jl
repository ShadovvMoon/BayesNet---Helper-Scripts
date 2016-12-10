println("Samuel Colbran - CS238 Final Project")
if length(ARGS) < 2
	println("Usage: julia evaluate.jl <input csv file> <input structure file>")
	exit(1)
end
csv = ARGS[1]
println("Using ", csv, " as input csv")
dag = ARGS[2]
println("Using ", dag, " as input structure")
#-------------------------------------------------------

# Load the BayesNets library [includes readtable]
println("Loading BayesNets")

include("BayesNets.jl/src/BayesNets.jl")
using BayesNets # Install using Pkg.add("BayesNets")
import LightGraphs: is_cyclic, in_neighbors

#.BayesNets #elapsed time: 41.613779745 seconds [max 18GB], CACHEBOUND: 30.417170324 secbonds
# BayesNets #elapsed time: 50.485258152 seconds [max 18], CACHEBOUND: 22.609605939

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

function evaluate(dag) 
	g = DAG(n)
	if !(isfile(dag))
		return "NE" # graph file does not exist.
	end
	f = open(dag)
	for line in eachline(f)
		gm = split(rstrip(line), ",")
		if length(gm) != 2 
			return "IG" # invalid graph
		end
		se = findsymbol(gm[1], names(input))
		ee = findsymbol(gm[2], names(input))
		if se == 0
			#println("Invalid symbol ", gm[1])
			return "IG" # invalid symbol
		elseif ee == 0
			#println("Invalid symbol ", gm[2])
			return "IG" # invalid symbol
		end
		add_edge!(g, se, ee)
	end
	close(f)

	# Does the graph contain cycles?
	if is_cyclic(g)
		return "IG" # invalid symbol
	end

	# Will this graph explode the server?
	for i in 1:n
		if length(in_neighbors(g, i)) > 10
			return "ER" 
		end
	end

	# Compute score
	bayesian_score(g, names(input), input) 
end

if isdir(dag)
	cache = ScoreComponentCache(input)
	files = readdir(dag)
	if length(files) > 0
		evaluate(joinpath(dag, files[1])) #compile
		tic()
		for file in files
			println(file, ": ", evaluate(joinpath(dag, file)))
		end
		toc()
	end
else
	tic()
	println(evaluate(dag))
	toc()
end


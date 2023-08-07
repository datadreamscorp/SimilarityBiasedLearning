### A Pluto.jl notebook ###
# v0.19.19

using Markdown
using InteractiveUtils

# ╔═╡ d22575c8-8ac4-4667-b9a9-cb05b44ec0e2
begin
	using Pkg
	Pkg.activate("..")
	using Revise
	using StatsBase, Random, Distributions, Agents, Plots
	import SimilarityBiasedLearning as sl
end

# ╔═╡ b2594d1b-dabc-4928-8de9-bd1de34b9521
md"
# The evolution of similarity-biased social learning
#### Paul E. Smaldino & Alejandro Pérez Velilla
"

# ╔═╡ 9dee2817-576a-4400-815f-e96d7769f958
model = sl.initialize_similarity_learning(
	N=50,
	theta=180, 
	f=0.5, 
	sigma_l=0.5, 
	n=5, 
	mu_r=0.05, 
	sigma_r=0.05, 
	mu_p=0.05,
	sigma_p=0.05,
	S=0.05,
	strategies=[1,2],
	mu_l=0.01,
	true_random=true
)

# ╔═╡ 579f2992-899b-4103-8579-4fa3a1c205be
for t in 1:10000
	sl.model_step!(model)
end

# ╔═╡ d136203d-5981-45e3-ab03-4152a032d6e3
begin
	model.H1 = (1.0, 0.0)
	#model.sigma_l = 0.01
	for t in 1:5000
		sl.model_step!(model)
	end
end

# ╔═╡ 177f883d-2bd5-4b93-b29f-b025edaea38a
begin
	plot(
		model.mean_social, 
		label="mean reliance on soclearn",
		xlab="time"
	)
	plot!(
		model.mean_parochial,
		label="mean similarity bias"
	)
end

# ╔═╡ 5249f71a-df66-4662-aa2e-e93c4e91e454
begin
	soclearn_groups = plot(
		model.mean_social_g0, 
		label="group 0",
		xlab="time",
		ylab="reliance on social learning"  
	)
	plot!(
		model.mean_social_g1,
		label="group 1"
	)

	parochialism_groups = plot(
		model.mean_parochial_g0, 
		label="group 0",
		xlab="time",
		ylab="similarity bias",
		legend=false,
	)
	plot!(
		model.mean_parochial_g1,
		label="group 1"
	)

	payoff_groups = plot(
		model.mean_payoff_g0, 
		label="group 0",
		xlab="time",
		ylab="mean payoff",
		legend=false,
	)
	plot!(
		model.mean_payoff_g1,
		label="group 1"
	)

	plot(
		plot(soclearn_groups, parochialism_groups), 
		payoff_groups, 
		size=(700,400),
		layout=(2,1)
	)
end

# ╔═╡ 400eb9ae-42a8-4335-9679-0688e87bf3f0
plot(
	model.prop_unbiased,
	xlab="time",
	label="prop. unbiased"
)

# ╔═╡ Cell order:
# ╟─d22575c8-8ac4-4667-b9a9-cb05b44ec0e2
# ╟─b2594d1b-dabc-4928-8de9-bd1de34b9521
# ╠═9dee2817-576a-4400-815f-e96d7769f958
# ╠═579f2992-899b-4103-8579-4fa3a1c205be
# ╠═d136203d-5981-45e3-ab03-4152a032d6e3
# ╟─177f883d-2bd5-4b93-b29f-b025edaea38a
# ╟─5249f71a-df66-4662-aa2e-e93c4e91e454
# ╟─400eb9ae-42a8-4335-9679-0688e87bf3f0

### A Pluto.jl notebook ###
# v0.19.27

using Markdown
using InteractiveUtils

# ╔═╡ d22575c8-8ac4-4667-b9a9-cb05b44ec0e2
begin
	using Pkg
	Pkg.activate("..")
	#Pkg.instantiate()
	using Revise
	using StatsBase, Random, Distributions, Agents, Plots
	#import SimilarityBiasedLearning as sl
	include("../src/similarity_bias_ABM.jl")
end

# ╔═╡ b2594d1b-dabc-4928-8de9-bd1de34b9521
md"
# The evolution of similarity-biased social learning
#### Paul E. Smaldino & Alejandro Pérez Velilla
"

# ╔═╡ 9dee2817-576a-4400-815f-e96d7769f958
model = initialize_similarity_learning(
	N=200,
	theta=180.0, 
	f=0.5, 
	sigma_l=0.5, 
	n=15,
	mu_r=0.05, 
	sigma_r=0.05, 
	mu_p=0.05,
	sigma_p=0.05,
	S=0.5,
	#strategies="UL",
	#strategies="UL&CB",
	#strategies="UL&PB",
	strategies="ALLTHREE",
	mu_l=0.05,
	ID_corr=0.5,
	true_random=true,
	total_ticks=10000
)

# ╔═╡ 579f2992-899b-4103-8579-4fa3a1c205be
for t in 1:10000
	model_step!(model)
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
		ylab="social learning",
		color="blue"
	)
	plot!(
		model.mean_social_g1,
		label="group 1",
		color="red"
	)

	parochialism_groups = plot(
		model.mean_parochial_g0, 
		label="group 0",
		xlab="time",
		ylab="similarity bias",
		legend=false,
		color="blue"
	)
	plot!(
		model.mean_parochial_g1,
		label="group 1",
		color="red"
	)

	payoff_groups = plot(
		model.mean_payoff_g0, 
		label="group 0",
		xlab="time",
		ylab="mean payoff",
		legend=false,
		color="blue"
	)
	plot!(
		model.mean_payoff_g1,
		label="group 1",
		color="red"
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
	label="prop. unbiased",
	ylim=(0.0, 1.0)
)

# ╔═╡ a06c1fd9-79c2-418d-9427-5b001484f888
begin
	plot(
		model.prop_unbiased_g0,
		xlab="time",
		label="prop. unbiased in group 0",
		ylim=(0.0, 1.0)
	)
	
	plot!(
		model.prop_unbiased_g1,
		#xlab="time",
		label="prop. unbiased in group 1",
		ylim=(0.0, 1.0)
	)
	
end

# ╔═╡ 53063075-8f92-4b08-8a28-fe1d03120d38
md"""
Unbiased transmission
"""

# ╔═╡ 5a7ab6db-b6e0-4b84-9bd4-a6f910bc62c9
prop_unbiased = last(model.prop_unbiased)

# ╔═╡ f48a2325-658a-49de-b387-917a9141c94f
corr_unbiased_social = model.corr_unbiased_social

# ╔═╡ 90da973f-8a96-4399-b2c6-4074ae3fd896
corr_unbiased_parochial = model.corr_unbiased_parochial

# ╔═╡ 7a17a596-0d68-402d-a1c2-c38110e7e65c
md"""
Conformist transmission
"""

# ╔═╡ 7df24664-a5ac-48cf-8851-5997018f3a4e
prop_conformist = last(model.prop_conformist)

# ╔═╡ d876d3c6-6b95-4f4e-8c68-acfa84e8775a
corr_conformist_social = model.corr_conformist_social

# ╔═╡ bc9a6cb0-2a09-45e8-84d5-47bb067f45f0
corr_conformist_parochial = model.corr_conformist_parochial

# ╔═╡ 9a005a58-7b57-44a6-a575-710e32a8e183
md"""
Payoff-biased transmission
"""

# ╔═╡ 559532b2-4da3-4f1b-a233-f2597a25b4f8
prop_payoff = last(model.prop_payoff)

# ╔═╡ 15ba57df-9cb8-4b6f-bd36-47db21cf9fd5
corr_payoff_social = model.corr_payoff_social

# ╔═╡ a3a38d9d-8147-46b0-8f43-7a2310bdc80a
corr_payoff_parochial = model.corr_payoff_parochial

# ╔═╡ Cell order:
# ╟─d22575c8-8ac4-4667-b9a9-cb05b44ec0e2
# ╟─b2594d1b-dabc-4928-8de9-bd1de34b9521
# ╠═9dee2817-576a-4400-815f-e96d7769f958
# ╠═579f2992-899b-4103-8579-4fa3a1c205be
# ╠═d136203d-5981-45e3-ab03-4152a032d6e3
# ╟─177f883d-2bd5-4b93-b29f-b025edaea38a
# ╟─5249f71a-df66-4662-aa2e-e93c4e91e454
# ╟─400eb9ae-42a8-4335-9679-0688e87bf3f0
# ╟─a06c1fd9-79c2-418d-9427-5b001484f888
# ╟─53063075-8f92-4b08-8a28-fe1d03120d38
# ╟─5a7ab6db-b6e0-4b84-9bd4-a6f910bc62c9
# ╟─f48a2325-658a-49de-b387-917a9141c94f
# ╟─90da973f-8a96-4399-b2c6-4074ae3fd896
# ╟─7a17a596-0d68-402d-a1c2-c38110e7e65c
# ╟─7df24664-a5ac-48cf-8851-5997018f3a4e
# ╟─d876d3c6-6b95-4f4e-8c68-acfa84e8775a
# ╟─bc9a6cb0-2a09-45e8-84d5-47bb067f45f0
# ╟─9a005a58-7b57-44a6-a575-710e32a8e183
# ╟─559532b2-4da3-4f1b-a233-f2597a25b4f8
# ╟─15ba57df-9cb8-4b6f-bd36-47db21cf9fd5
# ╟─a3a38d9d-8147-46b0-8f43-7a2310bdc80a

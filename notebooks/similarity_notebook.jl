### A Pluto.jl notebook ###
# v0.20.6

using Markdown
using InteractiveUtils

# ╔═╡ b2594d1b-dabc-4928-8de9-bd1de34b9521
begin
	using Pkg
	Pkg.activate("..")
	using Revise
	using StatsBase, Random, Distributions, Agents, Plots
	import SimilarityBiasedLearning as sl
	
	function plot_stats(model; plot_title="", labs=true, labelfontsize=7, legend=true)
		
		soclearn_groups = plot(
			model.mean_social_g0, 
			label="group 0",
			xlab="time",
			ylab="social learning",
			color="pink",
			legend=false,
			title=plot_title,
			titlelocation=:left
		)
		plot!(
			model.mean_social_g1,
			label="group 1",
			color="dark blue",
			alpha=0.75
		)
	
		parochialism_groups = plot(
			model.mean_parochial_g0, 
			label="group 0",
			xlab="time",
			ylab="similarity bias",
			legend=false,
			color="pink"
		)
		plot!(
			model.mean_parochial_g1,
			label="group 1",
			color="dark blue",
			alpha=0.75
		)
	
		payoff_groups = plot(
			model.mean_payoff_g0, 
			label="group 0",
			xlab="time",
			ylab="mean payoff",
			legend= legend ? :topleft : false,
			color="pink"
		)
		plot!(
			model.mean_payoff_g1,
			label="group 1",
			color="dark blue",
			alpha=0.75
		)
	
	
		unbiased_plot = plot(
			model.prop_unbiased_g0,
			#xlab="time",
			label="group 0",
			ylim=(0.0, 1.0),
			color="pink",
			legend=false,
			ylab="prop. unbiased",
			dpi=300
		)
		plot!(
			model.prop_unbiased_g1,
			#xlab="time",
			label="group 1",
			ylim=(0.0, 1.0),
			color="dark blue",
			alpha=0.75
		)
	
		
		comp_plot = plot(
			plot(soclearn_groups, parochialism_groups), 
			unbiased_plot, payoff_groups, 
			#size=(700,500),
			layout=(3,1),
			dpi=300,
			#plot_title=plot_title,
			plot_titlefontsize=20,
			labelfontsize=labelfontsize,
			tickfontsize=3,
			legendfontsize=5
		)
	
		return comp_plot
		
	end
	
md"
# The evolution of similarity-biased social learning
#### Paul E. Smaldino & Alejandro Pérez Velilla
"
end

# ╔═╡ e96b4c35-632f-463f-9b32-ef491f71b1ab
md"""
### Playground area (have fun!)
"""

# ╔═╡ c7330a46-b50b-4a17-9a0c-1e9a8aa04faa
begin
	#SET PARAMETERS HERE
	N=200; theta=180.0; f=0.5; sigma_l=0.3;
	n=5; mu_r=0.05; sigma_r=0.05;
	mu_p=0.05; sigma_p=0.05; S=0.05;
	strategies="UL&PB"; mu_l=0.05; ID_corr=0.75
	true_random=false; total_ticks=10000;
end

# ╔═╡ 92e1c8de-d9e8-41c1-aeb5-50c6db42b16a
# ╠═╡ skip_as_script = true
#=╠═╡
begin
	#evolution of payoff bias
	play_model = sl.initialize_similarity_learning(
		N=N,
		theta=theta, 
		f=f, 
		sigma_l=sigma_l, 
		n=n,
		mu_r=mu_r, 
		sigma_r=sigma_r, 
		mu_p=mu_p,
		sigma_p=sigma_p,
		S=S,
		strategies=strategies,
		mu_l=mu_l,
		ID_corr=ID_corr,
		true_random=true_random,
		total_ticks=total_ticks,
		seed=153456
	)
	for t in 1:play_model.total_ticks
		sl.model_step!(play_model)
	end

	plot_stats(play_model)
end
  ╠═╡ =#

# ╔═╡ 0c24c2b8-f9c7-46e4-b752-1c8763be23c7
md"""
### Figure S3
Enable the following cells in order to replicate the supplemental figure 3.
"""

# ╔═╡ ff07f800-e569-4a3f-89bf-218b1f081820
# ╠═╡ disabled = true
#=╠═╡
begin
	#evolution of payoff bias
	model = initialize_similarity_learning(
		N=N,
		theta=theta, 
		f=f, 
		sigma_l=sigma_l, 
		n=n,
		mu_r=mu_r, 
		sigma_r=sigma_r, 
		mu_p=mu_p,
		sigma_p=sigma_p,
		S=S,
		strategies=strategies,
		mu_l=mu_l,
		ID_corr=0.75,
		true_random=true_random,
		total_ticks=total_ticks,
		seed=153456
	)
	for t in 1:model.total_ticks
		model_step!(model)
	end
end
  ╠═╡ =#

# ╔═╡ 9dee2817-576a-4400-815f-e96d7769f958
# ╠═╡ disabled = true
#=╠═╡
begin
	#payoff oscillation
	model02 = initialize_similarity_learning(
		N=N,
		theta=theta, 
		f=f, 
		sigma_l=sigma_l, 
		n=n,
		mu_r=mu_r, 
		sigma_r=sigma_r, 
		mu_p=mu_p,
		sigma_p=sigma_p,
		S=S,
		strategies=strategies,
		mu_l=mu_l,
		ID_corr=0.75,
		true_random=true_random,
		total_ticks=total_ticks,
		seed=1234976 
	)
	for t in 1:model02.total_ticks
		model_step!(model02)
	end
end
  ╠═╡ =#

# ╔═╡ 50558bb7-7844-49ab-be1c-0f91e951a582
# ╠═╡ disabled = true
#=╠═╡
begin
	#payoff divergence at R = 0.5
	model03 = initialize_similarity_learning(
		N=N,
		theta=theta, 
		f=f, 
		sigma_l=sigma_l, 
		n=n,
		mu_r=mu_r, 
		sigma_r=sigma_r, 
		mu_p=mu_p,
		sigma_p=sigma_p,
		S=S,
		strategies=strategies,
		mu_l=mu_l,
		ID_corr=0.5,
		true_random=true_random,
		total_ticks=total_ticks,
		seed=123497 
	)
	for t in 1:model03.total_ticks
		model_step!(model03)
	end
end
  ╠═╡ =#

# ╔═╡ 59a25695-b3e9-4bbd-bccb-5b5576fab0be
# ╠═╡ disabled = true
#=╠═╡
begin
	learningevo_plot = plot_stats(model, plot_title="A", legend=false)
	cycle_plot = plot_stats(model02, plot_title="B", legend=false)
	divergence_plot = plot_stats(model03, plot_title="C")
	
	complot = plot(
		learningevo_plot,
		cycle_plot,
		divergence_plot,
		layout=(1,3),
		dpi=600,
		size=(800, 600),
		link=:all
	)
end
  ╠═╡ =#

# ╔═╡ d807c3c1-167c-4fe9-81a5-cadbed9d8bab
# ╠═╡ disabled = true
#=╠═╡
savefig(complot, "composite_plot.pdf")
  ╠═╡ =#

# ╔═╡ Cell order:
# ╟─b2594d1b-dabc-4928-8de9-bd1de34b9521
# ╟─e96b4c35-632f-463f-9b32-ef491f71b1ab
# ╠═c7330a46-b50b-4a17-9a0c-1e9a8aa04faa
# ╟─92e1c8de-d9e8-41c1-aeb5-50c6db42b16a
# ╟─0c24c2b8-f9c7-46e4-b752-1c8763be23c7
# ╟─ff07f800-e569-4a3f-89bf-218b1f081820
# ╟─9dee2817-576a-4400-815f-e96d7769f958
# ╟─50558bb7-7844-49ab-be1c-0f91e951a582
# ╟─59a25695-b3e9-4bbd-bccb-5b5576fab0be
# ╟─d807c3c1-167c-4fe9-81a5-cadbed9d8bab

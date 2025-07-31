#############
#ANALYSIS 3.1
using Pkg
Pkg.activate("..")
using Distributed

@everywhere include("../src/similarity_bias_ABM.jl")

#@everywhere using CSV, Distributed
@everywhere using CSV, Agents, Random, Distributions, Statistics, StatsBase

@everywhere total_ticks = 1

@everywhere begin #INCLUDE MODEL CODE AND NECESSARY LIBRARIES

	parameters = Dict( #ALTER THIS DICTIONARY TO DEFINE PARAMETER DISTRIBUTIONS
	    :N => [50, 200],
		:mu_r => [0.0, 0.05], 
		:sigma_r => 0.05, 
		:mu_p => 0.0,
		:sigma_p => 0.0,
		:S => 0.05,
        :strategies => "UL",
		:n => 1,
        :theta => 0.0,
        :f => 0.0,
        :sigma_l => collect(0.0:0.01:0.5),
		:ID_corr => 1.0,
		:rep => collect(1:100),
		:true_random => true,
		:total_ticks => total_ticks
	)
	
	mdata = [
		:mean_payoff_final,
		:mean_payoff_g0_final,
		:mean_payoff_g1_final,
		:mean_social_final,
		:mean_social_g0_final,
		:mean_social_g1_final,
		:mean_parochial_final,
		:mean_parochial_g0_final,
		:mean_parochial_g1_final
	]

end

#USE THIS LINE AFTER DEFINITIONS TO BEGIN PARAMETER SCANNING
_, mdf = paramscan(
            parameters, initialize_similarity_learning;
            mdata=mdata,
            #agent_step! = dummystep,
        	#model_step! = model_step!,
            n = total_ticks,
			parallel=true,
			when_model = [total_ticks],
			showprogress = true
	)

CSV.write("../data/analysis_3_1.csv", mdf)

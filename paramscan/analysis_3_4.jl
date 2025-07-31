#############
#ANALYSIS 3.4
@everywhere using Pkg
@everywhere Pkg.activate("..")

@everywhere include("../src/similarity_bias_ABM.jl")

@everywhere using CSV, Distributed
@everywhere using Agents, Random, Distributions, Statistics, StatsBase

@everywhere total_ticks = 10000

@everywhere begin 

    parameters = Dict( #ALTER THIS DICTIONARY TO DEFINE PARAMETER DISTRIBUTIONS
        :N => [50, 200],
        :mu_r => 0.05, 
        :sigma_r => 0.05,
        :mu_p => [0.0, 0.05],
        :sigma_p => 0.05,
        :S => 0.05,
        :strategies => ["UL&CB", "UL&PB", "ALLTHREE"],
        :n => [1, 5, 15],
        :theta => collect(0.0:10.0:180.0),
        :f => collect(0.5:0.2:1.0),
        :sigma_l => [0.1, 0.3, 0.5],
        :ID_corr => collect(0.0:0.25:1.0),
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
		:mean_parochial_g1_final,
        :prop_unbiased_final,
        :prop_unbiased_g0_final,
        :prop_unbiased_g1_final,
        :prop_conformist_final,
        :prop_conformist_g0_final,
        :prop_conformist_g1_final,
        :prop_payoff_final,
        :prop_payoff_g0_final,
        :prop_payoff_g1_final,
        :corr_conformist_social,
        :corr_conformist_parochial,
        :corr_payoff_social,
	    :corr_payoff_parochial
	]

end

#USE THIS LINE AFTER DEFINITIONS TO BEGIN PARAMETER SCANNING
_, mdf = paramscan(
            parameters, initialize_similarity_learning;
            mdata=mdata,
            agent_step! = dummystep,
        	model_step! = model_step!,
            n = total_ticks,
			parallel=true,
			when_model = [total_ticks],
			showprogress = true
	)

CSV.write("../data/analysis_3_4.csv", mdf)

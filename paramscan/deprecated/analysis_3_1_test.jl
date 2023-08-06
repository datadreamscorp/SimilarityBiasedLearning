
@everywhere begin #INCLUDE MODEL CODE AND NECESSARY LIBRARIES
	using Pkg
	Pkg.activate(".")

	import SimilarityBiasedLearning as sl
    using Agents, Random, Distributions, Statistics, StatsBase

	total_ticks = 10

	parameters = Dict( #ALTER THIS DICTIONARY TO DEFINE PARAMETER DISTRIBUTIONS
	    :N => [100, 1000],
		:mu_p => 0.0,
        :mu_l => 0.0,
		:n => 1,
        :theta => 0.0,
        :f => 0.0,
        :sigma_l => collect(0.0:0.01:0.5),
        :mu_r => [0.0, 0.01],
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
            parameters, sl.initialize_similarity_learning;
            mdata=mdata,
            agent_step! = dummystep,
        	model_step! = sl.model_step!,
            n = total_ticks,
			parallel=true,
			when_model = collect(0:1:total_ticks),
			showprogress = true
	)

CSV.write("../data/analysis_3_1.csv", mdf)

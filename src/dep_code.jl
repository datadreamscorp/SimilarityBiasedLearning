Dict(
			:N => N,
			:N_total => N,
			:f => f,
			:ID_corr => ID_corr,
			:H0 => H0,
			:theta => theta,
			:H1 => ( cosd(theta), sind(theta) ),
			:n => n,
			:mu_ID => mu_ID,
			:mu_l => mu_l,
			:sigma_l => sigma_l,
			:mu_p => mu_p,
			:sigma_p => sigma_p,
			:mu_r => mu_r,
			:sigma_r => sigma_r,
			:S => S,
			:prop_parochial => prop_parochial,
			:strat_pool => strat_pool,
			:init_soc => init_soc,
			#data
			:mean_payoff => Vector{Float64}(),
			:mean_payoff_g0 => Vector{Float64}(),
			:mean_payoff_g1 => Vector{Float64}(),
			:mean_social => Vector{Float64}(),
			:mean_social_g0 => Vector{Float64}(),
			:mean_social_g1 => Vector{Float64}(),
			:mean_parochial => Vector{Float64}(),
			:mean_parochial_g0 => Vector{Float64}(),
			:mean_parochial_g1 => Vector{Float64}(),
			:prop_unbiased => Vector{Float64}(),
			:prop_unbiased_g1 => Vector{Float64}(),
			:prop_unbiased_g0 => Vector{Float64}(),
			:prop_conformist => Vector{Float64}(),
			:prop_conformist_g1 => Vector{Float64}(),
			:prop_conformist_g0 => Vector{Float64}(),
			:prop_payoff => Vector{Float64}(),
			:prop_payoff_g1 => Vector{Float64}(),
			:prop_payoff_g0 => Vector{Float64}(),
			:mean_payoff_final => 0.0,
			:mean_payoff_g0_final => 0.0,
			:mean_payoff_g1_final => 0.0,
			:mean_social_final => 0.0,
			:mean_social_g0_final => 0.0,
			:mean_social_g1_final => 0.0,
			:mean_parochial_final => 0.0,
			:mean_parochial_g0_final => 0.0,
			:mean_parochial_g1_final => 0.0,
			:prop_unbiased_final => 0.0,
			:prop_unbiased_g1_final => 0.0,
			:prop_unbiased_g0_final => 0.0,
			:prop_conformist_final => 0.0,
			:prop_conformist_g1_final => 0.0,
			:prop_conformist_g0_final => 0.0,
			:prop_payoff_final => 0.0,
			:prop_payoff_g1_final => 0.0,
			:prop_payoff_g0_final => 0.0,
			:tick => 1,
			:total_ticks => total_ticks,
			:rep => rep,
			:true_random => true_random,
			:seed => seed,
		)

        Base.@kwdef mutable struct Parameters
            N::Int = N
            N_total::Int = N
            f::Float64 = f
            ID_corr::Float64 = ID_corr
            H0::Tuple{Float64} = H0
            theta::Float64 = theta
            H1::Tuple{Float64} = ( cosd(theta), sind(theta) )
            n::Int = n
            mu_ID::Float64 = mu_ID
            mu_l::Float64 = mu_l
            sigma_l::Float64 = sigma_l
            mu_p::Float64 = mu_p
            sigma_p::Float64 = sigma_p
            mu_r::Float64 = mu_r
            sigma_r::Float64 = sigma_r
            S::Float64 = S
            prop_parochial::Float64 = prop_parochial
            init_soc::Float64 = init_soc
            strat_pool::Vector{Int} = strat_pool
            #data
            mean_payoff::Vector{Float64} = Vector{Float64}()
            mean_payoff_g0::Vector{Float64} = Vector{Float64}()
            mean_payoff_g1::Vector{Float64} = Vector{Float64}()
            mean_social::Vector{Float64} = Vector{Float64}()
            mean_social_g0::Vector{Float64} = Vector{Float64}()
            mean_social_g1::Vector{Float64} = Vector{Float64}()
            mean_parochial::Vector{Float64} = Vector{Float64}()
            mean_parochial_g0::Vector{Float64} = Vector{Float64}()
            mean_parochial_g1::Vector{Float64} = Vector{Float64}()
            prop_unbiased::Vector{Float64} = Vector{Float64}()
            prop_unbiased_g1::Vector{Float64} = Vector{Float64}()
            prop_unbiased_g0::Vector{Float64} = Vector{Float64}()
            prop_conformist::Vector{Float64} = Vector{Float64}()
            prop_conformist_g1::Vector{Float64} = Vector{Float64}()
            prop_conformist_g0::Vector{Float64} = Vector{Float64}()
            prop_payoff::Vector{Float64} = Vector{Float64}()
            prop_payoff_g1::Vector{Float64} = Vector{Float64}()
            prop_payoff_g0::Vector{Float64} = Vector{Float64}()
            mean_payoff_final::Float64 = 0.0
            mean_payoff_g0_final::Float64 = 0.0
            mean_payoff_g1_final::Float64 = 0.0
            mean_social_final::Float64 = 0.0
            mean_social_g0_final::Float64 = 0.0
            mean_social_g1_final::Float64 = 0.0
            mean_parochial_final::Float64 = 0.0
            mean_parochial_g0_final::Float64 = 0.0
            mean_parochial_g1_final::Float64 = 0.0
            prop_unbiased_final::Float64 = 0.0
            prop_unbiased_g1_final::Float64 = 0.0
            prop_unbiased_g0_final::Float64 = 0.0
            prop_conformist_final::Float64 = 0.0
            prop_conformist_g1_final::Float64 = 0.0
            prop_conformist_g0_final::Float64 = 0.0
            prop_payoff_final::Float64 = 0.0
            prop_payoff_g1_final::Float64 = 0.0
            prop_payoff_g0_final::Float64 = 0.0
            tick::Int = 1
            total_ticks::Int = total_ticks
            rep::Int = rep
            true_random::Bool = true_random
            seed::Int64 = seed
        end

        Base.@kwdef mutable struct Parameters
            N::Int64
            N_total::Int64
            f::Float64
            ID_corr::Float64 
            H0::Tuple{Float64, Float64}
            theta::Float64
            H1::Tuple{Float64, Float64}
            n::Int64
            mu_ID::Float64
            mu_l::Float64
            sigma_l::Float64
            mu_p::Float64
            sigma_p::Float64
            mu_r::Float64
            sigma_r::Float64
            S::Float64
            prop_parochial::Float64
            init_soc::Float64
            strat_pool::Vector{Int64}
            #data
            mean_payoff::Vector{Float64}
            mean_payoff_g0::Vector{Float64}
            mean_payoff_g1::Vector{Float64}
            mean_social::Vector{Float64}
            mean_social_g0::Vector{Float64}
            mean_social_g1::Vector{Float64}
            mean_parochial::Vector{Float64}
            mean_parochial_g0::Vector{Float64}
            mean_parochial_g1::Vector{Float64}
            prop_unbiased::Vector{Float64}
            prop_unbiased_g1::Vector{Float64}
            prop_unbiased_g0::Vector{Float64}
            prop_conformist::Vector{Float64}
            prop_conformist_g1::Vector{Float64}
            prop_conformist_g0::Vector{Float64}
            prop_payoff::Vector{Float64}
            prop_payoff_g1::Vector{Float64}
            prop_payoff_g0::Vector{Float64}
            mean_payoff_final::Float64
            mean_payoff_g0_final::Float64
            mean_payoff_g1_final::Float64
            mean_social_final::Float64
            mean_social_g0_final::Float64
            mean_social_g1_final::Float64
            mean_parochial_final::Float64
            mean_parochial_g0_final::Float64
            mean_parochial_g1_final::Float64
            prop_unbiased_final::Float64
            prop_unbiased_g1_final::Float64
            prop_unbiased_g0_final::Float64
            prop_conformist_final::Float64
            prop_conformist_g1_final::Float64
            prop_conformist_g0_final::Float64
            prop_payoff_final::Float64
            prop_payoff_g1_final::Float64
            prop_payoff_g0_final::Float64
            tick::Int64
            total_ticks::Int64
            rep::Int64
            true_random::Bool
            seed::Int64
        end

        properties = Parameters(
		N,
		N,
		f,
		ID_corr,
		H0,
		theta,
		( cosd(theta), sind(theta) ),
		n,
		mu_ID,
		mu_l,
		sigma_l,
		mu_p,
		sigma_p,
		mu_r,
		sigma_r,
		S,
		prop_parochial,
		init_soc,
		strat_pool,
	#data
		Vector{Float64}(),
		Vector{Float64}(),
		Vector{Float64}(),
		Vector{Float64}(),
		Vector{Float64}(),
		Vector{Float64}(),
		Vector{Float64}(),
		Vector{Float64}(),
		Vector{Float64}(),
		Vector{Float64}(),
		Vector{Float64}(),
		Vector{Float64}(),
		Vector{Float64}(),
		Vector{Float64}(),
		Vector{Float64}(),
		Vector{Float64}(),
		Vector{Float64}(),
		Vector{Float64}(),
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		0.0,
		1,
		total_ticks,
		rep,
		true_random,
		seed
	)
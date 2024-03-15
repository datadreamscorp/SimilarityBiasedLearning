using StatsBase, Random, Distributions, Agents

#
@agent Learner NoSpaceAgent begin
	#Heritable characteristics
	group::Int64
	groupID::Int64
	indiv_coor::Tuple{Float64, Float64}
	social_coor::Tuple{Float64, Float64}
	parochial::Float64
	soc::Float64
	learning_strategy::Int64
	#Dynamic characteristics
	payoff::Float64
	trait::Tuple{Float64, Float64}
	old::Bool
	models::Vector{Any}
	p_rep::Float64
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
	corr_unbiased_parochial::Float64
	corr_unbiased_social::Float64
	prop_conformist_final::Float64
	prop_conformist_g1_final::Float64
	prop_conformist_g0_final::Float64
	corr_conformist_parochial::Float64
	corr_conformist_social::Float64
	prop_payoff_final::Float64
	prop_payoff_g1_final::Float64
	prop_payoff_g0_final::Float64
	corr_payoff_parochial::Float64
	corr_payoff_social::Float64
	tick::Int64
	total_ticks::Int64
	rep::Int64
	true_random::Bool
	seed::Int64
end


#
function initialize_similarity_learning(;
	N = 100,
	f = 0.5,
	ID_corr = 1.0,
	H0 = (1.0, 0.0),
	theta = 0,
	n = 5,
	mu_ID = 0.0,
	mu_l = 0.01, #social learning strategy mutation rate
	sigma_l = 0.1, #individual learning error
	mu_p = 0.05,
	sigma_p = 0.05,
	mu_r = 0.05,
	sigma_r = 0.05,
	S = 0.05,
	prop_parochial = 0.0,
	init_soc = 0.0,
	strategies = "UL",
	true_random = false,
	seed = 123456789,
	total_ticks = 3000,
	rep = 1,
)
	rng = true_random ? RandomDevice() : MersenneTwister(seed)
	
	if strategies == "UL"
		strat_pool = [1]

	elseif strategies == "CB"
		strat_pool = [2]

	elseif strategies == "PB"
		strat_pool = [3]

	elseif strategies == "UL&CB"
		strat_pool = [1, 2]

	elseif strategies == "UL&PB"
		strat_pool = [1, 3]

	elseif strategies == "CB&PB"
		strat_pool = [2, 3]

	elseif strategies == "ALLTHREE"
		strat_pool = [1, 2, 3]

	else
		error(raw"Invalid learning strategy pool.")
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
	
	#=
	properties = Dict(
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
	=#

	model = ABM( 
		Learner, 
		nothing;
		properties = properties,
		rng
	)
	
	for a in 1:N
		
		group = rand(model.rng) < model.f ? 0 : 1
		
		groupID = rand(model.rng) < model.ID_corr ? group : ( rand(model.rng) < model.f ? 0 : 1 )
		
		if group == 0
			HI = ( 
				@inbounds model.H0[1] + rand( model.rng, Normal(0, model.sigma_l) ),
				@inbounds model.H0[2] + rand( model.rng, Normal(0, model.sigma_l) )
			)
		else
			HI = ( 
				@inbounds model.H1[1] + rand( model.rng, Normal(0, model.sigma_l) ),
				@inbounds model.H1[2] + rand( model.rng, Normal(0, model.sigma_l) )
			)
		end
		
		agent = Learner( 
			a,
			group, 
			groupID,
			HI,
			(0.0, 0.0),
			rand(model.rng) < model.prop_parochial ? 1.0 : 0.0,
			init_soc,
			sample(model.rng, model.strat_pool),
			0.0,
			HI,
			true,
			[],
			0.0,
		)
        new_a = add_agent!(agent, model)
		calculate_payoff!(new_a, model)
	end
		
	return model
		
end


function squared_distance(X::Tuple{Float64, Float64}, H::Tuple{Float64, Float64})
	return @inbounds (X[1] - H[1])^2 + (X[2] - H[2])^2
end

#
function calculate_payoff!(agent, model)
	X = agent.trait
	H = agent.group == 0 ? model.H0 : model.H1
	agent.payoff = exp( -squared_distance(X, H) / (2*model.S) )
end

#
function reproduction!(model)
	
	agents = shuffle(model.rng, allagents(model)|>collect)
	group0 = filter(a -> a.group == 0, agents)
	group1 = setdiff( agents, group0 )

	g0_n = length(group0)
	g1_n = length(group1)
	
	g0_payoffs = [a.payoff for a in group0]
	g1_payoffs = [a.payoff for a in group1]
	g0_max = g0_n != 0 ? maximum(g0_payoffs) : 0
	g1_max = g1_n != 0 ? maximum(g1_payoffs) : 0

	g0_weights = Vector{Float64}()
	for a in group0
		a.p_rep = a.payoff / g0_max
		push!(g0_weights, a.p_rep)
	end

	g1_weights = Vector{Float64}()
	for a in group1
		a.p_rep = a.payoff / g1_max
		push!(g1_weights, a.p_rep)
	end

	g0_w = Weights(g0_weights)
	g1_w = Weights(g1_weights)

	total_agents = model.N_total
	
	if g0_n > 0
		for i in (total_agents + 1):(total_agents + g0_n)
			HI = ( 
					@inbounds model.H0[1] + rand( model.rng, Normal(0, model.sigma_l) ),
					@inbounds model.H0[2] + rand( model.rng, Normal(0, model.sigma_l) )
				)

			parent = sample(model.rng, group0, g0_w)
			parentID = parent.groupID
			
			inh_parochialism = rand(model.rng) < 1 - model.mu_p ? parent.parochial : clamp( parent.parochial + rand(model.rng, Normal(0, model.sigma_p)), 0, 1 )

			inh_soclearn = rand(model.rng) < 1 - model.mu_r ? parent.soc : clamp( parent.soc + rand(model.rng, Normal(0, model.sigma_r)), 0, 1 )

			inh_strategy = rand(model.rng) < 1 - model.mu_l ? parent.learning_strategy : sample(model.rng, model.strat_pool)
			
			child = Learner(
				i,
				parent.group, 
				#rand(model.rng) < 1 - model.mu_ID ? parentID : ( rand(model.rng) < model.f ? 0 : 1 ),
				rand(model.rng) < model.ID_corr ? parent.group : ( rand(model.rng) < model.f ? 0 : 1 ),
				HI,
				(0.0, 0.0),
				inh_parochialism,
				inh_soclearn,
				inh_strategy,
				0.0,
				HI,
				false,
				[],
				0.0,
			)
			add_agent!(
				child,
				model
			)

			model.N_total += 1
		end
	end
	#total_agents = model.N_total
	
	if g1_n > 0
		for i in (total_agents + g0_n + 1):(total_agents + g0_n + g1_n)
			HI = ( 
					@inbounds model.H1[1] + rand( model.rng, Normal(0, model.sigma_l) ),
					@inbounds model.H1[2] + rand( model.rng, Normal(0, model.sigma_l) )
				)

			parent = sample(model.rng, group1, g1_w)
			parentID = parent.groupID
			
			inh_parochialism = rand(model.rng) < 1 - model.mu_p ? parent.parochial : clamp( parent.parochial + rand(model.rng, Normal(0, model.sigma_p)), 0, 1 )

			inh_soclearn = rand(model.rng) < 1 - model.mu_r ? parent.soc : clamp( parent.soc + rand(model.rng, Normal(0, model.sigma_r)), 0, 1 )

			inh_strategy = rand(model.rng) < 1 - model.mu_l ? parent.learning_strategy : sample(model.rng, model.strat_pool)
			
			child = Learner(
				i,
				parent.group, 
				#rand(model.rng) < 1 - model.mu_ID ? parentID : abs(parentID - 1),
				rand(model.rng) < model.ID_corr ? parent.group : ( rand(model.rng) < model.f ? 0 : 1 ),
				HI,
				(0.0, 0.0),
				inh_parochialism,
				inh_soclearn,
				inh_strategy,
				0.0,
				HI,
				false,
				[],
				0.0,
			)
			add_agent!(
				child,
				model
			)

			model.N_total += 1
		end
	end

end

#
function learning_stage!(model)

	agents = shuffle(model.rng, allagents(model)|>collect)
	new_generation = filter( a -> !(a.old), agents )
	olds = setdiff(agents, new_generation)
		
	for a in new_generation
		model_choice!(a, olds, model)
		if length(a.models) > 0
			learning!(a, model)
		end
	end
	
end

#
function model_choice!(learner, olds, model)

	#if rand(model.rng) < a.parochial
		#pot_models = filter( m -> m.old & (m.group == learner.group), agents )
	#else
		#pot_models = filter( m -> m.old & (m.group == learner.group), agents )
	#end

	#old_sample = olds
	
	pot_models = sample(model.rng, olds, model.n, replace=false)
	for m in pot_models
		if m.groupID == learner.groupID
			push!(learner.models, m)
		elseif rand(model.rng) < 1 - learner.parochial
			push!(learner.models, m)
		end
	end
	
end

#
function learning!(learner, model)

	s = learner.soc
	
	if learner.learning_strategy == 1 #unbiased

		rando = rand(model.rng, learner.models)
		learner.social_coor = rando.trait
		
	elseif learner.learning_strategy == 2 #conformity

		x_coor = [m.trait[1] for m in learner.models]
		y_coor = [m.trait[2] for m in learner.models]

		learner.social_coor = median.( (x_coor, y_coor) )
			
	else #payoff bias

		max_idx = findmax(m -> m.payoff, learner.models)[2]
		mods = learner.models
		#winner = sample(model.rng, mods[max_idx])
		winner = mods[max_idx]
		learner.social_coor = winner.trait
		
	end

	new_coor = ( (1 - s).*learner.indiv_coor ) .+ ( s.*learner.social_coor )

	learner.trait = (new_coor[1], new_coor[2])
	
end

#
function pass_the_torch!(model)
	agents = shuffle(model.rng, allagents(model)|>collect)
	olds = filter( a -> a.old, agents )
	news = setdiff(agents, olds)

	for old in olds
		kill_agent!(old, model)
	end

	for new in news
		new.old = true
	end
end

#
function model_step!(model)
	
	reproduction!(model)
	learning_stage!(model)
	pass_the_torch!(model)

	agents = allagents(model)|>collect
	for a in agents
		calculate_payoff!(a, model)
	end

	g0 = filter(a -> a.group == 0, agents)
	g1 = filter(a -> a.group == 1, agents)

	push!( model.mean_social_g0, mean([a.soc for a in g0]) )
	push!( model.mean_parochial_g0, mean([a.parochial for a in g0]) )
	push!( model.mean_payoff_g0, mean([a.payoff for a in g0]) )

	push!( model.mean_social_g1, mean([a.soc for a in g1]) )
	push!( model.mean_parochial_g1, mean([a.parochial for a in g1]) )
	push!( model.mean_payoff_g1, mean([a.payoff for a in g1]) )
	
	push!( model.mean_social, mean([a.soc for a in agents]) )
	push!( model.mean_parochial, mean([a.parochial for a in agents]) )
	push!( model.mean_payoff, mean([a.payoff for a in agents]) )

	if length(model.strat_pool) > 1

		unb = filter(a -> a.learning_strategy == 1, agents)
		conf = filter(a -> a.learning_strategy == 2, agents)
		pay = filter(a -> a.learning_strategy == 3, agents)

		push!(
			model.prop_unbiased, 
			length(unb) / model.N 
			)

		push!( 
			model.prop_unbiased_g0, 
			length(g0) > 0 ? length(filter(a -> a.learning_strategy == 1, g0)) / length(g0) : 0
			)

		push!( 
			model.prop_unbiased_g1, 
			length(g1) > 0 ? length(filter(a -> a.learning_strategy == 1, g1)) / length(g1) : 0
			)
		
		push!(
			model.prop_conformist, 
			length(conf) / model.N 
			)

		push!( 
			model.prop_conformist_g0, 
			length(g0) > 0 ? length(filter(a -> a.learning_strategy == 2, g0)) / length(g0) : 0
			)

		push!( 
			model.prop_conformist_g1, 
			length(g1) > 0 ? length(filter(a -> a.learning_strategy == 2, g1)) / length(g1) : 0
			)

		push!(
			model.prop_payoff, 
			length(pay) / model.N 
			)

		push!( 
			model.prop_payoff_g0, 
			length(g0) > 0 ? length(filter(a -> a.learning_strategy == 3, g0)) / length(g0) : 0
			)
		
		push!( 
			model.prop_payoff_g1, 
			length(g1) > 0 ? length(filter(a -> a.learning_strategy == 3, g1)) / length(g1) : 0
			)

	end

	model.tick += 1
	
	if model.tick == model.total_ticks

		model.mean_payoff_final = last(model.mean_payoff)
		model.mean_payoff_g0_final = last(model.mean_payoff_g0)
		model.mean_payoff_g1_final = last(model.mean_payoff_g1)

		model.mean_social_final = last(model.mean_social)
		model.mean_social_g0_final = last(model.mean_social_g0)
		model.mean_social_g1_final = last(model.mean_social_g1)

		model.mean_parochial_final = last(model.mean_parochial)
		model.mean_parochial_g0_final = last(model.mean_parochial_g0)
		model.mean_parochial_g1_final = last(model.mean_parochial_g1)

		if length(model.strat_pool) > 1
			model.prop_unbiased_final = length(model.prop_unbiased) > 0 ? last(model.prop_unbiased) : 0
			model.prop_unbiased_g0_final = length(model.prop_unbiased_g0) > 0 ? last(model.prop_unbiased_g0) : 0
			model.prop_unbiased_g1_final = length(model.prop_unbiased_g1) > 0 ? last(model.prop_unbiased_g1) : 0
			model.corr_unbiased_social = mean([a.soc for a in unb])
			model.corr_unbiased_parochial = mean([a.parochial for a in unb])

			model.prop_conformist_final = length(model.prop_conformist) > 0 ? last(model.prop_conformist) : 0
			model.prop_conformist_g0_final = length(model.prop_conformist_g0) > 0 ? last(model.prop_conformist_g0) : 0
			model.prop_conformist_g1_final = length(model.prop_conformist_g1) > 0 ? last(model.prop_conformist_g1) : 0
			model.corr_conformist_social = mean([a.soc for a in conf])
			model.corr_conformist_parochial = mean([a.parochial for a in conf])

			model.prop_payoff_final = length(model.prop_payoff) > 0 ? last(model.prop_payoff) : 0
			model.prop_payoff_g0_final = length(model.prop_payoff_g0) > 0 ? last(model.prop_payoff_g0) : 0
			model.prop_payoff_g1_final = length(model.prop_payoff_g1) > 0 ? last(model.prop_payoff_g1) : 0
			model.corr_payoff_social = mean([a.soc for a in pay])
			model.corr_payoff_parochial = mean([a.parochial for a in pay])
		end

	end
end

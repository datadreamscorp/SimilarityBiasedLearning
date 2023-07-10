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

#
function initialize_similarity_learning(;
	N = 100,
	f = 0.5,
	r = 1.0,
	H0 = (1.0, 0.0),
	theta = 0,
	n = 5,
	mu_ID = 0.0,
	mu_l = 0,
	sigma_l = 0.1,
	mu_p = 0.01,
	sigma_p = 0.05,
	mu_r = 0.01,
	sigma_r = 0.05,
	S = 0.5,
	prop_parochial = 0.0,
	true_random = false,
	seed = 123456789,
)
	rng = true_random ? RandomDevice() : MersenneTwister(seed)
	
	model = ABM( 
		Learner, 
		nothing;
		properties = Dict(
			:N => N,
			:N_total => N,
			:f => f,
			:r => r,
			:H0 => H0,
			:theta => theta,
			:H1 => ( cos(theta), sin(theta) ),
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
			#:rng => rng,
			#data
			:mean_social => Vector{Float64}(),
			:mean_social_g0 => Vector{Float64}(),
			:mean_social_g1 => Vector{Float64}(),
			:mean_parochial => Vector{Float64}(),
			:mean_parochial_g0 => Vector{Float64}(),
			:mean_parochial_g1 => Vector{Float64}(),
			:tick => 1,
		),
		rng
	)
	
	for a in 1:N
		
		group = rand(model.rng) < model.f ? 0 : 1
		
		groupID = rand(model.rng) < model.r ? group : ( rand(model.rng) < model.f ? 0 : 1 )
		
		if group == 0
			HI = ( 
				model.H0[1] + rand( model.rng, Normal(0, model.sigma_l) ),
				model.H0[2] + rand( model.rng, Normal(0, model.sigma_l) )
			)
		else
			HI = ( 
				model.H1[1] + rand( model.rng, Normal(0, model.sigma_l) ),
				model.H1[2] + rand( model.rng, Normal(0, model.sigma_l) )
			)
		end
		
		agent = Learner( 
			a,
			group, 
			groupID,
			HI,
			(0.0, 0.0),
			rand(model.rng) < model.prop_parochial ? 1.0 : 0.0,
			0.0,
			1,
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
	return (X[1] - H[1])^2 + (X[2] - H[2])^2
end

#
function calculate_payoff!(agent, model)
	X = agent.trait
	H = agent.group == 0 ? model.H0 : model.H1
	agent.payoff = exp( -squared_distance(X, H) / (2*model.S) )
end

#
function reproduction!(model)
	
	agents = allagents(model)|>collect
	group0 = filter(a -> a.group == 0, agents)
	group1 = setdiff( agents, group0 )

	g0_n = length(group0)
	g1_n = length(group1)
	
	g0_payoffs = [a.payoff for a in group0]
	g1_payoffs = [a.payoff for a in group1]
	g0_max = maximum(g0_payoffs)
	g1_max = maximum(g1_payoffs)

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
	
	for i in (total_agents + 1):(total_agents + g0_n)
		HI = ( 
				model.H0[1] + rand( model.rng, Normal(0, model.sigma_l) ),
				model.H0[2] + rand( model.rng, Normal(0, model.sigma_l) )
			)

		parent = sample(model.rng, group0, g0_w)
		parentID = parent.groupID
		
		inh_parochialism = rand(model.rng) < 1 - model.mu_p ? parent.parochial : clamp( parent.parochial + rand(model.rng, Normal(0, model.sigma_p)), 0, 1 )

		inh_soclearn = rand(model.rng) < 1 - model.mu_r ? parent.soc : clamp( parent.soc + rand(model.rng, Normal(0, model.sigma_r)), 0, 1 )

		inh_strategy = rand(model.rng) < 1 - model.mu_l ? parent.learning_strategy : sample(model.rng, [1,2,3])
		
		child = Learner(
			i,
			parent.group, 
			rand(model.rng) < 1 - model.mu_ID ? parentID : abs(parentID - 1),
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

	#total_agents = model.N_total
	
	for i in (total_agents + g0_n + 1):(total_agents + g0_n + g1_n)
		HI = ( 
				model.H1[1] + rand( model.rng, Normal(0, model.sigma_l) ),
				model.H1[2] + rand( model.rng, Normal(0, model.sigma_l) )
			)

		parent = sample(model.rng, group1, g1_w)
		parentID = parent.groupID
		
		inh_parochialism = rand(model.rng) < 1 - model.mu_p ? parent.parochial : clamp( parent.parochial + rand(model.rng, Normal(0, model.sigma_p)), 0, 1 )

		inh_soclearn = rand(model.rng) < 1 - model.mu_r ? parent.soc : clamp( parent.soc + rand(model.rng, Normal(0, model.sigma_r)), 0, 1 )

		inh_strategy = rand(model.rng) < 1 - model.mu_l ? parent.learning_strategy : sample(model.rng, [1,2,3])
		
		child = Learner(
			i,
			parent.group, 
			rand(model.rng) < 1 - model.mu_ID ? parentID : abs(parentID - 1),
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

#
function learning_stage!(model)

	agents = allagents(model)|>collect
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

	old_sample = olds
	
	pot_models = sample(model.rng, old_sample, model.n, replace=false)
	for m in pot_models
		if m.group == learner.group
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
		learner.social_coor = median.([x_coor, y_coor])
			
	else #payoff bias

		max_idx = findmax(m -> m.payoff, learner.models)[2]
		mods = learner.models
		winner = mods[max_idx]
		learner.social_coor = winner.trait
		
	end

	learner.trait = ( (1 - s).*learner.indiv_coor ) .+ ( s.*learner.social_coor )
	
end

#
function pass_the_torch!(model)
	agents = allagents(model)|>collect
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

	push!( model.mean_social_g1, mean([a.soc for a in g1]) )
	push!( model.mean_parochial_g1, mean([a.parochial for a in g1]) )
	
	push!( model.mean_social, mean([a.soc for a in agents]) )
	push!( model.mean_parochial, mean([a.parochial for a in agents]) )
	model.tick += 1
	
end

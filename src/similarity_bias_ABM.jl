using StatsBase, Random, Distributions, Agents

# A learning agent with both inherited and dynamic traits
@agent struct Learner(NoSpaceAgent)
    # ————————————————————————————————
    # Heritable characteristics (fixed at birth)
    # ————————————————————————————————
    group::Int64                   # which patch/environment the agent belongs to (0 or 1)
    groupID::Int64                 # tag identity used for similarity‐based learning
    indiv_coor::Tuple{Float64,Float64}  # agent’s “innate” trait coordinates (initial preference)
    social_coor::Tuple{Float64,Float64} # trait copied via social learning (updated each generation)
    parochial::Float64             # bias against learning from out-group (0=no bias, 1=full bias)
    soc::Float64                   # weight on social vs individual information in learning (s)
    learning_strategy::Int64       # discrete code for strategy: 1=unbiased, 2=conformist, 3=payoff-biased

    # ————————————————————————————————
    # Dynamic characteristics (change over lifetime)
    # ————————————————————————————————
    payoff::Float64                # current fitness/payoff based on how trait matches environment
    trait::Tuple{Float64,Float64}  # agent’s expressed trait (blend of indiv_coor & social_coor)
    old::Bool                      # flag: has the agent already reproduced (adult vs newborn)
    models::Vector{Any}            # sampled pool of role models this generation
    p_rep::Float64                 # normalized reproduction probability (payoff / max payoff in group)
end


# Global parameters and data collectors for the similarity-biased learning model
Base.@kwdef mutable struct Parameters
    # —————————————————————————————
    # Population & environment settings
    # —————————————————————————————
    N::Int64                    # initial number of agents per patch
    N_total::Int64              # current total number of agents (grows after reproduction)
    f::Float64                  # baseline probability of being born in group 0
    ID_corr::Float64            # fidelity of groupID inheritance (vs random assignment)
    H0::Tuple{Float64,Float64}  # environmental optimum coordinates for group 0
    theta::Float64              # orientation angle (degrees), used to compute H1
    H1::Tuple{Float64,Float64}  # environmental optimum coordinates for group 1

    # —————————————————————————————
    # Learning & mutation parameters
    # —————————————————————————————
    n::Int64                    # number of role models sampled during social learning
    mu_ID::Float64              # mutation rate for tag inheritance (groupID)
    mu_l::Float64               # mutation rate for learning_strategy
    sigma_l::Float64            # mutation SD for individual-learning error
    mu_p::Float64               # mutation rate for parochial bias
    sigma_p::Float64            # mutation SD for parochial bias
    mu_r::Float64               # mutation rate for social-learning weight
    sigma_r::Float64            # mutation SD for social-learning weight
    S::Float64                  # variance parameter shaping payoff landscape
    prop_parochial::Float64     # initial proportion of agents with parochial bias = 1
    init_soc::Float64           # initial social-learning weight for all agents

    # —————————————————————————————
    # Strategy & simulation controls
    # —————————————————————————————
    strat_pool::Vector{Int64}   # allowed learning strategies (1=unbiased,2=conformist,3=payoff)
    tick::Int64                 # current tick (generation) counter
    total_ticks::Int64          # number of generations to run
    rep::Int64                  # simulation replicate ID
    true_random::Bool           # use OS randomness (true) or fixed seed (false)
    seed::Int64                 # RNG seed (for reproducibility)

    # —————————————————————————————
    # Time-series data collectors (defaults to empty vectors)
    # —————————————————————————————
    mean_payoff::Vector{Float64}       = Vector{Float64}()  # overall mean payoff each tick
    mean_payoff_g0::Vector{Float64}    = Vector{Float64}()  # mean payoff in group 0
    mean_payoff_g1::Vector{Float64}    = Vector{Float64}()  # mean payoff in group 1

    mean_social::Vector{Float64}       = Vector{Float64}()  # overall mean social weight
    mean_social_g0::Vector{Float64}    = Vector{Float64}()  # mean social weight, group 0
    mean_social_g1::Vector{Float64}    = Vector{Float64}()  # mean social weight, group 1

    mean_parochial::Vector{Float64}       = Vector{Float64}()  # overall mean parochial bias
    mean_parochial_g0::Vector{Float64}    = Vector{Float64}()  # mean parochial bias, group 0
    mean_parochial_g1::Vector{Float64}    = Vector{Float64}()  # mean parochial bias, group 1

    prop_unbiased::Vector{Float64}        = Vector{Float64}()  # proportion using unbiased copying
    prop_unbiased_g1::Vector{Float64}     = Vector{Float64}()  # same, group 1
    prop_unbiased_g0::Vector{Float64}     = Vector{Float64}()  # same, group 0

    prop_conformist::Vector{Float64}      = Vector{Float64}()  # proportion using conformist copying
    prop_conformist_g1::Vector{Float64}   = Vector{Float64}()  # same, group 1
    prop_conformist_g0::Vector{Float64}   = Vector{Float64}()  # same, group 0

    prop_payoff::Vector{Float64}          = Vector{Float64}()  # proportion using payoff-biased copying
    prop_payoff_g1::Vector{Float64}       = Vector{Float64}()  # same, group 1
    prop_payoff_g0::Vector{Float64}       = Vector{Float64}()  # same, group 0

    # —————————————————————————————
    # Final summary statistics (initialized to zero)
    # —————————————————————————————
    mean_payoff_final::Float64        = 0.0  # final overall mean payoff
    mean_payoff_g0_final::Float64     = 0.0  # final mean payoff, group 0
    mean_payoff_g1_final::Float64     = 0.0  # final mean payoff, group 1

    mean_social_final::Float64        = 0.0  # final overall mean social weight
    mean_social_g0_final::Float64     = 0.0  # final mean social weight, group 0
    mean_social_g1_final::Float64     = 0.0  # final mean social weight, group 1

    mean_parochial_final::Float64        = 0.0  # final overall mean parochial bias
    mean_parochial_g0_final::Float64     = 0.0  # final mean parochial bias, group 0
    mean_parochial_g1_final::Float64     = 0.0  # final mean parochial bias, group 1

    prop_unbiased_final::Float64         = 0.0  # final proportion unbiased
    prop_unbiased_g1_final::Float64      = 0.0  # final, group 1
    prop_unbiased_g0_final::Float64      = 0.0  # final, group 0
    corr_unbiased_parochial::Float64     = 0.0  # mean parochial bias among unbiased learners
    corr_unbiased_social::Float64        = 0.0  # mean social weight among unbiased learners

    prop_conformist_final::Float64       = 0.0  # final proportion conformist
    prop_conformist_g1_final::Float64    = 0.0  # final, group 1
    prop_conformist_g0_final::Float64    = 0.0  # final, group 0
    corr_conformist_parochial::Float64   = 0.0  # mean parochial bias among conformists
    corr_conformist_social::Float64      = 0.0  # mean social weight among conformists

    prop_payoff_final::Float64           = 0.0  # final proportion payoff-biased
    prop_payoff_g1_final::Float64        = 0.0  # final, group 1
    prop_payoff_g0_final::Float64        = 0.0  # final, group 0
    corr_payoff_parochial::Float64       = 0.0  # mean parochial bias among payoff-biased learners
    corr_payoff_social::Float64          = 0.0  # mean social weight among payoff-biased learners
end

#───────────────────────────────────────────────────────────────────────────────
# initialize_similarity_learning:
#   Build and populate an Agents.jl ABM for similarity‐biased social learning
#───────────────────────────────────────────────────────────────────────────────
function initialize_similarity_learning(;
    # —————————————————————————————
    # Function arguments (all keyword‐only, with defaults)
    # —————————————————————————————
    N              = 100,            # # of newborns per patch
    f              = 0.5,            # baseline prob. of being born in group 0
    ID_corr        = 1.0,            # fidelity of tag (groupID) inheritance
    H0             = (1.0, 0.0),     # optimum for environment 0
    theta          = 0.0,            # rotation angle (°) → defines H1
    n              = 5,              # # role models sampled per learner
    mu_ID          = 0.0,            # mutation rate for tag inheritance
    mu_l           = 0.01,           # learning‐strategy mutation rate
    sigma_l        = 0.1,            # SD of individual‐learning error
    mu_p           = 0.05,           # parochial‐bias mutation rate
    sigma_p        = 0.05,           # SD for parochial bias mutation
    mu_r           = 0.05,           # social‐weight mutation rate
    sigma_r        = 0.05,           # SD for social‐weight mutation
    S              = 0.05,           # payoff‐landscape variance
    prop_parochial = 0.0,            # initial proportion with parochial = 1
    init_soc       = 0.0,            # initial social‐weight for all agents
    strategies     = "UL",           # string code → which strategies to allow
    true_random    = false,          # use OS RNG (true) or fixed seed (false)
    seed           = 123456789,      # RNG seed if using Xoshiro
    total_ticks    = 3000,           # total generations to simulate
    rep            = 1               # replicate ID (for bookkeeping)
)
    #───────────────────────────────────────────────────────────────────────────
    # 1) Set up the random number generator
    #───────────────────────────────────────────────────────────────────────────
    rng = Xoshiro(seed)  # if true_random, you could swap in RandomDevice()

    #───────────────────────────────────────────────────────────────────────────
    # 2) Decode the `strategies` string into a vector of strategy codes
    #      1 = Unbiased, 2 = Conformist, 3 = Payoff‐biased
    #───────────────────────────────────────────────────────────────────────────
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
        error(raw"Invalid learning strategy pool: $strategies")
    end

    #───────────────────────────────────────────────────────────────────────────
    # 3) Build the model parameters struct (fills in defaults for data vectors)
    #───────────────────────────────────────────────────────────────────────────
    properties = Parameters(
        N               = N,
        N_total         = N,
        f               = f,
        ID_corr         = ID_corr,
        H0              = H0,
        theta           = theta,
        H1              = (cosd(theta), sind(theta)),  # rotate H0 by θ → H1
        n               = n,
        mu_ID           = mu_ID,
        mu_l            = mu_l,
        sigma_l         = sigma_l,
        mu_p            = mu_p,
        sigma_p         = sigma_p,
        mu_r            = mu_r,
        sigma_r         = sigma_r,
        S               = S,
        prop_parochial  = prop_parochial,
        init_soc        = init_soc,
        strat_pool      = strat_pool,
        tick            = 1,
        total_ticks     = total_ticks,
        rep             = rep,
        true_random     = true_random,
        seed            = seed
    )

    #───────────────────────────────────────────────────────────────────────────
    # 4) Instantiate the ABM with our Learner agent and custom stepping
    #───────────────────────────────────────────────────────────────────────────
    model = ABM(
        Learner,
        nothing;
        properties = properties,
        model_step! = model_step!,
        rng         = rng
    )

    #───────────────────────────────────────────────────────────────────────────
    # 5) Seed the model with N agents per patch
    #───────────────────────────────────────────────────────────────────────────
    for a in 1:N
        # (a) Assign birth group: prob f → group 0, else group 1
        group = rand(abmrng(model)) < model.f ? 0 : 1

        # (b) Inherit or randomly assign groupID with mutation rate mu_ID
        groupID = rand(abmrng(model)) < model.ID_corr ? group :
                  (rand(abmrng(model)) < model.f ? 0 : 1)

        # (c) Sample inherited coordinate (HI) around the patch optimum ± noise
        if group == 0
            HI = (
                @inbounds model.H0[1] + rand(abmrng(model), Normal(0, model.sigma_l)),
                @inbounds model.H0[2] + rand(abmrng(model), Normal(0, model.sigma_l))
            )
        else
            HI = (
                @inbounds model.H1[1] + rand(abmrng(model), Normal(0, model.sigma_l)),
                @inbounds model.H1[2] + rand(abmrng(model), Normal(0, model.sigma_l))
            )
        end

        # (d) Construct the agent with initial trait = HI, no social info yet
        agent = Learner(
            a,                        # unique agent ID
            group,                    # birth group
            groupID,                  # social tag
            HI,                       # indiv_coor
            (0.0, 0.0),               # social_coor (will be filled later)
            rand(abmrng(model)) < model.prop_parochial ? 1.0 : 0.0,  # parochial bias
            init_soc,                 # soc weight
            sample(abmrng(model), model.strat_pool),  # pick initial strategy
            0.0,                      # payoff (will compute next)
            HI,                       # trait starts equal to HI
            true,                     # old = true (adult before first step)
            [],                       # no models sampled yet
            0.0                       # p_rep (will compute in reproduction!)
        )

        # (e) Add to the model and compute initial payoff
        new_a = add_agent!(agent, model)
        calculate_payoff!(new_a, model)
    end

    #───────────────────────────────────────────────────────────────────────────
    # 6) Return the fully initialized model
    #───────────────────────────────────────────────────────────────────────────
    return model
end

#───────────────────────────────────────────────────────────────────────────────
# model_step!: one full generation update (reproduction → learning → bookkeeping)
#───────────────────────────────────────────────────────────────────────────────
function model_step!(model)
    # 1) Birth–death cycle: adults reproduce and die, newborns replace them
    reproduction!(model)
    # 2) Social learning: newborns sample models and update their traits
    learning_stage!(model)
    # 3) Advance generation: remove old adults, mark newborns as adults
    pass_the_torch!(model)

    #───────────────────────────────────────────────────────────────────────────
    # 4) Recompute payoffs for every agent based on their updated trait
    #───────────────────────────────────────────────────────────────────────────
    for a in collect(allagents(model))
        calculate_payoff!(a, model)
    end

    #───────────────────────────────────────────────────────────────────────────
    # 5) Aggregate per‐group and overall means for data collection
    #───────────────────────────────────────────────────────────────────────────
    agents = collect(allagents(model))
    g0 = filter(a -> a.group == 0, agents)
    g1 = filter(a -> a.group == 1, agents)

    # group 0 statistics (0 if empty)
    push!(model.mean_social_g0,
        isempty(g0) ? 0.0 : mean(a.soc for a in g0))
    push!(model.mean_parochial_g0,
        isempty(g0) ? 0.0 : mean(a.parochial for a in g0))
    push!(model.mean_payoff_g0,
        isempty(g0) ? 0.0 : mean(a.payoff for a in g0))

    # group 1 statistics (0 if empty)
    push!(model.mean_social_g1,
        isempty(g1) ? 0.0 : mean(a.soc for a in g1))
    push!(model.mean_parochial_g1,
        isempty(g1) ? 0.0 : mean(a.parochial for a in g1))
    push!(model.mean_payoff_g1,
        isempty(g1) ? 0.0 : mean(a.payoff for a in g1))

    # overall population statistics
    push!(model.mean_social, mean(a.soc for a in agents))
    push!(model.mean_parochial, mean(a.parochial for a in agents))
    push!(model.mean_payoff, mean(a.payoff for a in agents))

    #───────────────────────────────────────────────────────────────────────────
    # 6) Record strategy proportions if multiple strategies are in play
    #───────────────────────────────────────────────────────────────────────────
    if length(model.strat_pool) > 1
        unb = filter(a -> a.learning_strategy == 1, agents)
        conf = filter(a -> a.learning_strategy == 2, agents)
        pay = filter(a -> a.learning_strategy == 3, agents)

         # unbiased
        push!(model.prop_unbiased,
            isempty(unb) ? 0.0 : length(unb) / model.N)
        push!(model.prop_unbiased_g0,
            isempty(g0) ? 0.0 : count(a->a.learning_strategy==1, g0) / length(g0))
        push!(model.prop_unbiased_g1,
            isempty(g1) ? 0.0 : count(a->a.learning_strategy==1, g1) / length(g1))

        # conformist
        push!(model.prop_conformist,
            isempty(conf) ? 0.0 : length(conf) / model.N)
        push!(model.prop_conformist_g0,
            isempty(g0) ? 0.0 : count(a->a.learning_strategy==2, g0) / length(g0))
        push!(model.prop_conformist_g1,
            isempty(g1) ? 0.0 : count(a->a.learning_strategy==2, g1) / length(g1))

        # payoff‐biased
        push!(model.prop_payoff,
            isempty(pay) ? 0.0 : length(pay) / model.N)
        push!(model.prop_payoff_g0,
            isempty(g0) ? 0.0 : count(a->a.learning_strategy==3, g0) / length(g0))
        push!(model.prop_payoff_g1,
            isempty(g1) ? 0.0 : count(a->a.learning_strategy==3, g1) / length(g1))
    end

    #───────────────────────────────────────────────────────────────────────────
    # 7) Advance the tick counter
    #───────────────────────────────────────────────────────────────────────────
    model.tick += 1

    #───────────────────────────────────────────────────────────────────────────
    # 8) If we've reached the final generation, store summary statistics
    #───────────────────────────────────────────────────────────────────────────
    if model.tick == model.total_ticks
        # final payoffs
        model.mean_payoff_final     = last(model.mean_payoff)
        model.mean_payoff_g0_final  = last(model.mean_payoff_g0)
        model.mean_payoff_g1_final  = last(model.mean_payoff_g1)
        # final social‐learning weights
        model.mean_social_final     = last(model.mean_social)
        model.mean_social_g0_final  = last(model.mean_social_g0)
        model.mean_social_g1_final  = last(model.mean_social_g1)
        # final parochial biases
        model.mean_parochial_final  = last(model.mean_parochial)
        model.mean_parochial_g0_final = last(model.mean_parochial_g0)
        model.mean_parochial_g1_final = last(model.mean_parochial_g1)

        if length(model.strat_pool) > 1
            # unbiased learners
            model.prop_unbiased_final    = isempty(model.prop_unbiased)    ? 0.0 : last(model.prop_unbiased)
            model.prop_unbiased_g0_final = isempty(model.prop_unbiased_g0) ? 0.0 : last(model.prop_unbiased_g0)
            model.prop_unbiased_g1_final = isempty(model.prop_unbiased_g1) ? 0.0 : last(model.prop_unbiased_g1)
            model.corr_unbiased_social    = isempty(unb)  ? 0.0 : mean(a.soc for a in unb)
            model.corr_unbiased_parochial = isempty(unb)  ? 0.0 : mean(a.parochial for a in unb)

            # conformist learners
            model.prop_conformist_final    = isempty(model.prop_conformist)    ? 0.0 : last(model.prop_conformist)
            model.prop_conformist_g0_final = isempty(model.prop_conformist_g0) ? 0.0 : last(model.prop_conformist_g0)
            model.prop_conformist_g1_final = isempty(model.prop_conformist_g1) ? 0.0 : last(model.prop_conformist_g1)
            model.corr_conformist_social    = isempty(conf) ? 0.0 : mean(a.soc for a in conf)
            model.corr_conformist_parochial = isempty(conf) ? 0.0 : mean(a.parochial for a in conf)

            # payoff‐biased learners
            model.prop_payoff_final    = isempty(model.prop_payoff)    ? 0.0 : last(model.prop_payoff)
            model.prop_payoff_g0_final = isempty(model.prop_payoff_g0) ? 0.0 : last(model.prop_payoff_g0)
            model.prop_payoff_g1_final = isempty(model.prop_payoff_g1) ? 0.0 : last(model.prop_payoff_g1)
            model.corr_payoff_social    = isempty(pay)  ? 0.0 : mean(a.soc for a in pay)
            model.corr_payoff_parochial = isempty(pay)  ? 0.0 : mean(a.parochial for a in pay)
        end
    end
end

#───────────────────────────────────────────────────────────────────────────────
# Compute squared Euclidean distance between two 2-D points
#───────────────────────────────────────────────────────────────────────────────
function squared_distance(X::Tuple{Float64, Float64}, H::Tuple{Float64, Float64})
    # No bounds checks for speed
    return @inbounds (X[1] - H[1])^2 + (X[2] - H[2])^2
end

#───────────────────────────────────────────────────────────────────────────────
# Update an agent’s payoff based on how close its trait is to the patch optimum
#───────────────────────────────────────────────────────────────────────────────
function calculate_payoff!(agent, model)
    # choose the correct environmental target
    X = agent.trait
    H = agent.group == 0 ? model.H0 : model.H1

    # Gaussian fitness: exp(−dist²/(2S))
    agent.payoff = exp(-squared_distance(X, H) / (2 * model.S))
end

#───────────────────────────────────────────────────────────────────────────────
# Reproduce: remove all “old” agents and add offspring proportional to payoff
#───────────────────────────────────────────────────────────────────────────────
function reproduction!(model)
    # 1) Shuffle agents for unbiased grouping
    agents = shuffle(abmrng(model), collect(allagents(model)))
    group0 = filter(a -> a.group == 0, agents)
    group1 = filter(a -> a.group == 1, agents)

    # 2) Compute per-group maxima (to normalize payoffs)
    g0_n   = length(group0)
    g1_n   = length(group1)
    g0_max = g0_n > 0 ? maximum(a.payoff for a in group0) : 0.0
    g1_max = g1_n > 0 ? maximum(a.payoff for a in group1) : 0.0

    # 3) Build weight vectors for sampling parents
    g0_weights = Float64[]
    for a in group0
        a.p_rep = a.payoff / g0_max      # normalized reproduction weight
        push!(g0_weights, a.p_rep)
    end
    g1_weights = Float64[]
    for a in group1
        a.p_rep = a.payoff / g1_max
        push!(g1_weights, a.p_rep)
    end

    # Wrap into Weights objects for StatsBase.sample
    g0_w = Weights(g0_weights)
    g1_w = Weights(g1_weights)

    # 4) Spawn offspring for group0
    total_agents = model.N_total
    if g0_n > 0
        for i in (total_agents + 1):(total_agents + g0_n)
            # sample inherited coordinate around H0
            HI = (
                @inbounds model.H0[1] + rand(abmrng(model), Normal(0, model.sigma_l)),
                @inbounds model.H0[2] + rand(abmrng(model), Normal(0, model.sigma_l))
            )

            parent    = sample(abmrng(model), group0, g0_w)
            # mutate tag with rate mu_ID
            childID   = rand(abmrng(model)) < model.ID_corr ? parent.group :
                        (rand(abmrng(model)) < model.f ? 0 : 1)
            # inherit or mutate parochial bias
            inh_par   = rand(abmrng(model)) < 1 - model.mu_p ?
                        parent.parochial :
                        clamp(parent.parochial + rand(abmrng(model), Normal(0, model.sigma_p)), 0, 1)
            # inherit or mutate social weight
            inh_soc   = rand(abmrng(model)) < 1 - model.mu_r ?
                        parent.soc :
                        clamp(parent.soc + rand(abmrng(model), Normal(0, model.sigma_r)), 0, 1)
            # inherit or mutate learning strategy
            inh_strat = rand(abmrng(model)) < 1 - model.mu_l ?
                        parent.learning_strategy :
                        sample(abmrng(model), model.strat_pool)

            # build and add the newborn
            child = Learner(
                i,
                parent.group,
                childID,
                HI,
                (0.0, 0.0),
                inh_par,
                inh_soc,
                inh_strat,
                0.0,      # payoff (will be set later)
                HI,       # trait starts at HI
                false,    # old = false (newborn)
                Any[],    # no models sampled yet
                0.0       # p_rep
            )
            add_agent!(child, model)
            model.N_total += 1
        end
    end

    # 5) Spawn offspring for group1 (mirror of group0 logic)
    if g1_n > 0
        for i in (total_agents + g0_n + 1):(total_agents + g0_n + g1_n)
            HI     = (
                @inbounds model.H1[1] + rand(abmrng(model), Normal(0, model.sigma_l)),
                @inbounds model.H1[2] + rand(abmrng(model), Normal(0, model.sigma_l))
            )
            parent = sample(abmrng(model), group1, g1_w)
            childID   = rand(abmrng(model)) < model.ID_corr ? parent.group :
                        (rand(abmrng(model)) < model.f ? 0 : 1)
            inh_par   = rand(abmrng(model)) < 1 - model.mu_p ?
                        parent.parochial :
                        clamp(parent.parochial + rand(abmrng(model), Normal(0, model.sigma_p)), 0, 1)
            inh_soc   = rand(abmrng(model)) < 1 - model.mu_r ?
                        parent.soc :
                        clamp(parent.soc + rand(abmrng(model), Normal(0, model.sigma_r)), 0, 1)
            inh_strat = rand(abmrng(model)) < 1 - model.mu_l ?
                        parent.learning_strategy :
                        sample(abmrng(model), model.strat_pool)

            child = Learner(
                i,
                parent.group,
                childID,
                HI,
                (0.0, 0.0),
                inh_par,
                inh_soc,
                inh_strat,
                0.0,
                HI,
                false,
                Any[],
                0.0
            )
            add_agent!(child, model)
            model.N_total += 1
        end
    end
end

#───────────────────────────────────────────────────────────────────────────────
# One generation of social learning: newborns sample and then update
#───────────────────────────────────────────────────────────────────────────────
function learning_stage!(model)
    # shuffle and partition into newborns vs adults
    agents         = shuffle(abmrng(model), collect(allagents(model)))
    new_generation = filter(a -> !a.old, agents)
    olds           = setdiff(agents, new_generation)

    # for each newborn, choose models then learn
    for learner in new_generation
        model_choice!(learner, olds, model)
        if !isempty(learner.models)
            learning!(learner, model)
        end
    end
end

#───────────────────────────────────────────────────────────────────────────────
# Sample up to n role models, applying parochial bias
#───────────────────────────────────────────────────────────────────────────────
function model_choice!(learner, olds, model)
    pot_models = sample(abmrng(model), olds, model.n, replace=false)
    for m in pot_models
        if m.groupID == learner.groupID
            push!(learner.models, m)           # always accept in‐group
        elseif rand(abmrng(model)) < 1 - learner.parochial
            push!(learner.models, m)           # accept out‐group with prob (1−parochial)
        end
    end
end

#───────────────────────────────────────────────────────────────────────────────
# Update learner’s trait by combining individual & chosen social info
#───────────────────────────────────────────────────────────────────────────────
function learning!(learner, model)
    s = learner.soc                      # social‐learning weight

    # pick social coordinate according to strategy
    if learner.learning_strategy == 1   # Unbiased (pick a random model)
        rando = rand(abmrng(model), learner.models)
        learner.social_coor = rando.trait

    elseif learner.learning_strategy == 2 # Conformist (median of models)
        xs = [m.trait[1] for m in learner.models]
        ys = [m.trait[2] for m in learner.models]
        learner.social_coor = median.( (xs, ys) )

    else                                  # Payoff‐biased (highest payoff)
        idx = findmax(m -> m.payoff, learner.models)[2]
        winner = learner.models[idx]
        learner.social_coor = winner.trait
    end

    # blend individual & social coordinates
    new_coor = ((1 - s) .* learner.indiv_coor) .+ (s .* learner.social_coor)
    learner.trait = (new_coor[1], new_coor[2])
end

#───────────────────────────────────────────────────────────────────────────────
# Remove last generation adults and mark current newborns as adults
#───────────────────────────────────────────────────────────────────────────────
function pass_the_torch!(model)
    agents = shuffle(abmrng(model), collect(allagents(model)))
    olds   = filter(a -> a.old, agents)
    news   = setdiff(agents, olds)

    # kill off old adults
    for old in olds
        remove_agent!(old, model)
    end

    # flip newborns to adults for next tick
    for new in news
        new.old = true
    end
end


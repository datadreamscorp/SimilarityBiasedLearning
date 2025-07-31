using Plots

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
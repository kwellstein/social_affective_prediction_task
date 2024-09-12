function plot_belief_trajectory(agent, n_avatars, avatar_colors, node_type = "binary")

    #Plot the beliefs trajectories for the four avatars
    for i = 1:n_avatars
        #Plot the belief trajectories (predictions about the timesteps)
        if i == 1
            plot_trajectory(
                agent,
                "x$node_type$i",
                label = "avatar $i",
                color = avatar_colors[i],
            )
        else
            plot_trajectory!(
                agent,
                "x$node_type$i",
                label = "avatar $i",
                color = avatar_colors[i],
            )
        end

        if node_type == "binary"
            #Plot the inputs
            plot_trajectory!(agent, "u$i", label = "", color = avatar_colors[i])
        end
    end

    if node_type == "binary"
        #Plot the actions
        actions = get_history(agent, "action")
        popfirst!(actions)
        plot!(
            actions .+ 0.1,
            color = :black,
            label = "actions",
            linetype = :scatter,
            title = "simulated_actions",
        )
    end

    #Add title
    belief_plot = title!("Belief trajectories for the four avatars")

    return belief_plot
end

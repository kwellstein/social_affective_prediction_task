function plot_belief_trajectory(agent, n_avatars, avatar_colors)
    
    #Plot the beliefs trajectories for the four avatars
    for i in 1:n_avatars
        #Plot the belief trajectories (predictions about the timesteps)
        if i == 1
            plot_trajectory(agent, "xbinary$i", label = "avatar $i", color = avatar_colors[i])
        else
            plot_trajectory!(agent, "xbinary$i", label = "avatar $i", color = avatar_colors[i])
        end

        #Plot the inputs
        plot_trajectory!(agent, "u$i", label = "", color = avatar_colors[i])
    end

    #Plot the actions
    actions = get_history(agent, "action")
    popfirst!(actions)
   # plot!(actions .+ .1, color = :black, label = "actions", linetype = :scatter, title = "simulated_actions")

    #Add title
    belief_plot = title!("Belief trajectories for the three avatars")

    return belief_plot
end

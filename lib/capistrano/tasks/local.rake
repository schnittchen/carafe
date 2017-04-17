task "local:gather-rev" do
  rev =
    run_locally do
      capture :git, "rev-parse", Onartsipac.rev_param
    end

  set :rev, rev
  set :abbrev_rev, rev[0..9]
end



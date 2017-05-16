# We advise users to build their own "deploy" top level task.
# We need to clear capistrano's defaults before this can work.
# Also, provide a hint in case the user missed this step.
Rake::Task["deploy"].clear
task "deploy" do
  me = Rake::Task["deploy"]
  if me.actions.length + me.prerequisites.length == 1
    # this one is the only action, and there is no prerequisite
    raise %{If you want to use the "deploy" task, you need to define
    an action or prerequisites for it first. Please consult the carafe documentation.}
  end
end


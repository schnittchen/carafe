defmodule Top do
  use Application

  def start(_type, _args) do
    # asynchronoysly wait for our startup sequence to be finished,
    # then write started applications to file to be read by test

    Agent.start_link fn ->
      Task.async fn ->
        Stream.repeatedly(fn ->
          Application.started_applications
          |> Enum.map(fn {app, _, _} -> app end)
        end)
        |> Stream.drop_while(& !(:top in &1))
        |> Enum.find(fn _ -> true end)
        |> Enum.map(&to_string/1)
        |> Enum.join(" ")
        |> (& File.write("/tmp/started_applications", &1)).()
      end
    end
  end
end

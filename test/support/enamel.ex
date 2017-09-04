defmodule Enamel do
  @default_config %{expect_fail: false, good_exits: [0]}
  defstruct [
    config: @default_config,
    steps: [],
  ]

  def new(options \\ []) do
    validate_options(options)

    %__MODULE__{
      config: Enum.into(options, @default_config)
    }
  end

  def command(list) when is_list(list) do
    new()
    |> command(list)
  end

  def command(%__MODULE__{} = struct, list, options \\ []) when is_list(list) do
    validate_options(options)

    config = Map.merge(struct.config, Enum.into(options, %{}))
    step = {normalize_command(list), config}

    %{ struct | steps: struct.steps ++ [step] }
  end

  def run!(%__MODULE__{steps: steps}) do
    steps |> Enum.each(&handle_step/1)
  end

  defp handle_step({argv, config} = step) do
    {first, second, porcelain_opts} = porcelain_args(step)
    p = Porcelain.exec(first, second, porcelain_opts)
    case {p_ok_error(p, config), config.expect_fail} do
      {:ok, false} -> nil
      {{:error, _}, true} -> nil
      {:ok, true} -> failed(argv, "Expected failure, but succeeded", config)
      {{:error, reason}, false} -> failed(argv, reason, config)
    end
  end

  defp failed(argv, reason, %{on_failure: fun}) do
    failed(argv, reason, fun)
  end
  defp failed(argv, reason, %{}) do
    default_fun = fn reason, command ->
      raise "Command #{command} failed: #{reason}"
    end
    failed(argv, reason, default_fun)
  end
  defp failed(argv, reason, fun) when is_function(fun, 1) do
    failed(argv, reason, fn reason, command -> fun.(reason) end)
  end
  defp failed(argv, reason, fun) when is_function(fun, 2) do
    fun.(reason, argv |> Enum.join(" "))
  end

  @default_porcelain_opts [out: IO.binstream(:standard_io, :line)]

  defp porcelain_args({argv, %{as: user} = config}) do
    {_, config} = Map.pop(config, :as)
    argv = ["sudo", "-u", user, "-H", "--" | argv]
    porcelain_args({argv, config})
  end
  defp porcelain_args({argv, config}) do
    do_porcelain_args(argv, config, @default_porcelain_opts)
  end

  defp do_porcelain_args(argv, %{dir: dir} = config, porcelain_opts) do
    {_, config} = Map.pop(config, :dir)
    do_porcelain_args(argv, config, Keyword.put(porcelain_opts, :dir, dir))
  end
  defp do_porcelain_args(argv, config, porcelain_opts) do
    {hd(argv), tl(argv), porcelain_opts}
  end

  defp p_ok_error({:error, _} = e, _), do: e
  defp p_ok_error(%{err: nil, status: status}, %{good_exits: good_exits}) do
    if status in good_exits do
      :ok
    else
      {:error, "Exit status #{status}"}
    end
  end
  defp p_ok_error(%{err: error}) do
    {:error, "#{error}"} # not sure this can be converted to string
  end

  @known_options [:dir, :on_failure, :expect_fail, :as, :good_exits]
  defp validate_options(options) do
    case Keyword.keys(options) -- @known_options |> List.first do
      nil -> :ok
      bad -> raise ArgumentError, "unknown option #{inspect bad}"
    end
  end

  defp normalize_command(list) do
    list
    |> List.flatten
    |> Enum.map(&to_string/1)
  end
end

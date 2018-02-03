defmodule Carafe do
  @moduledoc """
  This is the client-side interface for Carafe.
  """

  @doc """
  Executes elixir code given as a string. Fails if the code returns :error or {:error, reason}.
  Intended for communication with a running node.
  """
  def execute_elixir(elixir) when is_list(elixir) do
    elixir |> to_string |> execute_elixir
  end
  def execute_elixir(elixir) when is_binary(elixir) do
    elixir
    |> Code.eval_string
    |> case do
      :ok -> :ok
      {:ok, _} -> :ok
      :error = bad -> bad
      {_error, } = bad -> bad
      other ->
        if other, do: :ok, else: other
    end
    |> case do
      :ok -> nil
      other -> raise "execute_elixir failed: #{inspect other}"
    end
  end
end

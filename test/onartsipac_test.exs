defmodule OnartsipacTest do
  use DummyAppCase, async: false

  test "foo" do
    Porcelain.exec("bundle", ~w{exec cap production foo}, dummy_app_poptions())
    |> assert_psuccess
  end
end

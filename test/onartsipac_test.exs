defmodule OnartsipacTest do
  use DummyAppCase

  test "foo" do
    Porcelain.exec("bundle", [], dummy_app_poptions())
    |> assert_psuccess
  end
end

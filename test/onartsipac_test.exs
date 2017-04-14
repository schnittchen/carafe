defmodule OnartsipacTest do
  use DummyAppCase, async: false

  setup do
    Porcelain.exec("rm", ~w{-rf /tmp/repo})
    |> assert_psuccess

    Porcelain.exec("mkdir", ~w{-p /tmp/repo})
    |> assert_psuccess

    Porcelain.exec("cp", ~w{-R #{dummy_app_path()} /tmp/repo})
    |> assert_psuccess

    Porcelain.exec("git", ~w{-C /tmp/repo init})
    |> assert_psuccess

    Porcelain.exec("git", ~w{-C /tmp/repo config user.name} ++ ["onartsipac test user"])
    |> assert_psuccess

    Porcelain.exec("git", ~w{-C /tmp/repo config user.email onartsipac@example.com})
    |> assert_psuccess

    Porcelain.exec("git", ~w{-C /tmp/repo add .})
    |> assert_psuccess

    Porcelain.exec("git", ~w{-C /tmp/repo commit -m bogus})
    |> assert_psuccess

    :ok
  end

  test "foo" do
    Porcelain.exec("bundle", [], dummy_app_poptions())
    |> assert_psuccess

    Porcelain.exec("bundle", ~w{exec cap --trace production foo}, dummy_app_poptions())
    |> assert_psuccess
  end
end

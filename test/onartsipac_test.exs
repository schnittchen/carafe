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

    Porcelain.exec("bundle", [], dummy_app_poptions())
    |> assert_psuccess

    :ok
  end

  test "updating the repo cache" do
    Porcelain.exec("bundle", ~w{exec cap --trace production buildhost:repo:update}, dummy_app_poptions())
    |> assert_psuccess

    Porcelain.exec("bundle", ~w{exec cap --trace production buildhost:repo:update}, dummy_app_poptions())
    |> assert_psuccess
  end

  test "cleaning the build path" do
    Porcelain.exec("sudo", ~w{su - user -c} ++ ["touch build_path"])
    |> assert_psuccess

    Porcelain.exec("bundle", ~w{exec cap --trace production buildhost:clean}, dummy_app_poptions())
    |> assert_psuccess

    Porcelain.exec("sudo", ~w{su - user -c} ++ ["[ ! -e build_path ]"])
    |> assert_psuccess

    Porcelain.exec("bundle", ~w{exec cap --trace production buildhost:clean}, dummy_app_poptions())
    |> assert_psuccess
  end

  test "cleaning the build path partially" do
    Porcelain.exec("sudo", ~w{su - user -c} ++ ["mkdir -p build_path/foo"])
    |> assert_psuccess

    Porcelain.exec("sudo", ~w{su - user -c} ++ ["mkdir -p build_path/deps/foo"])
    |> assert_psuccess

    Porcelain.exec("bundle", ~w{exec cap --trace production buildhost:clean:keepdeps}, dummy_app_poptions())
    |> assert_psuccess

    Porcelain.exec("sudo", ~w{su - user -c} ++ ["[ -e build_path/deps/foo ]"])
    |> assert_psuccess

    Porcelain.exec("sudo", ~w{su - user -c} ++ ["[ ! -e build_path/foo ]"])
    |> assert_psuccess

    Porcelain.exec("bundle", ~w{exec cap --trace production buildhost:clean:keepdeps}, dummy_app_poptions())
    |> assert_psuccess
  end
end

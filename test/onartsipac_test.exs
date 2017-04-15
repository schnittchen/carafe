defmodule OnartsipacTest do
  @dummy_name "dummy1"
  use DummyAppCase, async: false

  setup %{dummy: dummy} do
    File.rm_rf! dummy.base
    File.mkdir_p! dummy.base
    File.cp_r! ".", dummy.base
    File.rm_rf! Path.join(dummy.base, ".git")

    Porcelain.exec("git", ~w{-C #{dummy.remote} init})
    |> assert_psuccess

    Porcelain.exec("git", ~w{-C #{dummy.remote} config user.name} ++ ["onartsipac test user"])
    |> assert_psuccess

    Porcelain.exec("git", ~w{-C #{dummy.remote} config user.email onartsipac@example.com})
    |> assert_psuccess

    Porcelain.exec("git", ~w{-C #{dummy.remote} add .})
    |> assert_psuccess

    Porcelain.exec("git", ~w{-C #{dummy.remote} commit -m bogus})
    |> assert_psuccess

    Porcelain.exec("bundle", [], dummy.poptions)
    |> assert_psuccess

    :ok
  end

  test "updating the repo cache", %{dummy: dummy} do
    Porcelain.exec("bundle", ~w{exec cap --trace production buildhost:repo:update}, dummy.poptions)
    |> assert_psuccess

    Porcelain.exec("bundle", ~w{exec cap --trace production buildhost:repo:update}, dummy.poptions)
    |> assert_psuccess
  end

  test "cleaning the build path", %{dummy: dummy} do
    Porcelain.exec("sudo", ~w{su - user -c} ++ ["touch build_path"])
    |> assert_psuccess

    Porcelain.exec("bundle", ~w{exec cap --trace production buildhost:clean}, dummy.poptions)
    |> assert_psuccess

    assert !File.exists?("/home/user/build_path")

    Porcelain.exec("bundle", ~w{exec cap --trace production buildhost:clean}, dummy.poptions)
    |> assert_psuccess
  end

  test "cleaning the build path partially", %{dummy: dummy} do
    Porcelain.exec("sudo", ~w{su - user -c} ++ ["mkdir -p build_path/foo"])
    |> assert_psuccess

    Porcelain.exec("sudo", ~w{su - user -c} ++ ["mkdir -p build_path/deps/foo"])
    |> assert_psuccess

    Porcelain.exec("bundle", ~w{exec cap --trace production buildhost:clean:keepdeps}, dummy.poptions)
    |> assert_psuccess

    assert File.exists?("/home/user/build_path/deps/foo")
    assert !File.exists?("/home/user/build_path/foo")

    Porcelain.exec("bundle", ~w{exec cap --trace production buildhost:clean:keepdeps}, dummy.poptions)
    |> assert_psuccess
  end

  test "preparing the build path", %{dummy: dummy} do
    Porcelain.exec("bundle", ~w{exec cap --trace production buildhost:prepare_build_path}, dummy.poptions)
    |> assert_psuccess

    assert File.exists?("/home/user/build_path/mix.exs")
  end
end

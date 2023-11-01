{
  # native inputs:
  lib,
  meson,
  ninja,
  glslang,
  # cross compile inputs:
  SDL2,
  windows,
  stdenv,
  pins,
  python3,
}: let
  inherit (pins) dxvk dxvk-async;
in
  stdenv.mkDerivation {
    name = "dxvk";
    inherit (dxvk) version;

    enableParallelBuilding = true;
    separateDebugInfo = true;

    nativeBuildInputs = [
      python3
    ];

    buildInputs =
      lib.optionals stdenv.targetPlatform.isWindows [windows.pthreads]
      ++ lib.optionals stdenv.targetPlatform.isLinux [SDL2];

    postPatch = ''
      patchShebangs ./
    '';

    depsBuildBuild = [
      meson
      ninja
      glslang
    ];

    patches = [
      # TODO: do we want to carry an async patch?
      # (dxvk-async + "/dxvk-async.patch")
    ];

    mesonFlags = ["--buildtype=release"];

    src = dxvk;

    meta = with lib; {
      license = licenses.zlib;
      description = " Vulkan-based implementation of D3D9, D3D10 and D3D11 for Linux / Wine";
      homepage = "https://github.com/doitsujin/dxvk";
      maintainers = with lib.maintainers; [LunNova];
      platforms = platforms.linux ++ platforms.windows;
      # GCC <13 ends up with an extra dep on mcfg-threads12
      broken = stdenv.cc.isGNU && lib.versionOlder stdenv.cc.version "13";
    };
  }

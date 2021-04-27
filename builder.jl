using Pkg.Artifacts
using Pkg.BinaryPlatforms

pkg_name = "Deno"
deno_version = v"1.9.2"

build_path = "build/"
artifacts_toml = joinpath(@__DIR__, "Artifacts.toml")

platforms = [
  Linux(:x86_64),
  MacOS(:x86_64),
]

temp_dir = mktempdir()
cd(temp_dir)
for platform in platforms
  archive_url = if platform isa Linux && arch(platform) == :x86_64
    "https://github.com/denoland/deno/releases/download/v$(deno_version)/deno-x86_64-unknown-linux-gnu.zip"
  elseif platform isa MacOS && arch(platform) == :aarch64
    "https://github.com/denoland/deno/releases/download/v$(deno_version)/deno-x86_64-apple-darwin.zip"
  elseif platform isa MacOS && arch(platform) == :x86_64
    "https://github.com/denoland/deno/releases/download/v$(deno_version)/deno-x86_64-apple-darwin.zip"
  elseif platform isa Windows && arch(platform) == :x86_64
    "https://github.com/denoland/deno/releases/download/v$(deno_version)/deno-x86_64-pc-windows-msvc.zip"
  end

  archive_name = download(archive_url, split(archive_url, "/")[end])
  dest_dir = replace(archive_name, ".zip" => "")
  run(`unzip $(archive_name) -d $(dest_dir)`)

  artifact_hash = create_artifact() do artifact_dir
    run(`mv $(dest_dir)/deno $(artifact_dir)`)
  end

  download_hash = archive_artifact(artifact_hash, "$dest_dir.tar.gz")
  github_url = "https://github.com/Pangoraw/DenoBuilder/"
  bind_artifact!(artifacts_toml, "deno_exe", artifact_hash; platform=platform, force=true, download_info=[
    (github_url, download_hash)
  ])
end

using Pkg.Artifacts
using Pkg.BinaryPlatforms

deno_version = v"1.9.2"
build_number = 2

# Where the GitHub release files will be located
build_path = joinpath(pwd(), "build/")

# The Artifacts.toml file
artifacts_toml = joinpath(build_path, "Artifacts.toml")

# Clean the build folder
if ispath(build_path)
  rm(build_path; force=true, recursive=true)
end
mkdir(build_path)

# Candidates platforms
platforms = [
  Linux(:x86_64),
  Windows(:x86_64),
  MacOS(:x86_64),
]

try # Is not supported on earlier Julia versions
  push!(platforms, MacOS(:aarch64))
catch
end

mktempdir() do temp_path
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

    zip_name = split(archive_url, "/")[end]
    archive_name = download(archive_url, joinpath(temp_path, zip_name))
    dest_dir = replace(basename(archive_name), ".zip" => "")
    run(`unzip $(archive_name) -d $(dest_dir)`)

    exe_name = platform isa Windows ? "deno.exe" : "deno"
    artifact_hash = create_artifact() do artifact_dir
      mv(joinpath(dest_dir, exe_name), joinpath(artifact_dir, exe_name))
    end

    archive_name = "$dest_dir-$deno_version-$build_number.tar.gz"
    archive_dest = joinpath(build_path, archive_name)
    download_hash = archive_artifact(artifact_hash, archive_dest)
    github_url = "https://github.com/Pangoraw/Deno.jl/releases/download/v$deno_version-$build_number/$archive_name"
    bind_artifact!(artifacts_toml, "deno_exe", artifact_hash; platform=platform, force=true, download_info=[
      (github_url, download_hash)
    ])
  end
end
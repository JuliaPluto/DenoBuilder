import HTTP
import LibGit2

include("./deno_version.jl")

function check_version_exists(version)
  release_url = "https://api.github.com/repos/denoland/deno/releases/tags/v$(version)"
  response = HTTP.get(release_url; status_exception=false)

  if response.status != 200
    @warn "Version $version does not seem to exists 🤔"
  end
end

function commit_changes(version, build_number)
  version_string = "v$version-$build_number"

  repo = LibGit2.GitRepo("./")
  LibGit2.add!(repo, "deno_version.jl")
  commit_hash = LibGit2.commit(repo, "Release version $version_string")
  LibGit2.tag_create(repo, version_string, commit_hash)

  @info """
  Created commit & tag for version $version_string

  Run `git push origin $version_string && git push` to create the release on GitHub
  """
end

println("Create a new version for Deno.jl")

print("deno-version ($deno_version)> ")
new_version = readline()

new_version = length(new_version) == 0 ? deno_version : VersionNumber(new_version)

if new_version != deno_version
  check_version_exists(new_version)
  deno_version = new_version
  build_number = 1
else
  build_number += 1
end

new_code = """
deno_version = v"$deno_version"
build_number = $build_number
"""

open("deno_version.jl", "w") do f
  write(f, new_code)
end

commit_changes(deno_version, build_number)

# DenoBuilder

This repository contains a script to download the released versions of deno from 
its [release page](https://github.com/denoland/deno/releases) and re-upload them as tarballs compatible with Julia's artifacts system. It is used as part of [Deno.jl](https://github.com/Pangoraw/Deno.jl).

### New release

To create a new release, you can run:

```
$ julia new_release.jl
deno-version (1.9.1)> 1.9.2
┌ Info: Created commit & tag for version v1.9.2-1
│
└ Run `git push` to create the release on GitHub

$ git push
```

Leaving the version empty will create a new release with the same version as previously build with a new build number incremented.

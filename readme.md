<p align="center">
    <h1 align="center">dot</h1>
</p1>

<p align="center"><i>dot is dotfiles manage cli.</i></p>

<p align="center">
    <a href=".license-mit"><img src="https://img.shields.io/badge/license-MIT-blue.svg"></a> 
</p>

## Configuration
Please make dot.json confirm to the format, or generate by `dot init` command. And you upload it to dotfiles respository.
```
[
  {
    "name": "filename",
    "input": "input_file_path_from_github",
    "output": "output_file_path_to_local",
    "chain": [] // chain install filenames (optional)
  },
]
```

## Support commands
```console
❯ dot install [--chain | -c] ${filename}
```

```console
❯ dot token ${github_token}
```

```console
❯ dot url ${github_url}
```

**coming soon**
```console
❯ dot init
```

## Installation via Homebrew
```console
❯ brew tap atsushi130/tap
❯ brew install dot
```


## Using Library
- [Commandy](https://github.com/atsushi130/Commandy)
- [Swifty](https://github.com/atsushi130/Swifty)
- [Moya](https://github.com/Moya/Moya)

## License
dot is available under the MIT license. See the [LICENSE file](https://github.com/atsushi130/dot/blob/master/license-mit).

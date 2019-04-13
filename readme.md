<p align="center">
    <h1 align="center">dot</h1>
</p1>

<p align="center"><i>dot is dotfiles manage cli.</i></p>

<p align="center">
    <a href=".license-mit"><img src="https://img.shields.io/badge/license-MIT-blue.svg"></a> 
</p>

## Installation via Homebrew
```console
❯ brew tap atsushi130/tap
❯ brew install dot
```

## Configuration
Please make dot.json confirm to the format, or generate by `dot init` command. And you upload it to dotfiles respository.
```
[
  {
    "name": "filename",
    "type": "file or dir",
    "input": "input_file_path_from_github",
    "output": "output_file_path_to_local",
    "chain": [] // chain install filenames (optional)
  },
]
```

- [Example dot.json](https://github.com/atsushi130/dotfiles/blob/master/dot.json)

## Usage
First, generate Github access token. [[Here](https://github.com/settings/tokens/new)]
![image](https://user-images.githubusercontent.com/11363154/55290785-9526c000-5412-11e9-92cc-861da7248307.png)

Next, register generated Github access token and repository to dot.
```console
❯ dot token ${generated_github_access_token}
❯ dot repository atsushi130/dotfiles
```

## Support commands

**install dotfiles**  
```console
❯ dot install [--chain | -c] ${filename}
```

**register github access token**  
```console
❯ dot token ${github_token}
```

**register dotfiles repository**  
```console
❯ dot repository ${owner/repository}
```

**example**
```console
❯ dot token f8a86be02ff77c0fa42d0fa16855d1e09a1affb6
❯ dot repository atsushi130/dotfiles
❯ dot install -c vimrc
```

**coming soon**
```console
❯ dot init
```

## Extension
Incremental search and install.  
```console
normal
❯ dot list | fzf --reverse | xargs dot install
cool
❯ dot list | fzf-tmux -d 35% --preview 'echo ❯ dot install {}' --preview-window down:1 --ansi --reverse --prompt='install dotfile is ' | xargs dot install
```

## Using Library
- [Commandy](https://github.com/atsushi130/Commandy)
- [Scripty](https://github.com/atsushi130/Scripty)
- [Moya](https://github.com/Moya/Moya)

## License
dot is available under the MIT license. See the [LICENSE file](https://github.com/atsushi130/dot/blob/master/license-mit).

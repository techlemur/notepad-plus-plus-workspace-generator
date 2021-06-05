# Notepad++ Workspace Generator [![License: MIT](https://img.shields.io/badge/License-MIT-black.svg)](https://opensource.org/licenses/MIT)

Small bash script for generating workspace files for notepad plus plus

## Options

- **-h | --help** -- Print help and exit
- **-n | --name** -- Project Name
- **-f | --file** -- File Name
- **-v | --verbose** -- Be more verbose

## Examples

### Bash

```bash
./generate.sh -f .npworkspace -n "My Project Name"
```

### Docker

```bash
docker run -it --rm -v "$PWD":/work techlemur/npwg -n $(basename $PWD)
```

## ToDo:

- [ ] Add CI tests

## :sparkling_heart: Supporters

| | |
|-|-|
|[![Greeley Wells](https://gravatar.com/avatar/48ef4a9d954492ad08e5c32b21c1daaa?s=150#avatar "Greeley Wells")](https://greeleyandfriends.com/)  | **Greeley Wells** (https://greeleyandfriends.com/) |

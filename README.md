# gamebuilder

A template for building Rojo projects. Designed with both partial and full management in mind.

## Get started

1. Clone this repository to your project folder.

    ```bash
    git clone https://github.com/constellationz/gamebuilder <project name>
    ```

2. Remove this project's GitHub link.

    ```bash
    cd <project name>
    git remote rm origin
    ```

3. Initialize the submodules

    ```bash
    git submodule init
    ```

4. Make sure [Rojo](https://github.com/rojo-rbx/rojo) is set up and added to your PATH.

5. Build a place to open while editing.

    ```bash
    rojo build -o place.rbxlx
    ```

    or (VS Code task)

    ```
    task build
    ```

6. Serve your project.

    ```bash
    rojo serve
    ```

    or (VS Code task)

    ```
    task serve
    ```

7. Activate Rojo in Studio

### Rojo Structure

By default, the file tree is organized as follows:

| File tree | Roblox | Description |
| - | - | - |
| `src/client` | [StarterPlayerScripts](https://developer.roblox.com/en-us/api-reference/class/PlayerScripts) | Client-side scripts |
| `src/character` | [StarterCharacterScripts](https://developer.roblox.com/en-us/api-reference/class/StarterCharacterScripts) | Scripts placed in the character |
| `src/common` | [ReplicatedStorage](https://developer.roblox.com/en-us/api-reference/class/ReplicatedStorage) | Common modules, assets, and remotes |
| `src/server` | [ServerScriptService](https://developer.roblox.com/en-us/api-reference/class/ServerScriptService) | Server-side scripts |
| `src/storage` | [ServerStorage](https://developer.roblox.com/en-us/api-reference/class/ServerStorage) | Assets that the server can access |
| `src/lighting` | [Lighting](https://developer.roblox.com/en-us/api-reference/class/Lighting) | Lighting |
| `src/workspace` | [Workspace](https://developer.roblox.com/en-us/api-reference/class/Workspace) | Map models |

## Attribution

`constellationz/gamebuilder` is licensed under the ISC license.

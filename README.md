# gamebuilder
A template for building Rojo projects. Designed with both partial and full management in mind.

### Custom Loader

```lua
local Get = require(workspace.Get)

local Maps = Get.ServerAsset "Maps" -- Get maps from server storage
local Crown = Get.Asset "Props.Crown" -- Get the crown asset from common storage
local DataStore2 = Get "MyModule" -- Load DataStore2 from external repo
local ForwardData = Get.Remote "ForwardData" -- Get a common remote
```

### Rojo Structure

By default, the file tree is organized as follows:

| File tree | Roblox | Description |
| - | - | - |
| `src/client` | [StarterPlayerScripts](https://developer.roblox.com/en-us/api-reference/class/PlayerScripts) | Client-side scripts |
| `src/server` | [ServerScriptService](https://developer.roblox.com/en-us/api-reference/class/ServerScriptService) | Server-side scripts |
| `src/common` | [ReplicatedStorage](https://developer.roblox.com/en-us/api-reference/class/ReplicatedStorage) | Common modules, assets, and remotes |
| `src/character` | [StarterCharacterScripts](https://developer.roblox.com/en-us/api-reference/class/StarterCharacterScripts) | Scripts placed in the character |
| `src/storage` | [ServerStorage](https://developer.roblox.com/en-us/api-reference/class/ServerStorage) | Assets that the server can access |
| `src/workspace` | [Workspace](https://developer.roblox.com/en-us/api-reference/class/Workspace) | Map models |

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

3. Make sure [Rojo](https://github.com/rojo-rbx/rojo) is set up and added to your PATH.

4. Set up your project in dependencies in `default.project.json`

5. Build a place to open while editing.

    ```bash
    rojo build -o place.rbxlx
    ```

6. Serve your project.

    ```bash
    rojo serve
    ```

7. Activate Rojo in Studio

## Configure to your needs

### Add a source from an external library to the Rojo tree:

To include a Rojo tree from another folder, add the directory to `default.project.json` with `$path` set to the correct destination

```bash
git add submodule https://github.com/Roblox/roact 
```

```json
"ReplicatedStorage": {
  "$className": "ReplicatedStorage",
  "$path": "src/common",
  "Libraries": {
    "$className": "Folder",
    "Roact": {
      "$path": "./Roact/src"
    }
  }
}
```

```lua
-- ClientScript
local Get = require(workspace.Get)
local Roact = Get.Lib "Roact" -- Roact is loaded as if require(Roact) was called.

-- Modules can be used as normally.
local element = Roact.createElement(...)
```

### Customizing the Get loader

The Get loader can be customized to add extra functionality.

```lua
-- In Get.lua
-- Get.Remote -> look for assets parented to Remotes
ListenFor("Remote", Remotes, AssertExistence)

-- Get.Dog -> look for assets in DogFolder, then pass through function
ListenFor("Dog", DogFolder, function (result, name)
    assert(result ~= nil, "got no result for "..name)
    return result
end
    
-- DIY
function Get.MyMethod(name)
    return Folder:FindFirstChild(name)
end
```

```lua
-- On the client
local Get = require(workspace.Get)
local MyDog = Get.Dog "MyDog"
local MyThing = Get.MyMethod "MyThing"
```

## Attribution

`constellationz/gamebuilder` is licensed under the ISC license.

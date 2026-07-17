# SpringVisual3D (Project & Demo)

[![Godot Engine](https://shields.io)](https://godotengine.org)
[![License: MIT](https://shields.io)](LICENSE)

This repository contains the official development project, a live interactive demo scene, and the source files for the **SpringVisual3D** Godot 4 add-on. 

SpringVisual3D generates and deforms highly customizable 3D spring geometry purely through GPU vertex displacement. By using high-performance vertex shaders to mathematically construct, twist, and stretch the spring body in real time, it bypasses complex modeling and rigging workflows.

---

## 🚀 Repository Structure

Unlike the stripped-down folder distributed via the Godot Asset Library, this repository contains the full workspace used to build and test the addon:

*   **`addons/spring_visual_3d/`**: The core, production-ready plugin folder.
*   **`demo.tscn`**: The interactive demo scene located at the root for immediate testing.
*   **`project.godot`**: The master Godot project file.

---

## 🎮 Running the Demo Scene

A fully configured interactive demo scene is included at the root so you can see `SpringVisual3D` in action immediately.

### How to Play:
1. Clone this repository to your local machine:
   ```bash
   git clone https://github.com/jdarc/SpringVisual3D
   ```
2. Open the **Godot Project Manager** (v4.7 or newer).
3. Click **Import**, navigate to the cloned folder, and select the `project.godot` file.
4. Once the editor opens, double-click `demo.tscn` in the FileSystem dock.

### What’s inside the Demo:
*   **Dynamic Targeting**: Move the `Target` and `Anchor` nodes around using editor handles to watch the spring stretch, compress, and update its geometry flawlessly in real-time.
*   **Inspector Playground**: Select the spring node to tweak properties like `coil_radius`, `wire_radius`, and `twist_degrees` on the fly.

---

## 📦 Using the Add-on in Your Own Project

If you want to move **only** the plugin into your existing project, you have two choices:

### Option 1: The Godot Asset Library (Recommended)
1. Inside your own Godot project, click the **AssetLib** tab at the top of the editor.
2. Search for `SpringVisual3D` and download it.
3. Godot will automatically place the necessary files directly into your project's `res://addons/` directory.

### Option 2: Manual Copy from this Repo
1. Copy the `addons/spring_visual_3d/` directory from this repository.
2. Paste it directly into your own project's `res://addons/` folder.

> ⚠️ **Important Step**: After installing via either method, navigate to **Project -> Project Settings -> Plugins** in your editor, locate **SpringVisual3D**, and check the **Enable** box.

---

## 🛠️ Quick Code Example

Once enabled, you can easily control the spring anchors programmatically via GDScript:

```gdscript
extends Node3D

@onready var spring = $SpringVisual3D

func _process(delta: float) -> void:
    # Programmatically adjust the twisting effect in real-time
    spring.twist_degrees = wrapf(spring.twist_degrees + (90.0 * delta), 0.0, 360.0)
```

---

## 📄 License
This entire project—including the core add-on, source code, and root demo—is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for the full legal text.

## 👥 Contact & Support
* **Author**: Jean d'Arc
* **GitHub**: [@jdarc](https://github.com/jdarc)
* **Report Issues**: Please use the [GitHub Issues tab](https://github.com/jdarc/SpringVisual3D/issues) to report bugs or request new features.

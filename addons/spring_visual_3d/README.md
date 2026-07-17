# SpringVisual3D

This Godot 4 add-on generates and deforms customizable 3D spring geometry purely through GPU vertex displacement. It uses high-performance vertex shaders to mathematically construct, twist, and stretch the spring body in real time. Built for rapid implementation, it bypasses complex modelling and rig setups, giving you instant, programmatic control over spring rendering, scaling, and compression via simple and intuitive settings.

## Features
* **GPU-Driven Performance**: Mathematical vertex displacement eliminates CPU mesh generation overhead.
* **Dynamic Node Tracking**: Automatically anchors and stretches between two designated `Node3D` targets.
* **Real-time Procedural Adjustments**: Tweak geometry details, materials, and twisting directly inside the editor inspector.

## Installation

### Method 1: Godot Asset Library
1. Open your Godot project and navigate to the **AssetLib** tab.
2. Search for **SpringVisual3D**.
3. Click **Download** and then **Install**.

### Method 2: Manual Installation
1. Download the latest release source code.
2. Copy the `addons/spring_visual_3d` folder into your project's `res://addons/` directory.

### Activating the Plugin
1. Open Godot and go to **Project -> Project Settings -> Plugins**.
2. Locate **SpringVisual3D** and check the **Enable** box.

## Configuration & Export Properties

### Core Targeting
* **`target_node`** (`Node3D`): The endpoint node the spring attaches and stretches towards.
* **`anchor_node`** (`Node3D`): The starting origin node for the spring structure.
* **`twist_degrees`** (`float`): Rotational twist deformation applied along the length of the spring (0.0 to 360.0).

### Geometry Group
* **`radial_segments`** (`int`, default: `12`): Number of polygon edges making up the wire's thickness.
* **`rings`** (`int`, default: `200`): Total longitudinal steps along the spiral path (controls overall mesh smoothness).
* **`wire_radius`** (`float`, default: `0.05`): The thickness/radius of the physical spring wire strand.
* **`coil_radius`** (`float`, default: `0.3`): The overall radius of the main spring spiral cylinder.
* **`total_coils`** (`int`, default: `10`): The total number of full revolutions/loops the spring makes.

### Appearance Group
* **`albedo`** (`Color`, default: `Color.WHITE`): The base color of the spring material.
* **`metallic`** (`float`, default: `0.8`): Reflectivity setting matching standard PBR workflows.
* **`specular`** (`float`, default: `0.5`): High-frequency light reflection intensity.
* **`roughness`** (`float`, default: `0.2`): Surface micro-surface details (lower values create a shinier finish).

## License
This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

## Contact
* **Author**: Jean d'Arc
* **GitHub**: [@jdarc](https://github.com/jdarc)
* **Report Issues**: Please use the [GitHub Issues tab](https://github.com/jdarc/SpringVisual3D/issues) to report bugs or request new features.
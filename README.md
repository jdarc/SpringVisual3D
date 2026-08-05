# SpringVisual3D — Project & Demo

[![Godot Engine](https://shields.io)](https://godotengine.org)
[![License: MIT](https://shields.io)](LICENSE)

This repository contains the official development project, interactive demo, stress test, and source code for the **SpringVisual3D** Godot 4 add-on.

SpringVisual3D renders customizable 3D springs using **GPU vertex deformation**. A reusable `CylinderMesh` provides the backing geometry while a spatial vertex shader mathematically deforms it into a spring, allowing the spring to be positioned, stretched, twisted, and customized in real time without CPU-side mesh generation.

## ⚠️ Version 2.0.0

**SpringVisual3D 2.0.0 is a major rewrite and is not backwards-compatible with 1.x.**

Version 2.0.0 changes the underlying architecture from an internally managed spring mesh to a **reusable `CylinderMesh` + GPU deformation** approach.

The backing `CylinderMesh` is now explicitly assigned to `SpringVisual3D` and can be shared between multiple spring instances. This makes the resolution and resource usage of the spring geometry directly controllable by the user.

If you are upgrading from 1.x, please refer to the add-on documentation for the new setup and configuration model.

## Repository Structure

This repository contains the complete development workspace rather than just the production-ready add-on distributed through the Godot Asset Library.

```text
SpringVisual3D/
├── addons/
│   └── spring_visual_3d/    # Production add-on
├── stress/
│   └── stress_test.scn      # Performance/stress test
├── demo.tscn                # Interactive editor demonstration
└── project.godot            # Godot project configuration
```

### `addons/spring_visual_3d/`

The production-ready SpringVisual3D add-on. This is the only directory required when manually installing the add-on into another Godot project.

### `demo.tscn`

An interactive demonstration of SpringVisual3D's core functionality, including dynamic endpoint tracking and real-time configuration.

### `stress/stress_test.scn`

A performance test scene containing multiple animated springs. It is included to exercise SpringVisual3D under a heavier scene load and to provide a simple environment for performance comparisons.

### `project.godot`

The Godot project file used to open and run the demo and development scenes.

## Running the Project

Clone the repository:

```bash
git clone https://github.com/jdarc/SpringVisual3D
```

Open the **Godot Project Manager** and import the cloned project by selecting its `project.godot` file.

Once the project is open, the main scenes can be found in the FileSystem dock:

* `demo.tscn` — interactive demonstration
* `stress/stress_test.scn` — performance test

The project requires **Godot 4.2 or newer**.

## Demo

The demo scene provides an interactive environment for experimenting with SpringVisual3D.

### Dynamic Control Nodes

The spring can be controlled by two `Node3D` instances. Moving the anchor and target nodes automatically updates the spring's position, orientation, and length.

This makes it easy to experiment with:

* stretching and compressing
* changing spring orientation
* rotating the spring around its axis
* manipulating the spring through local transforms

### Inspector Playground

Select the `SpringVisual3D` node to experiment with its geometry and appearance properties directly in the editor.

Try changing:

* `wire_radius`
* `coil_radius`
* `total_coils`
* `twist_degrees`
* `albedo`
* `metallic`
* `specular`
* `roughness`

## Stress Test

The `stress/stress_test.scn` scene provides a simple performance test using multiple independently animated springs.

The test is intended primarily as a development and regression benchmark rather than as a formal performance specification. Actual performance depends on the number and resolution of the backing meshes, GPU capabilities, scene complexity, and editor/runtime overhead.

## Using the Add-on in Your Own Project

If you only want to use SpringVisual3D, you do **not** need to copy the entire repository. Install the add-on from the Godot Asset Library or copy the production add-on directory manually.

### Option 1: Godot Asset Library

1. Open your Godot project.
2. Select the **AssetLib** tab.
3. Search for **SpringVisual3D**.
4. Download and install the add-on.

### Option 2: Manual Installation

Copy:

```text
addons/spring_visual_3d/
```

into your project's:

```text
res://addons/
```

Then enable the plugin from:

**Project → Project Settings → Plugins**

## Basic Usage

SpringVisual3D is a `MeshInstance3D` that uses a `CylinderMesh` as its backing geometry.

Assign a `CylinderMesh` to the `mesh` property and optionally assign two `Node3D` control nodes:

```text
SpringVisual3D
├── mesh → CylinderMesh
├── anchor_node → Anchor
└── target_node → Target
```

The backing `CylinderMesh` can be shared between multiple `SpringVisual3D` instances.

For example:

```gdscript
extends Node3D

@onready var spring: SpringVisual3D = $SpringVisual3D

func _process(delta: float) -> void:
    spring.twist_degrees = wrapf(
        spring.twist_degrees + 90.0 * delta,
        0.0,
        360.0
    )
```

## Performance Model

SpringVisual3D deliberately avoids CPU-side spring mesh generation.

The scene graph is responsible for positioning the spring and supplying its parameters. The GPU vertex shader performs the procedural deformation required to turn the backing cylinder into a spring.

```text
Scene Graph
    │
    ├── Anchor / Target
    ├── Spring Transform
    └── Spring Parameters
            │
            ▼
      GPU Vertex Shader
            │
            ▼
     Procedural Spring
```

Because the backing `CylinderMesh` can be reused, multiple springs can share the same geometry resource while retaining independent transforms, dimensions, and appearance.

The resolution of the spring is determined by the backing cylinder's topology:

* **Radial segments** control the roundness of the wire.
* **Rings** control longitudinal resolution.

Higher-resolution meshes produce smoother springs but require more vertex processing.

## License

This project, including the SpringVisual3D add-on, source code, demo scenes, and stress test, is licensed under the **MIT License**.

See [LICENSE](LICENSE) for the full license text.

## Contact & Support

**Author:** Jean d'Arc

**GitHub:** [@jdarc](https://github.com/jdarc)

**Issues & Feature Requests:** [GitHub Issues](https://github.com/jdarc/SpringVisual3D/issues)

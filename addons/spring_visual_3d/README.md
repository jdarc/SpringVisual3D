# SpringVisual3D

A Godot 4 add-on for rendering customizable 3D springs using GPU vertex deformation.

SpringVisual3D takes a `CylinderMesh` and procedurally transforms it into a spring entirely in the vertex shader. The spring can be positioned, stretched, twisted, and customized in real time without generating or modifying mesh geometry on the CPU.

## ⚠️ Version 2.0.0 — Major Update

**SpringVisual3D 2.0.0 is a major rewrite and is not backwards-compatible with 1.x.**

Version 2.0.0 changes how the spring is constructed and configured internally. The previous implementation generated and managed its own cylinder geometry and shader setup. The new implementation instead uses a **user-supplied `CylinderMesh` as reusable backing geometry**, allowing the same mesh resource to be shared between multiple springs.

This makes the component more flexible and significantly improves resource reuse, particularly when using higher-resolution cylinder meshes.

### What's new in 2.0.0

* **Reusable `CylinderMesh` resources** — assign an existing `CylinderMesh` or create one specifically for your springs.
* **Shared geometry** — multiple `SpringVisual3D` instances can use the same mesh resource without duplicating geometry.
* **GPU procedural deformation** — the cylinder is transformed into a spring entirely in the vertex shader.
* **Dynamic endpoint tracking** — springs automatically position and stretch between two `Node3D` control nodes.
* **Twist control** — rotate the spring around the axis between its control nodes.
* **Per-instance appearance** — each spring can independently control its color and PBR properties.
* **Editor-friendly controls** — configure and manipulate springs directly in the Godot Inspector.
* **Arbitrary backing mesh dimensions** — the assigned `CylinderMesh` does not need to have a particular height or radius.

> **Upgrading from 1.x?**
> Version 2.0.0 changes the underlying implementation and scene configuration. Existing 1.x `SpringVisual3D` setups may need to be recreated or reconfigured. See the configuration section below for the new setup.

## How It Works

SpringVisual3D does not generate spring geometry on the CPU.

Instead, a regular `CylinderMesh` provides the underlying vertex layout while a GPU vertex shader mathematically transforms those vertices into a helical spring.

```text
CylinderMesh
     │
     ▼
GPU Vertex Shader
     │
     ├── Coil radius
     ├── Wire radius
     ├── Number of coils
     └── Spring length
     │
     ▼
Procedural Spring
```

The mesh itself can be reused by multiple `SpringVisual3D` instances. Each instance controls its own spring dimensions, transform, shader parameters, and appearance.

## Installation

### Method 1: Godot Asset Library

1. Open your Godot project and navigate to the **AssetLib** tab.
2. Search for **SpringVisual3D**.
3. Click **Download** and then **Install**.

### Method 2: Manual Installation

1. Download the latest release source code.
2. Copy the `addons/spring_visual_3d` folder into your project's `res://addons/` directory.

### Activating the Plugin

1. Open **Project → Project Settings → Plugins**.
2. Locate **SpringVisual3D**.
3. Enable the plugin.

## Basic Setup

Add a `SpringVisual3D` node to your scene.

SpringVisual3D requires a **`CylinderMesh`** assigned to its `mesh` property. You can either create a new `CylinderMesh` or assign an existing one.

The mesh resource is only used as the backing geometry. Its dimensions and topology are not modified by SpringVisual3D, so the same resource can safely be shared between multiple spring instances.

For example:

```text
SpringVisual3D
├── mesh → SharedSpringCylinder
├── anchor_node → Anchor
└── target_node → Target
```

Assign the two control nodes to `anchor_node` and `target_node`. The spring automatically positions itself between them and adjusts its length as they move.

### Control Nodes

**`anchor_node`**
Optional `Node3D` defining one end of the spring.

**`target_node`**
Optional `Node3D` defining the opposite end of the spring.

The distance between the two nodes determines the spring's length.

### Align Control Nodes

The **Align Control Nodes** Inspector button rotates the anchor and target nodes so their local transforms align with the spring's axis.

This is useful when using local transforms to stretch or manipulate the control nodes regardless of the spring's orientation.

## Geometry

### `wire_radius`

Radius of the circular cross-section of the spring wire.

Default: `0.05`

### `coil_radius`

Distance from the spring's central axis to the centre of the wire.

Default: `0.3`

### `total_coils`

Number of complete coils in the spring.

Default: `10`

### Choosing Mesh Resolution

The resolution of the backing `CylinderMesh` determines the visual resolution of the generated spring.

* **Radial segments** control the roundness of the wire.
* **Rings** control the longitudinal resolution of the spring.

Higher values produce smoother springs at the cost of additional vertex processing.

Because the `CylinderMesh` can be shared, a single high-resolution mesh can be reused by many `SpringVisual3D` instances.

## Twist

### `twist_degrees`

Rotates the spring around the axis running between the anchor and target nodes.

Default: `0°`

This controls the orientation of the spring's helical cross-section without changing its length or number of coils.

## Appearance

SpringVisual3D uses standard spatial PBR properties for its appearance.

### `albedo`

Base color of the spring.

Default: `Color.WHITE`

### `metallic`

Metallic strength of the spring's surface.

Default: `0.9`

### `specular`

Strength of specular reflections.

Default: `0.5`

### `roughness`

Surface roughness, where `0` is smooth and `1` is rough.

Default: `0.2`

## Performance

SpringVisual3D performs its procedural spring deformation in the **GPU vertex shader** rather than generating spring geometry on the CPU.

This makes it suitable for scenes containing many independently animated springs while allowing the underlying `CylinderMesh` geometry to be shared between instances.

Performance depends primarily on the resolution of the backing mesh, the number of springs, and the capabilities of the GPU.

For best performance, use only as much cylinder resolution as your project requires.

## Migrating from 1.x

Version 2.0.0 introduces a new implementation and should be treated as a **breaking release**.

The primary architectural change is:

**1.x**

```text
SpringVisual3D
	│
	├── internally managed cylinder
	└── internally managed spring geometry/shader
```

**2.0.0**

```text
SpringVisual3D
	│
	├── user-supplied CylinderMesh
	└── GPU spring deformation
```

The backing `CylinderMesh` is now an explicit part of the component's configuration and can be shared between spring instances.

If upgrading an existing project from 1.x, expect existing spring scenes to require reconfiguration.

## License

This project is licensed under the **MIT License**.

See [LICENSE](LICENSE) for details.

## Contact

**Author:** Jean d'Arc

**GitHub:** [@jdarc](https://github.com/jdarc)

**Report Issues:** Please use the [GitHub Issues](https://github.com/jdarc/SpringVisual3D/issues) page to report bugs or request features.

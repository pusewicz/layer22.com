---
layout: post
title: 'Swift and Cute Framework: Setting up a project with CMake'
date: 2025-06-06 09:26 +0200
tags: [cute, cute-framework, cmake, swift, game-development]
---

[Cute Framework](https://randygaul.github.io/cute_framework/) is a simple, yet powerful C/C++ framework for building 2D games using the modern GPU pipeline. While C or C++ is fine, [Swift](https://www.swift.org) is a modern language that many developers prefer for its safety and expressiveness. In this post, we will explore how to set up a project using Cute Framework with [CMake](https://cmake.org), enabling you to write your game logic in Swift while leveraging the performance of C/C++ for rendering and other performance-critical tasks.

## Prerequisites

Before we begin, ensure you have the following installed:

- [Swift](https://www.swift.org) (latest version, preferably Swift 6 or later)
- [CMake](https://cmake.org) (we are going to use the most recent version 4.0, but 3.20+ should work just fine)
- [Ninja](https://ninja-build.org) (required for building Swift with CMake)

## Setting Up the Project Structure

Create a new directory for your project and navigate into it:

```bash
mkdir MyCuteGame
cd MyCuteGame
```

Create the following directory structure:

```bash
mkdir src include
touch CMakeLists.txt # Our CMake configuration file
touch src/main.swift # Our main Swift file
touch include/shim.h # Our C header file for Swift interoperability
touch include/module.modulemap # Our C module map for Swift interoperability
```

The next step is to configure the `CMakeLists.txt` file. Open it in your favorite text editor and add the following content:

```cmake
cmake_minimum_required(VERSION 4.0)

# Set the project name and languages
project(
    MyCuteGame
    LANGUAGES C CXX Swift # Ensure we include C, C++, and Swift
)

# Set our game sources
file(GLOB_RECURSE SOURCES CONFIGURE_DEPENDS src/*.swift)

# Set our executable target
add_executable(MyCuteGame ${SOURCES})

# Include FetchContent to download Cute Framework
include(FetchContent)

# Define cute as our Cute Framework dependency
FetchContent_Declare(
    cute
    GIT_REPOSITORY https://github.com/RandyGaul/cute_framework
)
# Fetch the Cute Framework
FetchContent_MakeAvailable(cute)

# Add the Cute Framework as a dependency
target_include_directories(MyCuteGame PUBLIC $<BUILD_INTERFACE:${CMAKE_CURRENT_SOURCE_DIR}/include>)
target_link_libraries(MyCuteGame cute)
```

The `CMakeLists.txt` file defines few key components:

- It sets the project name and specifies that we will be using C, C++, and Swift. We use C and C++ as Cute Framework is written in C/C++.
- It collects all Swift source files in the `src` directory.
- It sets up the Cute Framework as a dependency using `FetchContent`, which allows us to download and include it directly in our project.
- It creates an executable target named `MyCuteGame` and links it with the Cute Framework.
- It includes the `include` directory for header files, which will be used for Swift interoperability.

## Setting Up Swift Interoperability

To enable Swift to call C functions, we need to create a C header file and a module map. Open `include/shim.h` and add the following content:

```c
#pragma once
#include <cute.h>
```

The `shim.h` file includes the Cute Framework header, allowing Swift to access its functions.

Next, create the module map in `include/module.modulemap`:

```
module CCute [extern_c] {
    header "shim.h"
    export *
}
```

This module map tells Swift how to import the C header file. The `extern_c` attribute indicates that this module is a C module, which is necessary for Swift interoperability.

With all that in place, we can now write our Swift code in `src/main.swift`. Open this file and add the following content:

```swift
import CCute

// Center the window on the screen
let options: CF_AppOptionFlags = Int32(CF_APP_OPTIONS_WINDOW_POS_CENTERED_BIT.rawValue)
let width: Int32 = 800
let height: Int32 = 600

// Create the Cute Framework app
let result = cf_make_app("MyCuteGame", 0, 0, 0, width, height, options, CommandLine.unsafeArgv[0])
if cf_is_error(result) {
  fatalError("Failed to create Cute Framework app")
}

// Create a demo girl sprite
var sprite = cf_make_demo_sprite()
// Play the "spin" animation
cf_sprite_play(&sprite, "spin")
// Make the sprite 4x larger
sprite.scale = CF_V2(x: 4.0, y: 4.0)

while cf_app_is_running() {
  // Update internal app state without a callback
  cf_app_update(nil)

  // Update the sprite state
  cf_sprite_update(&sprite)

  // Draw the sprite
  cf_sprite_draw(&sprite)

  // Draw the app onto the screen with clearing enabled
  cf_app_draw_onto_screen(true)
}

cf_destroy_app()
```

## Configure and Build the Project

Now that we have our project structure and code set up, we can configure and build the project using CMake. Open a terminal in the root directory of your project and run the following commands:

```bash
mkdir build       # Create a build directory
cd build
cmake -G Ninja .. # Configure the project using CMake with Ninja as the generator
cmake --build .   # Build the project
```

All that's left is to run the executable. You can do this by executing:

```bash
./MyCuteGame
```

This should launch your Cute Framework application, displaying a window with a spinning girl sprite.

![MyCuteGame](/images/posts/cute/girl.gif)

And voila! You have successfully set up a Cute Framework project using CMake and Swift. You can now start building your game logic in Swift while leveraging the performance of C/C++ for rendering and other tasks.

I encourage you to explore the documentation, and especially the [Getting Started](https://randygaul.github.io/cute_framework/#/getting_started) guide.

There is also a Discord server where you can ask questions and share your projects: [Cute Framework Discord](https://discord.gg/ZvxfCyjZCj).

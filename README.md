# Projection Illusion

Inspired by [this tweet](https://x.com/RedNoob5050/status/2022431439510540592), I reproduced the code in Godot and open-sourced it.

This is essentially an optical illusion where a shape floating above a ground plane is moved and resized such that it appears to not move, but it has actually moved onto the ground plane, without appearing like it has moved at all. The camera is also locked during this process to not break the illusion.

To determine how to move/scale the object, two raycasts are casted from 2 vertices on the bottom shape onto the ground plane, in the direction of the camera origin towards each vertex. The two points on the ground plane can be used to move the shape onto the ground plane, and the distance between those two points indicate exactly how much to scale the shape.
-   I also explained this process [here](https://x.com/NereusDev/status/2022657986498617619).

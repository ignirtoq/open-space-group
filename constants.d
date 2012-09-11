module superAwesome.constants;

import std.math; // Not sure if I should put this somewhere else, but I was getting an error.

/*
Values in this module are given in the following units
Mass - Kilograms
Length - Meters
Time - Seconds
Temperature - Kelvin
*/

public immutable real GRAVITATIONAL_CONSTANT = 6.67e-11;
public immutable real MASS_OF_EARTH = 5.97e24;
public immutable real RADIUS_OF_EARTH = 6371e3;
public immutable real RADIUS_OF_EARTH_SQUARED = RADIUS_OF_EARTH * RADIUS_OF_EARTH;
public immutable real ANGULAR_VELOCITY_OF_EARTH = 2 * PI / (24*3600);
public immutable real AIR_SPECIFIC_GAS_CONSTANT = 287.058;
public immutable real AIR_SURFACE_TEMPERATURE = 15 + 273.15;

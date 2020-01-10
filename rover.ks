// Rover autopilot library
runpath("0:/library/sphere_nav.ks").

function cruiseControl {
  parameter spd.

  // Control the wheel throttle with a PID that looks at the difference between the desired and the current speed.
}

function steerTo {
  parameter hdg.

  // Control the wheel steering with a PID that looks at the angle between the desired and current heading.

  // The compass needs to be in the range [0, 360).
}

function driveTo {
  parameter point.

  until sphere_dist(ship:geoposition, point) < 50 {
    // Point in the direction of the point
    lock wheelsteering to steerTo(point:heading).

    // Control the throttle to maintain a speed of 15 m/s
    lock wheelthrottle to cruiseControl(15).
  }
}

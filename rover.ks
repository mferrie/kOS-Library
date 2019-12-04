// Rover autopilot library

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
  parameter hdg, dist, spd. // Go x meters in the direction of y compass degrees.

  set currentDistance to dist.
  until currentDistance < 10 {
    // Drive in the required direction for 10 meters
    // Measure the new distance between here and the target
    // If the distance is less than 10 meters, stop.
    // Else, go to the beginning of the loop.
  }
  unlock wheelThrottle.
  unlock wheelSteer.
  brakes on.
}

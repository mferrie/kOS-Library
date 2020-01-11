runpath("0:/library/azimuth.ks").

function launchToOrbit {
  parameter alt, inc.
  countdown(10).
  clearscreen.
  launch().
  wait until verticalspeed > 80.
  until apoapsis > 80000 {
    set expectedThrust to maxThrust.
    lock steering to gravityTurn(alt, inc).
    if maxThrust < expectedThrust * 0.9 {
      lock throttle to 0.
      stage.
      lock throttle to 1.
    } else lock throttle to min(1, max(0, gLimit(3))).
  }
  lock throttle to 0.
  wait until eta:apoapsis < 30.
  lock steering to prograde.
  wait 5.
  lock throttle to 1.
  wait until periapsis > alt - 1000.
  lock throttle to 0.
  wait 5.
  panels on.
  stage.
  for p in ship:parts {
    if p:hasModule("ModuleDeployableAntenna") {
      p:getModule("ModuleDeployableAntenna"):doEvent("Extend Antenna").
    }
  }
}

function countdown {
  parameter count.
  from {local x is 0.} until x = count step {set x to x + 1.} do {
    print("Launch in T-" + (count - x) + "      ") at (5, 5).
    wait 1.
  }
}

function launch {
  lock throttle to 1.
  lock steering to up.
  stage.
  lock throttle to gLimit(2.5).
}

function gravityTurn {
  parameter alt, inc.
  return heading(az(alt, inc), 90 * constant:e^(-(6.7203*(10^(-5))))).
}

function gLimit {
  parameter gees.
  // Acceleration = gravity * gees
  local acc is 9.81 * gees.

  // Force = mass * acceleration
  local f is ship:mass * acc.

  // Throttle = desired force / maximum force
  if ship:maxThrust = 0 return 0.
  else return f / ship:maxThrust.
}

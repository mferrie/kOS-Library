// Maneuver node creation and execution library

function hohmann { // Hohmann transfer started at periapsis
  parameter targetAlt.

  set r1 to orbit:periapsis + body:radius.
  set r2 to targetAlt + body:radius.

  // v1
  set v1 to sqrt(body:mu / r1) * (sqrt((2 * r2) / (r1 + r2)) - 1).

  // v2
  set v2 to sqrt(body:mu / r2) * (1 - sqrt((2 * r1) / (r1 + r2))).

  return list(v1, v2).
}

function inc_change { // Inclination change done from AN
  parameter newInc.
  return (2 * sin((newInc - orbit:inclination) / 2) * sqrt(1 - orbit:eccentricity^2) * cos(orbit:argumentOfPeriapsis + orbit:trueAnomaly) * orbit:meanMotion * orbit:semiMajorAxis) / (1 + orbit:eccentricity * cos(orbit:trueanomaly)).
}

function exec_hohmann {
  parameter targetAlt.

  set totalDV to hohmann(targetAlt).

  set periBurn to node(time:seconds + eta:periapsis, 0, 0, totalDV[0]).
  exec_node(periBurn).

  set apoBurn to node(time:seconds + eta:apoapsis, 0, 0, totalDV[1]).
  exec_node(apoBurn).
}

function exec_inc_change {
  return 0. // TODO: Implement this.
}

function exec_node {
  parameter nd.

  //calculate ship's max acceleration
  set max_acc to ship:maxthrust/ship:mass.

  set burn_duration to nd:deltav:mag/max_acc.

  wait until nd:eta <= ((burn_duration / 2) + 60).

  set np to nd:deltav.
  lock steering to np.
  wait until vang(np, ship:facing:vector) < 0.25.
  wait until nd:eta <= (burn_duration / 2).

  set tset to 0.
  lock throttle to tset.

  set done to false.
  set dv0 to nd:deltav.
  until done {
    set max_acc to ship:maxThrust / ship:mass.
    set tset to min(nd:deltav:mag / max_acc, 1).
    if vdot(dv0, nd:deltaV) < 0 {
      lock throttle to 0.
      break.
    }
    if nd:deltaV:mag < 0.1 {
      wait until vdot(dv0, nd:deltav) < 0.5.
      lock throttle to 0.
      set done to true.
    }
  }
  unlock all.
  remove nd.
  set ship:control:pilotMainThrottle to 0.
}

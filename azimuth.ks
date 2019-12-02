function az {
  parameter alt, inc.

  // Input sanitization
  if body:atm:exists and alt < body:atm:height {
    set alt to ship:obt:body:atm:height + 5000.
  }
  if abs(inc) < abs(ship:latitude) {
    if inc < 0 {
      set inc to -abs(ship:latitude).
    }
    else {
      set inc to abs(ship:latitude).
    }
  }

  // Orbital velocity
  set v_orb to sqrt(body:mu / (alt + body:radius)).

  // Inertial azimuth
  set b_inertial to arcsin(cos(inc) / cos(ship:latitude)).

  // Planet rotation speed
  set v_planet_rot to (2 * constant:pi * body:radius) / body:rotationperiod.

  // Orbital speed northward and eastward components
  set v_x to v_orb * sin(b_inertial) - v_planet_rot * cos(ship:latitude).
  set v_y to v_orb * cos(b_inertial).

  // True azimuth
  return b_rot to arctan(v_x / v_y).
}

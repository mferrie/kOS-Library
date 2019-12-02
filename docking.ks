function translate {
  parameter vector.
  if vector:mag > 1 set vector to vector:normalized.

  set ship:control:starboard to vector * ship:facing:starvector.
  set ship:control:fore to vector * ship:facing:forevector.
  set ship:control:top to vector * ship:facing:topvector.
}

function get_port {
  parameter name.
  list targets in targets.
  targets:add(ship).
  for t in targets {
    if t:dockingports:length <> 0 {
      for port in target:dockingports {
        if port:tag = name return port.
      }
    }
  }
}

function approach {
  parameter targetPort, dockingPort, dist, spd.

  dockingPort:controlFrom().

  lock distOffset to targetPort:portFacing:vector * dist.
  lock approachVec to targetPort:nodePosition - dockingPort:nodePosition + distOffset.
  lock relVel to ship:velocity:orbit - targetPort:ship:velocity:orbit.
  lock steering to lookDirUp(-targetPort:portFacing:vector, targetPort:portFacing:upVector).

  until dockingPort:state <> "Ready" {
    translate((approachVec:normalized * spd) - relVel).
    local distanceVec is (targetPort:nodePosition - dockingPort:nodePosition).
    if vang(dockingPort:portFacing:vector, distanceVec) < 2 and abs(dist - distanceVec:mag) < 0.1 {
      break.
    }
    wait 0.01.
  }
  translate(v(0,0,0)). // Stop
}

function ensure_range {
  parameter targetVessel, dockingPort, dist, spd.

  lock relPos to ship:position - targetVessel:position.
  lock departVec to (relPos:normalized * dist) - relPos.
  lock relVel to ship:velocity:orbit - targetVessel:velocity:orbit.
  lock steering to heading(0, 0).
  until false {
    translate((departVec:normalized * spd) - relVel).
    if departVec:mag < 0.1 break.
    wait 0.01.
  }
  translate(v(0,0,0)).
}

function sideswipe_port {
  parameter targetPort, dockingPort, dist, spd.

  dockingPort:controlFrom().

  // Get a direction perpendicular to the docking port.
  lock sideDirection to targetPort:ship:facing:starVector.
  if abs(sideDirection * targetPort:portFacing:vector) = 1 {
    lock sideDirection to targetPort:ship:facing:topVector.
  }

  lock distOffset to sideDirection * dist.

  // Flip the offset if we're on the other side of the ship
  if (targetPort:nodePosition - dockingPort:nodePosition + distOffset):mag < (targetPort:nodePosition - dockingPort:nodePosition - distOffset):mag {
    lock distOffset to (-sideDirection) * dist.
  }
  lock approachVec to targetPort:nodePosition - dockingPort:nodePosition + distOffset.
  lock relVel to ship:velocity:orbit - targetPort:ship:velocity:orbit.
  lock steering to -1 * targetPort:portFacing:vector.

  until false {
    translate((approachVec:normalized * spd) - relVel).
    if approachVec:mag < 0.1 break.
    wait 0.01.
  }
  translate(v(0,0,0)).
}

function kill_relative_velocity {
  parameter targetPort.

  lock relativeVelocity to ship:velocity:orbit - targetPort:ship:velocity:orbit.
  until relativeVelocity:mag < 0.1 {
    translate(-relativeVelocity).
  }
  translate(v(0,0,0)).
}

function dock {
  parameter dockingPortTag, targetName, targetPortTag.
  set dockingPort to get_port(dockingPortTag).
  set targetVessel to vessel(targetName).
  dockingPort:controlFrom().

  rcs on.
  ensure_range(targetVessel, dockingPort, 100, 1).

  set targetPort to get_port(targetPortTag).
  kill_relative_velocity(targetPort).
  sideswipe_port(targetPort, dockingPort, 100, 1).
  approach(targetPort, dockingPort, 100, 1).
  approach(targetPort, dockingPort, 50, 1).
  approach(targetPort, dockingPort, 25, 1).
  approach(targetPort, dockingPort, 10, 0.5).
  approach(targetPort, dockingPort, 0, 0.5).
  rcs off.
}

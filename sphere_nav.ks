function bearing {
  parameter p1, p2.
  return mod(360 + arctan2(sin(p2:lng - p1:lng) * cos(p2:lat),
                          cos(p1:lat) * sin(p2:lat) - sin(p1:lat) * cos(p2:lat) * cos(p2:lng - p1:lng)),
              360).
}

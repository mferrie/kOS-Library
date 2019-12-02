// Initialize the vehicle's "operating system" core functionality

function notify {
  parameter message, priority is "message".
  if priority = "message" set col to green.
  else if priority = "alert" set col to yellow.
  else if priority = "warning" set col to red.
  else {
    set priority to "message".
    set col to green.
  }
  hudtext(message, 5, 2, 50, col, false).
}

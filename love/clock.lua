clock = {
  lastTime = 0,
  currentTime = 0,
  bpm = 120,
  sixteenth = function()
    return 1 / (clock.bpm / 60 * 4)
  end,
  lag = 0,
  update = function(dt)
    clock.currentTime = clock.currentTime + dt
    clock.lag = clock.currentTime - clock.lastTime
    clock.fire = clock.currentTime - clock.lastTime > clock.sixteenth()
    if clock.fire then
      clock.lastTime = clock.currentTime
    end
  end
}

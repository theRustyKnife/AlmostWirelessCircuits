local config = {}


-- how many ticks between checking no copper wires are connected
config.REFRESH_RATE = 10

-- poles that can only connect circuit wires
config.CIRCUIT_ONLY_POLES = {"almost-an-antenna"}

-- allow all poles (except above defined as circuit only) to be switched between circuit only and normal when placing
config.ALLOW_TOGGLE = true


config.DUMMY_NAME = "awc-dummy"


return config

--[[pod_format="raw",created="2026-04-17 10:47:47",modified="2026-04-17 10:48:32",revision=2]]
-- Screen dimensions, layout metrics, and network configuration

VERSION      = "1.3.0"

W, H         = 480, 270
BAR_H        = 16
PAD_X        = 6
CONT_W       = W - PAD_X * 2
LINE_H       = 8
CHAR_W       = 4

DOMAINS_FILE = "/appdata/podweb-browser/domains.lookup"
HOME_URL     = "podnet://48932/index.podweb"

BACK_BTN     = { x=4,    y=2, w=12, h=12, sprite=3 }
FORWARD_BTN  = { x=20,   y=2, w=12, h=12, sprite=4 }
RELOAD_BTN   = { x=36,   y=2, w=12, h=12, sprite=2 }
SUBMIT_BTN   = { x=W-16, y=2, w=12, h=12, sprite=1 }

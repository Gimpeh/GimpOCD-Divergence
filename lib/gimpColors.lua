--basic color api for OC Glasses
local gimp_colors = {}

gimp_colors.white = {1,1,1}
gimp_colors.black = {0,0,0}
gimp_colors.red = {1,0,0}
gimp_colors.green = {0,1,0}
gimp_colors.blue = {0,0,1}
gimp_colors.yellow = {1,1,0}
gimp_colors.cyan = {0,1,1}
gimp_colors.magenta = {1,0,1}
gimp_colors.orange = {1,0.65,0}  -- Corrected from {1,0.5,0}
gimp_colors.purple = {0.5,0,0.5} -- Corrected to a more standard purple
gimp_colors.lime = {0,1,0}       -- Changed to more standard lime (full green)
gimp_colors.pink = {1,0.75,0.8}  -- Adjusted pink to a more appropriate shade
gimp_colors.gray = {0.5,0.5,0.5}
gimp_colors.brown = {0.65,0.16,0.16} -- Adjusted brown to a more realistic value

gimp_colors.lightgray = {0.827, 0.827, 0.827}  -- More accurate light gray
gimp_colors.mutedcyan = {0.565, 0.933, 0.933} -- Softened cyan tones
gimp_colors.slategray = {0.439, 0.502, 0.565}
gimp_colors.softyellow = {1, 1, 0.878} -- Softened yellow, closer to butter color
gimp_colors.lightorange = {1, 0.647, 0} -- Corrected to the usual "light orange"
gimp_colors.lightgreen = {0.678, 1, 0.184} -- Made lighter and greener
gimp_colors.tealblue = {0, 0.502, 0.502} -- More teal-based blue
gimp_colors.royalblue = {0.255, 0.412, 0.882}
gimp_colors.brightred = {1, 0, 0} -- Brightened up the red component
gimp_colors.darkpurple = {0.415, 0.082, 0.549} -- Adjusted the dark purple tone

gimp_colors.mint = {0.678, 1, 0.678}
gimp_colors.periwinkle = {0.8, 0.8, 1}
gimp_colors.carrot = {1, 0.498, 0.094}
gimp_colors.salmon = {1, 0.549, 0.412} -- Brightened up salmon
gimp_colors.skyblue = {0.529, 0.808, 0.980} -- Made sky blue closer to its actual shade
gimp_colors.sandybrown = {0.957, 0.643, 0.376}
gimp_colors.turquoise = {0.251, 0.878, 0.816}
gimp_colors.violet = {0.933, 0.510, 0.933}
gimp_colors.gold = {1, 0.843, 0}
gimp_colors.silver = {0.753, 0.753, 0.753}
gimp_colors.peach = {1, 0.898, 0.769} -- Softened peach tone
gimp_colors.indigo = {0.294, 0, 0.510}
gimp_colors.olive = {0.502, 0.502, 0}
gimp_colors.maroon = {0.502, 0, 0}
gimp_colors.navy = {0, 0, 0.502}
gimp_colors.chocolate = {0.824, 0.412, 0.118}
gimp_colors.forestgreen = {0.133, 0.545, 0.133}
gimp_colors.khaki = {0.941, 0.902, 0.549}
gimp_colors.coral = {1, 0.498, 0.314}
gimp_colors.plum = {0.867, 0.627, 0.867}
gimp_colors.lavender = {0.902, 0.902, 0.980}
gimp_colors.tan = {0.824, 0.706, 0.549}
gimp_colors.crimson = {0.863, 0.078, 0.235}
gimp_colors.burgundy = {0.502, 0, 0.125}
gimp_colors.cerulean = {0.0, 0.482, 0.655}
gimp_colors.mauve = {0.878, 0.690, 1}
gimp_colors.beige = {0.961, 0.961, 0.863}
gimp_colors.azure = {0, 0.498, 1}
gimp_colors.bronze = {0.804, 0.498, 0.196}
gimp_colors.cadmiumgreen = {0, 0.502, 0}
gimp_colors.aquamarine = {0.498, 1, 0.831}
gimp_colors.fuchsia = {1, 0, 1}
gimp_colors.gainsboro = {0.863, 0.863, 0.863}
gimp_colors.ivory = {1, 1, 0.941}
gimp_colors.lavenderblush = {1, 0.941, 0.961}
gimp_colors.lemonchiffon = {1, 0.980, 0.804}
gimp_colors.lightsalmon = {1, 0.627, 0.478}
gimp_colors.mediumseagreen = {0.235, 0.702, 0.443}
gimp_colors.oldlace = {0.992, 0.961, 0.902}
gimp_colors.papayawhip = {1, 0.937, 0.835}
gimp_colors.seagreen = {0.180, 0.545, 0.341}
gimp_colors.springgreen = {0, 1, 0.498}
gimp_colors.thistle = {0.847, 0.749, 0.847}
gimp_colors.tomato = {1, 0.388, 0.278}
gimp_colors.wheat = {0.961, 0.871, 0.702}
gimp_colors.palegreen = {0.596, 0.984, 0.596}


--gimp_colors for gimpOCD
gimp_colors.background = gimp_colors.skyblue
gimp_colors.background2 = gimp_colors.white

gimp_colors.object = gimp_colors.mutedcyan
gimp_colors.objectinfo = gimp_colors.slategray

gimp_colors.configsettingtitle = gimp_colors.softyellow
gimp_colors.alertsettingtitle = gimp_colors.lightorange
gimp_colors.configsetting = gimp_colors.lightgreen

gimp_colors.navbutton = gimp_colors.seagreen
gimp_colors.otherbutton = gimp_colors.ivory
gimp_colors.dangerbutton = gimp_colors.brightred
gimp_colors.tabs = gimp_colors.darkpurple

gimp_colors.clicked = gimp_colors.yellow
gimp_colors.alertnotification = gimp_colors.crimson

gimp_colors.contextMenuBackground = gimp_colors.silver
gimp_colors.pagesButton_active = gimp_colors.mutedcyan
gimp_colors.pagesButton_inactive = gimp_colors.lime

gimp_colors.derp = {1.0, 0.8, 0.796}

return gimp_colors
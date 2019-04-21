--Another reason to be sad makes progress get made.
local d = vgui.Create("DHTML")
d:SetAllowLua(true)
--return d:ConsoleMessage([[RUNLUA:
if sad then --Prevents old instances from fucking anything up such as old values or functions.(Unloads anything left from the previous sad table if reloaded)
    if sad.UnLoad then
        print("[Sad-Bot] Unloading previous instance.")
        sad.UnLoad()
    end
end
sad = {}
sad.shots_fired = {}
sad.shots_fired_cooldown = {}


local ss = false
 
local renderv = render.RenderView
local renderc = render.Clear
local rendercap = render.Capture
local vguiworldpanel = vgui.GetWorldPanel
 
function sad.screengrab()
	if ss then return end
	ss = true
 
	renderc( 0, 0, 0, 255, true, true )
	renderv( {
		origin = LocalPlayer():EyePos(),
		angles = LocalPlayer():EyeAngles(),
		x = 0,
		y = 0,
		w = ScrW(),
		h = ScrH(),
		dopostprocess = true,
		drawhud = true,
		drawmonitors = true,
		drawviewmodel = true
	} )
 
	local vguishits = vguiworldpanel()
 
	if IsValid( vguishits ) then
		vguishits:SetPaintedManually( true )
	end
 
	timer.Simple( 0.1, function()
		vguiworldpanel():SetPaintedManually( false )
		ss = false
	end)
end
 
render.Capture = function(data)
	sad.screengrab()
	local cap = rendercap( data )
	return cap
end

--gay shit for later

local spread = {
    ["weapon_smg1"] = Vector( 0.04362, 0.04362, 0.04362 ),
    ["weapon_ar2"] = Vector( 0.02618, 0.02618, 0.02618 ),
    ["weapon_shotgun"] = Vector( 0.08716, 0.08716, 0.08716 ),
    ["weapon_pistol"] = Vector( 0.00873, 0.00873, 0.00873 ) ,
}
_R = _R or debug.getregistry()
of = of or _R.Entity.FireBullets
sad.q_shot_show = {}
function _R.Entity.FireBullets(ent, bul)
    local ply = LocalPlayer()
    local wep = ply:GetActiveWeapon()
    if sad.shots_fired_cooldown[ent:EntIndex()] == nil then sad.shots_fired_cooldown[ent:EntIndex()] = 0; end
    if sad.shots_fired[ent:EntIndex()] == nil then sad.shots_fired[ent:EntIndex()] = 0; end
    if CurTime() - sad.shots_fired_cooldown[ent:EntIndex()] > 0.1 then
        sad.shots_fired[ent:EntIndex()] = sad.shots_fired[ent:EntIndex()] + 1
        sad.shots_fired[ent:EntIndex()] = sad.shots_fired[ent:EntIndex()] % 5
        if sad.shots_fired[ent:EntIndex()] > 30000 then
            sad.shots_fired[ent:EntIndex()] = 0
        end
        if ent == ply then
            local re = sad.shots_fired[ply:EntIndex()]
            sad.q_shot_show[re] = {CurTime(), bul.Src, bul.Dir, bul.Distance}
        end
        sad.shots_fired_cooldown[ent:EntIndex()] = CurTime()
    end
    --sad.swap_predict()
    if (IsValid(wep)) then
        spread[wep:GetClass()] = bul.Spread
    end
    return of(ent, bul)
end

local md5 = {
}

md5.const = {
    0xd76aa478,
    0xe8c7b756,
    0x242070db,
    0xc1bdceee,
    0xf57c0faf,
    0x4787c62a,
    0xa8304613,
    0xfd469501,
    0x698098d8,
    0x8b44f7af,
    0xffff5bb1,
    0x895cd7be,
    0x6b901122,
    0xfd987193,
    0xa679438e,
    0x49b40821,
    0xf61e2562,
    0xc040b340,
    0x265e5a51,
    0xe9b6c7aa,
    0xd62f105d,
    0x02441453,
    0xd8a1e681,
    0xe7d3fbc8,
    0x21e1cde6,
    0xc33707d6,
    0xf4d50d87,
    0x455a14ed,
    0xa9e3e905,
    0xfcefa3f8,
    0x676f02d9,
    0x8d2a4c8a,
    0xfffa3942,
    0x8771f681,
    0x6d9d6122,
    0xfde5380c,
    0xa4beea44,
    0x4bdecfa9,
    0xf6bb4b60,
    0xbebfbc70,
    0x289b7ec6,
    0xeaa127fa,
    0xd4ef3085,
    0x04881d05,
    0xd9d4d039,
    0xe6db99e5,
    0x1fa27cf8,
    0xc4ac5665,
    0xf4292244,
    0x432aff97,
    0xab9423a7,
    0xfc93a039,
    0x655b59c3,
    0x8f0ccc92,
    0xffeff47d,
    0x85845dd1,
    0x6fa87e4f,
    0xfe2ce6e0,
    0xa3014314,
    0x4e0811a1,
    0xf7537e82,
    0xbd3af235,
    0x2ad7d2bb,
    0xeb86d391,
    0x67452301,
    0xefcdab89,
    0x98badcfe,
    0x10325476
}

local f = function(x, y, z)
    return bit.bor(bit.band(x, y), bit.band(-x - 1, z))
end
local g = function(x, y, z)
    return bit.bor(bit.band(x, z), bit.band(y, -z - 1))
end
local h = function(x, y, z)
    return bit.bxor(x, bit.bxor(y, z))
end
local i = function(x, y, z)
    return bit.bxor(y, bit.bor(x, -z - 1))
end
local z = function(f, a, b, c, d, x, s, ac)
    a = bit.band(a + f(b, c, d) + x + ac, 0xffffffff)
    return bit.bor(bit.lshift(bit.band(a, bit.rshift(0xffffffff, s)), s), bit.rshift(a, 32 - s)) + b
end
local MAX = 2 ^ 31
local SUB = 2 ^ 32
function md5.fix(a)
    if a > MAX then
        return a - SUB
    end
    return a
end

function md5.transform(A, B, C, D, X)
    local a, b, c, d = A, B, C, D
    a = z(f, a, b, c, d, X[0], 7, md5.const[1])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    d = z(f, d, a, b, c, X[1], 12, md5.const[2])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    c = z(f, c, d, a, b, X[2], 17, md5.const[3])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    b = z(f, b, c, d, a, X[3], 22, md5.const[4])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    a = z(f, a, b, c, d, X[4], 7, md5.const[5])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    d = z(f, d, a, b, c, X[5], 12, md5.const[6])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    c = z(f, c, d, a, b, X[6], 17, md5.const[7])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    b = z(f, b, c, d, a, X[7], 22, md5.const[8])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    a = z(f, a, b, c, d, X[8], 7, md5.const[9])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    d = z(f, d, a, b, c, X[9], 12, md5.const[10])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    c = z(f, c, d, a, b, X[10], 17, md5.const[11])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    b = z(f, b, c, d, a, X[11], 22, md5.const[12])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    a = z(f, a, b, c, d, X[12], 7, md5.const[13])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    d = z(f, d, a, b, c, X[13], 12, md5.const[14])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    c = z(f, c, d, a, b, X[14], 17, md5.const[15])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    b = z(f, b, c, d, a, X[15], 22, md5.const[16])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)

    a = z(g, a, b, c, d, X[1], 5, md5.const[17])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    d = z(g, d, a, b, c, X[6], 9, md5.const[18])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    c = z(g, c, d, a, b, X[11], 14, md5.const[19])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    b = z(g, b, c, d, a, X[0], 20, md5.const[20])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    a = z(g, a, b, c, d, X[5], 5, md5.const[21])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    d = z(g, d, a, b, c, X[10], 9, md5.const[22])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    c = z(g, c, d, a, b, X[15], 14, md5.const[23])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    b = z(g, b, c, d, a, X[4], 20, md5.const[24])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    a = z(g, a, b, c, d, X[9], 5, md5.const[25])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    d = z(g, d, a, b, c, X[14], 9, md5.const[26])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    c = z(g, c, d, a, b, X[3], 14, md5.const[27])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    b = z(g, b, c, d, a, X[8], 20, md5.const[28])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    a = z(g, a, b, c, d, X[13], 5, md5.const[29])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    d = z(g, d, a, b, c, X[2], 9, md5.const[30])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    c = z(g, c, d, a, b, X[7], 14, md5.const[31])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    b = z(g, b, c, d, a, X[12], 20, md5.const[32])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)

    a = z(h, a, b, c, d, X[5], 4, md5.const[33])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    d = z(h, d, a, b, c, X[8], 11, md5.const[34])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    c = z(h, c, d, a, b, X[11], 16, md5.const[35])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    b = z(h, b, c, d, a, X[14], 23, md5.const[36])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    a = z(h, a, b, c, d, X[1], 4, md5.const[37])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    d = z(h, d, a, b, c, X[4], 11, md5.const[38])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    c = z(h, c, d, a, b, X[7], 16, md5.const[39])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    b = z(h, b, c, d, a, X[10], 23, md5.const[40])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    a = z(h, a, b, c, d, X[13], 4, md5.const[41])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    d = z(h, d, a, b, c, X[0], 11, md5.const[42])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    c = z(h, c, d, a, b, X[3], 16, md5.const[43])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    b = z(h, b, c, d, a, X[6], 23, md5.const[44])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    a = z(h, a, b, c, d, X[9], 4, md5.const[45])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    d = z(h, d, a, b, c, X[12], 11, md5.const[46])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    c = z(h, c, d, a, b, X[15], 16, md5.const[47])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    b = z(h, b, c, d, a, X[2], 23, md5.const[48])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)

    a = z(i, a, b, c, d, X[0], 6, md5.const[49])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    d = z(i, d, a, b, c, X[7], 10, md5.const[50])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    c = z(i, c, d, a, b, X[14], 15, md5.const[51])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    b = z(i, b, c, d, a, X[5], 21, md5.const[52])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    a = z(i, a, b, c, d, X[12], 6, md5.const[53])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    d = z(i, d, a, b, c, X[3], 10, md5.const[54])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    c = z(i, c, d, a, b, X[10], 15, md5.const[55])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    b = z(i, b, c, d, a, X[1], 21, md5.const[56])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    a = z(i, a, b, c, d, X[8], 6, md5.const[57])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    d = z(i, d, a, b, c, X[15], 10, md5.const[58])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    c = z(i, c, d, a, b, X[6], 15, md5.const[59])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    b = z(i, b, c, d, a, X[13], 21, md5.const[60])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    a = z(i, a, b, c, d, X[4], 6, md5.const[61])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    d = z(i, d, a, b, c, X[11], 10, md5.const[62])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    c = z(i, c, d, a, b, X[2], 15, md5.const[63])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    b = z(i, b, c, d, a, X[9], 21, md5.const[64])
    a = md5.fix(a)
    b = md5.fix(b)
    c = md5.fix(c)
    d = md5.fix(d)
    return A + a, B + b, C + c, D + d
end

function md5.PseudoRandom(number)
    local a, b, c, d = md5.fix(md5.const[65]), md5.fix(md5.const[66]), md5.fix(md5.const[67]), md5.fix(md5.const[68])
    local m = {}
    for i = 0, 15 do
        m[i] = 0
    end
    m[0] = number
    m[1] = 128
    m[14] = 32
    local a, b, c, d = md5.transform(a, b, c, d, m)
    return bit.rshift(md5.fix(b), 16) % 256
 --& 0xff this is so mutch faster
end

--Some of them are wrong( like 3 ) but im to lazy to dump them again
local engineSpread = {
    [0] = {-0.492036, 0.286111},
    [1] = {-0.492036, 0.286111},
    [2] = {-0.255320, 0.128480},
    [3] = {0.456165, 0.356030},
    [4] = {-0.361731, 0.406344},
    [5] = {-0.146730, 0.834589},
    [6] = {-0.253288, -0.421936},
    [7] = {-0.448694, 0.111650},
    [8] = {-0.880700, 0.904610},
    [9] = {-0.379932, 0.138833},
    [10] = {0.502579, -0.494285},
    [11] = {-0.263847, -0.594805},
    [12] = {0.818612, 0.090368},
    [13] = {-0.063552, 0.044356},
    [14] = {0.490455, 0.304820},
    [15] = {-0.192024, 0.195162},
    [16] = {-0.139421, 0.857106},
    [17] = {0.715745, 0.336956},
    [18] = {-0.150103, -0.044842},
    [19] = {-0.176531, 0.275787},
    [20] = {0.155707, -0.152178},
    [21] = {-0.136486, -0.591896},
    [22] = {-0.021022, -0.761979},
    [23] = {-0.166004, -0.733964},
    [24] = {-0.102439, -0.132059},
    [25] = {-0.607531, -0.249979},
    [26] = {-0.500855, -0.185902},
    [27] = {-0.080884, 0.516556},
    [28] = {-0.003334, 0.138612},
    [29] = {-0.546388, -0.000115},
    [30] = {-0.228092, -0.018492},
    [31] = {0.542539, 0.543196},
    [32] = {-0.355162, 0.197473},
    [33] = {-0.041726, -0.015735},
    [34] = {-0.713230, -0.551701},
    [35] = {-0.045056, 0.090208},
    [36] = {0.061028, 0.417744},
    [37] = {-0.171149, -0.048811},
    [38] = {0.241499, 0.164562},
    [39] = {-0.129817, -0.111200},
    [40] = {0.007366, 0.091429},
    [41] = {-0.079268, -0.008285},
    [42] = {0.010982, -0.074707},
    [43] = {-0.517782, -0.682470},
    [44] = {-0.663822, -0.024972},
    [45] = {0.058213, -0.078307},
    [46] = {-0.302041, -0.132280},
    [47] = {0.217689, -0.209309},
    [48] = {-0.143615, 0.830349},
    [49] = {0.270912, 0.071245},
    [50] = {-0.258170, -0.598358},
    [51] = {0.099164, -0.257525},
    [52] = {-0.214676, -0.595918},
    [53] = {-0.427053, -0.523764},
    [54] = {-0.585472, 0.088522},
    [55] = {0.564305, -0.533822},
    [56] = {-0.387545, -0.422206},
    [57] = {0.690505, -0.299197},
    [58] = {0.475553, 0.169785},
    [59] = {0.347436, 0.575364},
    [60] = {-0.069555, -0.103340},
    [61] = {0.286197, -0.618916},
    [62] = {-0.505259, 0.106581},
    [63] = {-0.420214, -0.714843},
    [64] = {0.032596, -0.401891},
    [65] = {-0.238702, -0.087387},
    [66] = {0.714358, 0.197811},
    [67] = {0.208960, 0.319015},
    [68] = {-0.361140, 0.222130},
    [69] = {-0.133284, -0.492274},
    [70] = {0.022824, -0.133955},
    [71] = {-0.100850, 0.271962},
    [72] = {-0.050582, -0.319538},
    [73] = {0.577980, 0.095507},
    [74] = {0.224871, 0.242213},
    [75] = {-0.628274, 0.097248},
    [76] = {0.184266, 0.091959},
    [77] = {-0.036716, 0.474259},
    [78] = {-0.502566, -0.279520},
    [79] = {-0.073201, -0.036658},
    [80] = {0.339952, -0.293667},
    [81] = {0.042811, 0.130387},
    [82] = {0.125881, 0.007040},
    [83] = {0.138374, -0.418355},
    [84] = {0.261396, -0.392697},
    [85] = {-0.453318, -0.039618},
    [86] = {0.890159, -0.335165},
    [87] = {0.466437, -0.207762},
    [88] = {0.593253, 0.418018},
    [89] = {0.566934, -0.643837},
    [90] = {0.150918, 0.639588},
    [91] = {0.150112, 0.215963},
    [92] = {-0.130520, 0.324801},
    [93] = {-0.369819, -0.019127},
    [94] = {-0.038889, -0.650789},
    [95] = {0.490519, -0.065375},
    [96] = {-0.305940, 0.454759},
    [97] = {-0.521967, -0.550004},
    [98] = {-0.040366, 0.683259},
    [99] = {0.137676, -0.376445},
    [100] = {0.839301, 0.085979},
    [101] = {-0.319140, 0.481838},
    [102] = {0.201437, -0.033135},
    [103] = {0.384637, -0.036685},
    [104] = {0.598419, 0.144371},
    [105] = {-0.061424, -0.608645},
    [106] = {-0.065337, 0.308992},
    [107] = {-0.029356, -0.634337},
    [108] = {0.326532, 0.047639},
    [109] = {0.505681, -0.067187},
    [110] = {0.691612, 0.629364},
    [111] = {-0.038588, -0.635947},
    [112] = {0.637837, -0.011815},
    [113] = {0.765338, 0.563945},
    [114] = {0.213416, 0.068664},
    [115] = {-0.576581, 0.554824},
    [116] = {0.246580, 0.132726},
    [117] = {0.385548, -0.070054},
    [118] = {0.538735, -0.291010},
    [119] = {0.609944, 0.590973},
    [120] = {-0.463240, 0.010302},
    [121] = {-0.047718, 0.741086},
    [122] = {0.308590, -0.322179},
    [123] = {-0.291173, 0.256367},
    [124] = {0.287413, -0.510402},
    [125] = {0.864716, 0.158126},
    [126] = {0.572344, 0.561319},
    [127] = {-0.090544, 0.332633},
    [128] = {0.644714, 0.196736},
    [129] = {-0.204198, 0.603049},
    [130] = {-0.504277, -0.641931},
    [131] = {0.218554, 0.343778},
    [132] = {0.466971, 0.217517},
    [133] = {-0.400880, -0.299746},
    [134] = {-0.582451, 0.591832},
    [135] = {0.421843, 0.118453},
    [136] = {-0.215617, -0.037630},
    [137] = {0.341048, -0.283902},
    [138] = {-0.246495, -0.138214},
    [139] = {0.214287, -0.196102},
    [140] = {0.809797, -0.498168},
    [141] = {-0.115958, -0.260677},
    [142] = {-0.025448, 0.043173},
    [143] = {-0.416803, -0.180813},
    [144] = {-0.782066, 0.335273},
    [145] = {0.192178, -0.151171},
    [146] = {0.109733, 0.165085},
    [147] = {-0.617935, -0.274392},
    [148] = {0.283301, 0.171837},
    [149] = {-0.150202, 0.048709},
    [150] = {-0.179954, -0.288559},
    [151] = {-0.288267, -0.134894},
    [152] = {-0.049203, 0.231717},
    [153] = {-0.065761, 0.495457},
    [154] = {0.082018, -0.457869},
    [155] = {-0.159553, 0.032173},
    [156] = {0.508305, -0.090690},
    [157] = {0.232269, -0.338245},
    [158] = {-0.374490, -0.480945},
    [159] = {-0.541244, 0.194144},
    [160] = {-0.040063, -0.073532},
    [161] = {0.136516, -0.167617},
    [162] = {-0.237350, 0.456912},
    [163] = {-0.446604, -0.494381},
    [164] = {0.078626, -0.020068},
    [165] = {0.163208, 0.600330},
    [166] = {-0.886186, -0.345326},
    [167] = {-0.732948, -0.689349},
    [168] = {0.460564, -0.719006},
    [169] = {-0.033688, -0.333340},
    [170] = {-0.325414, -0.111704},
    [171] = {0.010928, 0.723791},
    [172] = {0.713581, -0.077733},
    [173] = {-0.050912, -0.444684},
    [174] = {-0.268509, 0.381144},
    [175] = {-0.175387, 0.147070},
    [176] = {-0.429779, 0.144737},
    [177] = {-0.054564, 0.821354},
    [178] = {0.003205, 0.178130},
    [179] = {-0.552814, 0.199046},
    [180] = {0.225919, -0.195013},
    [181] = {0.056040, -0.393974},
    [182] = {-0.505988, 0.075184},
    [183] = {-0.510223, 0.156271},
    [184] = {-0.209616, 0.111174},
    [185] = {-0.605132, -0.117104},
    [186] = {0.412433, -0.035510},
    [187] = {-0.573947, -0.691295},
    [188] = {-0.712686, 0.021719},
    [189] = {-0.643297, 0.145307},
    [190] = {0.245038, 0.343062},
    [191] = {-0.235623, -0.159307},
    [192] = {-0.834004, 0.088725},
    [193] = {0.121377, 0.671713},
    [194] = {0.528614, 0.607035},
    [195] = {-0.285699, -0.111312},
    [196] = {0.603385, 0.401094},
    [197] = {0.632098, -0.439659},
    [198] = {0.681016, -0.242436},
    [199] = {-0.261709, 0.304265},
    [200] = {-0.653737, -0.199245},
    [201] = {-0.435512, -0.762978},
    [202] = {0.701105, 0.389527},
    [203] = {0.093495, -0.148484},
    [204] = {0.715218, 0.638291},
    [205] = {-0.055431, -0.085173},
    [206] = {-0.727438, 0.889783},
    [207] = {-0.007230, -0.519183},
    [208] = {-0.359615, 0.058657},
    [209] = {0.294681, 0.601155},
    [210] = {0.226879, -0.255430},
    [211] = {-0.307847, -0.617373},
    [212] = {0.340916, -0.780086},
    [213] = {-0.028277, 0.610455},
    [214] = {-0.365067, 0.323311},
    [215] = {0.001059, -0.270451},
    [216] = {0.304025, 0.047478},
    [217] = {0.297389, 0.383859},
    [218] = {0.288059, 0.262816},
    [219] = {-0.889315, 0.533731},
    [220] = {0.215887, 0.678889},
    [221] = {0.287135, 0.343899},
    [222] = {0.423951, 0.672285},
    [223] = {0.411912, -0.812886},
    [224] = {0.081615, -0.497358},
    [225] = {-0.051963, -0.117891},
    [226] = {-0.062387, 0.331698},
    [227] = {0.020458, -0.734125},
    [228] = {-0.160176, 0.196321},
    [229] = {0.044898, -0.024032},
    [230] = {-0.153162, 0.930951},
    [231] = {-0.015084, 0.233476},
    [232] = {0.395043, 0.645227},
    [233] = {-0.232095, 0.283834},
    [234] = {-0.507699, 0.317122},
    [235] = {-0.606604, -0.227259},
    [236] = {0.526430, -0.408765},
    [237] = {0.304079, 0.135680},
    [238] = {-0.134042, 0.508741},
    [239] = {-0.276770, 0.383958},
    [240] = {-0.298963, -0.233668},
    [241] = {0.171889, 0.697367},
    [242] = {-0.292571, -0.317604},
    [243] = {0.587806, 0.115584},
    [244] = {-0.346690, -0.098320},
    [245] = {0.956701, -0.040982},
    [246] = {0.040838, 0.595304},
    [247] = {0.365201, -0.519547},
    [248] = {-0.397271, -0.090567},
    [249] = {-0.124873, -0.356800},
    [250] = {-0.122144, 0.617725},
    [251] = {0.191266, -0.197764},
    [252] = {-0.178092, 0.503667},
    [253] = {0.103221, 0.547538},
    [254] = {0.019524, 0.621226},
    [255] = {0.663918, -0.573476}
}

sad.aimtarget = nil
require("fuckpackets")
require("tuxmodulev2")
require("sourcenetcustom2")
bSendPacket = true --bSendpacket

--tick and net functions
sad.get_netchan_ply = function(ply)
    return CNetChan(ply:EntIndex())
end

sad.get_netchan = function()
    return CNetChan(LocalPlayer():EntIndex())
end

function sad.TIME_TO_TICKS(dt)
    return 0.5 + dt / engine.TickInterval()
end

function sad.TICKS_TO_TIME(dt)
    return engine.TickInterval() * dt
end

function sad.ROUND_TO_TICKS(dt)
    return engine.TickInterval() * sad.TIME_TO_TICKS(dt)
end

sad.visibletoscreen = function(x,y) --v1
    local w, h = ScrW(), ScrH()
    w = w
    h = h
    if (math.abs(x) > (w) or math.abs(y) > (h)) then return false; end
    return true
end

--add thing to make reminders from cheat instead of code! since i'm bored!
sad.cheat_report = {
    "Speed being under 1 can mess up aimbot if silent/psilent is enabled",
    "human should probably get disabled aswell?",
    "Holding down mouse1 with psilent enabled for too long will make you lag for a second",
    "anti-spread will not work with sweps that have a custom nospread system",
    "anti-recoil can fuck up with m9k, causing shots to go under the target"
}

for a, b in pairs(sad.cheat_report) do
    print("[Sad-Bot] [report]" .. b)
end

--Cheat config
sad.config = {
    --Selections start with 1, sliders start with 0, checkboxes start with falseortrue
    main_aimbot = false,
    main_aimbot_silent = false,
    main_aimbot_psilent = false,
    main_aimbot_autofire = false,
    main_aimbot_autoreload = false,
    main_aimbot_teamcheck = false,
    main_aimbot_prefer_eye = false,
    main_ammocheck = false,
    main_aimbot_autowall = false,
    main_aimbotwait = false,
    main_aimbotm1 = false,
    main_aimbotfov_check = false,
    main_aimbotfov = 0,
    main_aimbothumanize = 0,
    main_aimbothumanize_delay = 0.1,
    main_aimbothumanize_time = 0.01,
    main_aimbotspeed = 1,
    main_aimbotrecoil = false,
    main_aimbotspread = 1,
    main_aimbotpred = false,
    main_anti_aim = false,
    main_anti_anti_aim = false,
    main_bhop = false,
    main_bhop_strafe = false,
    main_lag_exploit = false,
    main_fakelag_factor = 0,
    main_fakelag = false,
    main_tabbed_out = false,
    main_low_lerp = false,
    visuals_enabled = false,
    visuals_players = false,
    visuals_players_local = false,
    visuals_npcs = false,
    visuals_type = 1,
    visuals_type_npc = 1,
    visuals_balloon_lead = false,
    visuals_crosshair_recoil = false,
    visuals_fov = 90,
    visuals_fov_toggle = false,
    visuals_thirdperson = false,
    visuals_target_indicator = false,
    visuals_info_bar = false,
    visuals_hit_marker = false,
}
--Menu colors(Temporary, I'll add something to change these in the menu)
sad.active_button_color = Color(40, 40, 40, 255)
sad.button_color = Color(0, 0, 0, 255)
sad.button_bar_color = Color(40, 40, 40, 150)
sad.button_border_color = Color(40, 40, 40, 50)
sad.corner_colors = Color(80, 80, 80)
sad.background_colors = Color(20, 20, 20, 250)
local options = sad.config

function sad.loadconfig() --Loads config, error checks.
    if (file.Exists(tostring("sad_config_v2.txt"), "DATA")) then
        for k, i in pairs(sad.config) do
            tooptions = util.JSONToTable(file.Read(tostring("sad_config_v2.txt"), "DATA"))
            if (tooptions[k] ~= sad.config[k]) then
                if (tooptions[k] ~= nil and (type(tooptions[k]) == type(sad.config[k]))) then
                    sad.config[k] = tooptions[k]
                else
                    print(
                        "Config-Failsafe ->",
                        k ..
                            " -> " ..
                                tostring(tooptions[k]) ..
                                    " was corrected to " ..
                                        tostring(sad.config[k]) ..
                                            " because it's value in the master config was changed."
                    )
                    tooptions[k] = sad.config[k]
                    file.Write(tostring("sad_config_v2.txt"), util.TableToJSON(tooptions))
                    options = tooptions
                end
            end
        end
    else
        print("[Sad-Bot] Creating config file")
        file.Write(tostring("sad_config_v2.txt"), util.TableToJSON(options))
    end
end

function sad.saveconfig() --Saves config
    file.Write(tostring("sad_config_v2.txt"), util.TableToJSON(options))
end
--Config end

sad.hooks = {}
--Hooking
function sad.AddHook(name, identifier, func) --Creates a hook that can be unhooked with sad.unload
    table.insert(sad.hooks, {name, identifier})
    hook.Add(name, identifier, func)
end

function sad.UnHook(name, identifier) --Unloads any hook, may add checks for purely cheat hooks only.
    hook.Remove(name, identifier)
end
--Hoking end

--Extra drawing
surface.CreateFont(
    "Sad1",
    {
        font = "Tahoma",
        extended = false,
        weight = 500,
        blursize = 0,
        scanlines = 0,
        antialias = true,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = true,
        additive = false,
        outline = false,
        size = 15
    }
)

surface.CreateFont(
    "Sad1-Checkbox",
    {
        font = "Tahoma",
        extended = false,
        weight = 700,
        blursize = 0,
        scanlines = 0,
        antialias = false,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = false,
        additive = false,
        outline = false,
        size = 13
    }
)

surface.CreateFont(
    "Sad1-Esp",
    {
        font = "Tahoma",
        extended = false,
        weight = 700,
        blursize = 0,
        scanlines = 0,
        antialias = false,
        underline = false,
        italic = false,
        strikeout = false,
        symbol = false,
        rotary = false,
        shadow = true,
        additive = false,
        outline = false,
        size = 13
    }
)

function sad.draw_text(text, x, y, font, color) --Draw text from surface.
    surface.SetFont(font)
    surface.SetTextColor(color)
    surface.SetTextPos(x, y)
    surface.DrawText(text)
end

draw.OutlinedBox = function(x1,y1,x2,y2,color)
    surface.SetDrawColor(color)
    surface.DrawOutlinedRect(x1,y1,x2,y2)
end

draw.Line = function(sX, sY, eX, eY, color)
    surface.SetDrawColor(color)
    surface.DrawLine( sX, sY, eX, eY )
end
--Extra Drawing end

--Extra utils
function sad.IsInFov(spot, fov) --fov checks if angle is in the speicfied degrees
    if options.main_aimbotfov_check == false then return true; end
    local my_angles = LocalPlayer():GetAngles()
    local compare_ang = (spot - LocalPlayer():GetShootPos()):Angle()
    local difference_y = math.abs(math.NormalizeAngle(my_angles.y - compare_ang.y))
    local difference_x = math.abs(math.NormalizeAngle(my_angles.x - compare_ang.x))
    if (difference_y <= fov and difference_x <= fov) then
        return true
    else
        return false
    end
end

sad.distance_point_to_line = function(Point, LineOrigin, Dir) --from v1
    PointDir = Point - LineOrigin
    TempOffset = PointDir:Dot(Dir) / (Dir.x * Dir.x + Dir.y * Dir.y + Dir.z * Dir.z)
    if (TempOffset < 0.000001) then
        return 340288876
    end
    PerpendicularPoint = LineOrigin + (Dir * TempOffset)
    return (Point - PerpendicularPoint):Length()
end

sad.FindPoint = function(point, screenwidth, screenheight, degrees) --from v1
    local x2 = screenwidth / 2
    local y2 = screenheight / 2
    local d = math.sqrt(math.pow((point.x - x2), 2) + (math.pow((point.y - y2), 2)))
    local r = degrees / d
    point.x = r * point.x + (1 - r) * x2
    point.y = r * point.y + (1 - r) * y2
end

sad.visibletoscreen = function(x, y) --from v1
    local w, h = ScrW(), ScrH()
    w = w
    h = h
    if (math.abs(x) > (w) or math.abs(y) > (h)) then
        return false
    end
    return true
end

draw.OutlinedBox = function(x1, y1, x2, y2, color) --from v1
    surface.SetDrawColor(color)
    surface.DrawOutlinedRect(x1, y1, x2, y2)
end

sad.SpotIsVisible = function(pos, ent)
    if pos == nil then
        return false
    end
    local tracedata = {}
    tracedata.start = LocalPlayer():GetShootPos()
    tracedata.endpos = pos
    if ent then
        tracedata.filter = {LocalPlayer(), ent}
    else
        tracedata.filter = {LocalPlayer()}
    end

    local trace = util.TraceLine(tracedata)
    if trace.HitPos:Distance(pos) < 0.09 or (tracedata.Entity == ent) then
        return true
    else
        return false
    end
end
--end extra utils

--Menu input, custom functions
sad.input = {}
sad.input.keydown = {}
sad.input.keydownalready = {}
function sad.input.ButtonPressed(key) --Returns if key was pressed, doesn't return if key is down it has to be released again to return pressed.
    if input.IsKeyDown(key) ~= true then
        sad.input.keydown[key] = false
        sad.input.keydownalready[key] = false
        return false
    else
        sad.input.keydown[key] = true
        if sad.input.keydownalready[key] ~= true then
            sad.input.keydownalready[key] = true
            return true
        else
            return false
        end
    end
end

sad.input.mousedown = {}
sad.input.mousedownalready = {}
function sad.input.MousePressed(key) --Returns if key was pressed, doesn't return if key is down it has to be released again to return pressed.
    if input.IsMouseDown(key) ~= true then
        sad.input.mousedown[key] = false
        sad.input.mousedownalready[key] = false
        return false
    else
        sad.input.mousedown[key] = true
        if sad.input.mousedownalready[key] ~= true then
            sad.input.mousedownalready[key] = true
            return true
        else
            return false
        end
    end
end
--Input end

--Pac shitr
sad.start_drama = function()
end
sad.start_drama_loaded = false
sad.all_ent_parts = {}
sad.eye_candy_parts = {}
if (pac) then
    sad.OldEntityRender = pac.HookEntityRender
    sad.start_drama = function()
        print("[Sad-Bot] Started drama")
        include("pac3/core/client/init.lua")
        include("pac3/editor/client/init.lua")
        function pac.HookEntityRender(ent, part)
            if not sad.all_ent_parts[ent] then
                if ent:IsPlayer() then
                    sad.eye_candy_parts[ent] = {}
                end
                sad.all_ent_parts[ent] = {}
            end

            if sad.all_ent_parts[ent][part] then
                return
            end
            --pac.dprint("[Sad-Bot] hooking render on %s to draw part %s", tostring(ent), tostring(part))
            --if utils.pusheventglobal and options.eventlogs_pac then
            --local ev = tostring("hooking render on " .. tostring(ent) .. " for part: " .. tostring(part))
            --utils.pusheventglobal(ev, 3)
            --end
            pac.drawn_entities[ent:EntIndex()] = ent
            pac.profile_info[ent:EntIndex()] = nil
            if ent:IsPlayer() then
                sad.eye_candy_parts[ent] = sad.eye_candy_parts[ent] or {}
                sad.eye_candy_parts[ent][part] = part
            end
            sad.all_ent_parts[ent] = sad.all_ent_parts[ent] or {}
            sad.all_ent_parts[ent][part] = part

            ent.pac_has_parts = true
            return sad.OldEntityRender(ent, part)
        end
        sad.start_drama_loaded = true
        print("[Sad-Bot] Stopped, loaded =", sad.start_drama_loaded)
    end
--pcall(start_drama)
end
--pac end

--UI
sad.tab_elements = {}
sad.menu_open = false
sad.menu_open_old = false
sad.last_menu_press = RealTime()
if sad.frame then
    sad.frame:Remove()
    sad.frame = nil
else
    sad.frame = nil
end

--Menu sounds
sad.menu_sounds = {
    --Use later or discard?
    menu_open = "",
    menu_close = "",
    tab_click = "",
    checkbox_click = ""
}
--Menu buttons
sad.cur_tab_boxes = {}
sad.buttons = 0
sad.button_last_hover = {}
sad.button_already_hovered = {}
sad.check_boxes = {}
sad.previous_tab = "Main"
sad.cur_tab = "Main"
--Default tab
function sad.create_tab_button(self, text, color, tabtochange) --Create a button which switches the current tab to the 'tabtochange'
    local button = vgui.Create("DButton", self)
    button:SetSize(80, 30)
    button:SetPos(6, 6 + sad.buttons * 35)
    button:SetText(text)
    button.Paint = function()
        local c = sad.button_color
        if sad.cur_tab == tabtochange then
            c = sad.active_button_color
        end
        if button:IsHovered() then
            if sad.button_already_hovered[tabtochange] == false then
                sad.button_last_hover[tabtochange] = RealTime()
            end
            sad.button_already_hovered[tabtochange] = true
            local p_tabtime = math.Clamp(((RealTime() - sad.button_last_hover[tabtochange]) * 40), 0, 1337)
            if p_tabtime > 14 then
                p_tabtime = 14
            end
            local fade_in = math.Clamp(14 - p_tabtime, 0, 14)
            draw.RoundedBox(0, 0, 0, button:GetWide(), button:GetTall(), sad.button_border_color)
            draw.RoundedBox(fade_in, 0, 0, button:GetWide(), button:GetTall(), c)
        else
            if sad.button_last_hover[tabtochange] == nil or sad.button_already_hovered[tabtochange] then
                sad.button_last_hover[tabtochange] = RealTime()
            end
            sad.button_already_hovered[tabtochange] = false
            local tabtime = math.Clamp(((RealTime() - sad.button_last_hover[tabtochange]) * 40), 0, 1337)
            if tabtime > 14 then
                tabtime = 14
            end
            draw.RoundedBox(0, 0, 0, button:GetWide(), button:GetTall(), sad.button_border_color)
            draw.RoundedBox(tabtime, 0, 0, button:GetWide(), button:GetTall(), c)
        end
    end
    --ignore this v
    --sad.menu_previous_items[sad.cur_tab] = button--Add this to any new UI element, it will remove it when the tab is changed.
    button.DoClick = function()
        if sad.cur_tab ~= tabtochange then
            sad.previous_tab = sad.cur_tab
        end
        sad.cur_tab = tabtochange
    end
    sad.buttons = sad.buttons + 1
end

function sad.MouseInArea(x, y, w, h)
    local mousex, mousey = gui.MousePos()
    if ((mousex - x) >= 0 and (mousey - y) >= 0) then
        return ((mousex - x) <= w and (mousey - y) <= h)
    end
end

--Checkboxes
function sad.create_checkbox(frame, text, value, tab, slot)
    local toggled = options[value]
    local color
    color = toggled and Color(0, 120, 0) or Color(120, 0, 0)
    if sad.cur_tab_boxes[slot] == nil then
        sad.cur_tab_boxes[slot] = 0
    end
    local pos = Vector(90, 3 + sad.cur_tab_boxes[slot] * 15, 0)
    local px, py = frame:GetPos()
    local px2, py2 = frame.main_frame:GetPos()
    px, py = px + px2, py + py2 -- Adds the postion of listview with mainframe to get the actual spot we want to put our checkbox(for mouse in area)
    local framesizex, framesizey = frame:GetWide(), frame:GetTall()
    local slot_move = 180
    if slot == 1 then
        slot_move = 0
    elseif (slot == 2) then
        slot_move = slot_move
    elseif (slot == 3) then
        slot_move = slot_move * 2
    elseif (slot == 4) then
        slot_move = slot_move * 3
    elseif (slot == 5) then
        slot_move = slot_move * 4
    end
    local mouse = sad.MouseInArea(px + (pos.x + slot_move), pos.y + py, 5, 5)
    local c = color
    c.a = mouse and 150 or c.a
    surface.SetDrawColor(Color(0, 0, 0))
    surface.DrawOutlinedRect((pos.x + slot_move) - 1, pos.y - 0.5, 7, 7)
    --Outline
    draw.RoundedBox(0, pos.x + slot_move, pos.y, 5, 5, c)
    --Box
    sad.draw_text(text, pos.x + slot_move + 8, pos.y - 4, "Sad1-Checkbox", c)
    --Text
    sad.cur_tab_boxes[slot] = sad.cur_tab_boxes[slot] + 1
    if (mouse) then
        if sad.input.MousePressed(MOUSE_LEFT) then
            if toggled == false then
                options[value] = true
            else
                options[value] = false
            end
            if toggled == nil then
                print(value .. " is nil")
            end
        end
    end
end

function sad.create_selection(frame, text, value, selections, tab, slot)
    if sad.cur_tab_boxes[slot] == nil then
        sad.cur_tab_boxes[slot] = 0
    end

    if options[value] < 1 then --failsafe
        options[value] = 1
    elseif (options[value] > #selections) then
        options[value] = #selections
    end

    local box_w = 50
    local box_h = 10

    local pos = Vector(90, 3 + sad.cur_tab_boxes[slot] * 15, 0)
    local px, py = frame:GetPos()
    local px2, py2 = frame.main_frame:GetPos()
    px, py = px + px2, py + py2 -- Adds the postion of listview with mainframe to get the actual spot we want to put our checkbox(for mouse in area)
    local framesizex, framesizey = frame:GetWide(), frame:GetTall()
    local slot_move = 180

    if slot == 1 then
        slot_move = 0
    elseif (slot == 2) then
        slot_move = slot_move
    elseif (slot == 3) then
        slot_move = slot_move * 2
    elseif (slot == 4) then
        slot_move = slot_move * 3
    elseif (slot == 5) then
        slot_move = slot_move * 4
    end

    local mouse = sad.MouseInArea(px + (pos.x + slot_move), pos.y + py, box_w, box_h)
    surface.SetDrawColor(Color(0, 0, 0))
    surface.DrawOutlinedRect((pos.x + slot_move) - 1, pos.y - 0.5, box_w + 2, box_h + 2)
    --Outline

    local c = Color(0, 0, 255)
    local tx_c = Color(255, 255, 255)
    local val_tx_c = Color(120, 255, 255)

    --print(#selections)
    draw.RoundedBox(0, pos.x + slot_move, pos.y, box_w, box_h, c)
    --Box
    local re_val = options[value]
    sad.draw_text(selections[re_val], pos.x + slot_move + 8, pos.y - 3, "Sad1-Checkbox", val_tx_c)
    --value text
    sad.draw_text(text, pos.x + slot_move + (box_w + 4), pos.y - 2, "Sad1-Checkbox", tx_c)
    --Text
    sad.cur_tab_boxes[slot] = sad.cur_tab_boxes[slot] + 1 --adds how many spaces it took for the next ui element after it

    if (mouse) then
        if sad.input.MousePressed(MOUSE_LEFT) then
            if options[value] > 1 then
                options[value] = options[value] - 1
            end
        end
        if sad.input.MousePressed(MOUSE_RIGHT) then
            if options[value] < #selections then
                options[value] = options[value] + 1
            end
        end
    end
end

function sad.create_button(frame, text, tab, slot, func)
    if sad.cur_tab_boxes[slot] == nil then
        sad.cur_tab_boxes[slot] = 0
    end

    local box_w = 50
    local box_h = 30

    local pos = Vector(90, 3 + sad.cur_tab_boxes[slot] * 15, 0)
    local px, py = frame:GetPos()
    local px2, py2 = frame.main_frame:GetPos()
    px, py = px + px2, py + py2 -- Adds the postion of listview with mainframe to get the actual spot we want to put our checkbox(for mouse in area)
    local framesizex, framesizey = frame:GetWide(), frame:GetTall()
    local slot_move = 180

    if slot == 1 then
        slot_move = 0
    elseif (slot == 2) then
        slot_move = slot_move
    elseif (slot == 3) then
        slot_move = slot_move * 2
    elseif (slot == 4) then
        slot_move = slot_move * 3
    elseif (slot == 5) then
        slot_move = slot_move * 4
    end

    local mouse = sad.MouseInArea(px + (pos.x + slot_move), pos.y + py, box_w, box_h)
    surface.SetDrawColor(Color(0, 0, 0))
    surface.DrawOutlinedRect((pos.x + slot_move) - 1, pos.y - 0.5, box_w + 2, box_h + 2)
    --Outline

    local c = Color(40, 40, 40)
    local tx_c = Color(255, 255, 255)
    local val_tx_c = Color(120, 255, 255)

    --print(#selections)
    draw.RoundedBox(0, pos.x + slot_move, pos.y, box_w, box_h, c)
    --Box
    sad.draw_text(text, pos.x + slot_move + (box_w / 4) - 4, pos.y + (box_h / 4), "Sad1-Checkbox", tx_c)
    --Text
    sad.cur_tab_boxes[slot] = sad.cur_tab_boxes[slot] + 2.3
    --adds how many spaces it took for the next ui element after it

    if (mouse) then
        if sad.input.MousePressed(MOUSE_LEFT) then
            local func_to_run = func
            if isfunction(func_to_run) == true then
                func_to_run()
            else
                print("[Sad-Bot] function failure")
            end
        end
    end
end

function sad.create_drawtext(frame, text, tab, slot)
    if sad.cur_tab_boxes[slot] == nil then
        sad.cur_tab_boxes[slot] = 0
    end

    local pos = Vector(90, 3 + sad.cur_tab_boxes[slot] * 15, 0)
    local px, py = frame:GetPos()
    local px2, py2 = frame.main_frame:GetPos()
    px, py = px + px2, py + py2 -- Adds the postion of listview with mainframe to get the actual spot we want to put our checkbox(for mouse in area)
    local framesizex, framesizey = frame:GetWide(), frame:GetTall()
    local slot_move = 180

    if slot == 1 then
        slot_move = 0
    elseif (slot == 2) then
        slot_move = slot_move
    elseif (slot == 3) then
        slot_move = slot_move * 2
    elseif (slot == 4) then
        slot_move = slot_move * 3
    elseif (slot == 5) then
        slot_move = slot_move * 4
    end

    --local mouse = sad.MouseInArea(px + (pos.x + slot_move), pos.y + py, box_w, box_h)
    --Draws just text in the menu
    sad.draw_text(text, pos.x + slot_move, pos.y, "Sad1-Checkbox", Color(255, 255, 255))
    sad.cur_tab_boxes[slot] = sad.cur_tab_boxes[slot] + 1.1
    --adds how many spaces it took for the next ui element after it
end

function sad.create_slider(frame, text, value, tab, slot, max, maxDec)
    local cur_val = options[value]
    local slide_size = 70
    if type(cur_val) ~= "number" then
        return
    end
    --print(cur_val)
    local color
    color = Color(200, 200, 200)
    if sad.cur_tab_boxes[slot] == nil then
        sad.cur_tab_boxes[slot] = 0
    end
    local pos = Vector(90, 3 + sad.cur_tab_boxes[slot] * 15, 0)
    local px, py = frame:GetPos()
    local px2, py2 = frame.main_frame:GetPos()
    px, py = px + px2, py + py2 -- Adds the postion of listview with mainframe to get the actual spot we want to put our checkbox(for mouse in area)
    local framesizex, framesizey = frame:GetWide(), frame:GetTall()
    local slot_move = 180
    if slot == 1 then
        slot_move = 0
    elseif (slot == 2) then
        slot_move = slot_move
    elseif (slot == 3) then
        slot_move = slot_move * 2
    elseif (slot == 4) then
        slot_move = slot_move * 3
    elseif (slot == 5) then
        slot_move = slot_move * 4
    end
    local slide_size_div  --ree
    local re = math.ceil(cur_val * slide_size / max)
    local x_slide = re
    surface.SetDrawColor(Color(0, 0, 0))
    surface.DrawOutlinedRect((pos.x + slot_move) - 1, pos.y - 0.5, slide_size + 2, 7)
    --Outline
    draw.RoundedBox(0, pos.x + slot_move, pos.y, slide_size, 5, color)
    --Box
    draw.RoundedBox(0, pos.x + slot_move, pos.y, x_slide, 5, Color(255, 255, 0))
    --Box
    sad.draw_text(text .. ": " .. cur_val, pos.x + slot_move, pos.y + 8, "Sad1-Checkbox", Color(255, 255, 0))
    --Text
    sad.cur_tab_boxes[slot] = sad.cur_tab_boxes[slot] + 1.8
    local mousecheckx, mousehecky = px + (pos.x + slot_move), pos.y + py
    local mouse_in_area =
        sad.MouseInArea(mousecheckx - 3, mousehecky + 2, slide_size + 2, 10) or
        sad.MouseInArea(mousecheckx + 3, mousehecky + 2, slide_size + 2, 10)
    --Real box height is 5 but make it 10 so it's easier to click
    mouse_in_area =
        mouse_in_area or
        (sad.MouseInArea(mousecheckx - 3, mousehecky - 2, slide_size, 10) or
            sad.MouseInArea(mousecheckx + 3, mousehecky - 2, slide_size, 10) or
            sad.MouseInArea(mousecheckx, mousehecky - 2, slide_size, 10))
    if (mouse_in_area) then
        local mouse_press = sad.input.MousePressed(MOUSE_LEFT)
        if input.IsMouseDown(MOUSE_LEFT) or mouse_press then
            local mousex, mousey = gui.MousePos()
            local x_diff = mousex - (px + (pos.x + slot_move))
            x_diff = (slide_size * (x_diff / slide_size)) * (max / slide_size)
            local toSet = Lerp(0.2, options[value], x_diff)
            options[value] = math.Clamp(toSet, 0, max)
            if maxDec then
                options[value] = math.Round(options[value], maxDec)
            else
                options[value] = math.Round(options[value])
            end
        end
    end
end

--Create tabs automatically, just plug them in here
sad.tabs = {
    "Main",
    "Visuals",
    "Pac"
}

function sad.create_tabs(panel) --Adds tabs from the table
    for place, tab in next, sad.tabs do
        sad.create_tab_button(panel, tab, sad.button_color, tab)
    end
end

--Creates a DFrame for the menu and returns the frame to be made(Simplifies the clusterfuck in sad.create_menu_instance)
function sad.setup_menu()
    sad_main_frame = vgui.Create("DFrame")
    sad_main_frame:SetPos(0, 0)
    sad_main_frame:SetSize(800, 500)
    sad_main_frame:Center()
    sad_main_frame:SetTitle("")
    sad_main_frame:SetVisible(true)
    sad_main_frame:SetDraggable(true)
    sad_main_frame:ShowCloseButton(false)
    return sad_main_frame
end

function sad.SuaveSoap(entity, parts)
    if type(parts) ~= "table" then
        return
    end
    print("[Sad-Bot] Dumping " .. entity:Nick())
    local data = {}
    for key, part in pairs(parts) do
        if not part:HasParent() then
            table.insert(data, part:ToTable())
        end
    end
    data = hook.Run("pac_pace.SaveParts", data) or data
    Save_Path = "pac3/" .. "pac_yoink_" .. string.Replace(os.date("%X", os.time()), ":", "-")
    file.CreateDir(Save_Path)
    local savewith = pac.luadata ~= nil and pac or pace
    savewith.luadata.WriteFile(Save_Path .. "/" .. entity:GetName() .. ".txt", data)
    pace.RefreshFiles()
end

function sad.Sav_ULL()
    for k, v in pairs(player.GetAll()) do
        sad.SuaveSoap(v, sad.all_ent_parts[v])
    end
end

function sad.sort_non_tabs(panel) --Sorts ui elements into their respective tabs
    p = panel
    if sad.cur_tab == "Main" then
        sad.create_checkbox(panel, "Aimbot", "main_aimbot", "Main", 1)
        sad.create_checkbox(panel, "Silent", "main_aimbot_silent", "Main", 1)
        sad.create_checkbox(panel, "pSilent", "main_aimbot_psilent", "Main", 1)
        sad.create_checkbox(panel, "Autofire", "main_aimbot_autofire", "Main", 1)
        sad.create_checkbox(panel, "Autoreload", "main_aimbot_autoreload", "Main", 1)
        sad.create_checkbox(panel, "Autowall", "main_aimbot_autowall", "Main", 1)
        sad.create_checkbox(panel, "Team-check", "main_aimbot_teamcheck", "Main", 1)
        sad.create_checkbox(panel, "Prefer-eyepos", "main_aimbot_prefer_eye", "Main", 1)
        sad.create_checkbox(panel, "Ammo check", "main_ammocheck", "Main", 1)
        sad.create_checkbox(panel, "On-M1", "main_aimbotm1", "Main", 1)
        sad.create_checkbox(panel, "Prediction", "main_aimbotpred", "Main", 1)
        sad.create_checkbox(panel, "FOV-Limit", "main_aimbotfov_check", "Main", 1)
        if options.main_aimbotfov_check then
            sad.create_slider(panel, "FOV", "main_aimbotfov", "Main", 1, 360)
        end
        sad.create_slider(panel, "Human", "main_aimbothumanize", "Main", 1, 30, 1)
        if options.main_aimbothumanize > 0 then
            sad.create_slider(panel, "Human-Speed", "main_aimbothumanize_delay", "Main", 1, 0.5, 3)
            sad.create_slider(panel, "Human-Time", "main_aimbothumanize_time", "Main", 1, 0.5, 3)
        end
        sad.create_slider(panel, "Speed", "main_aimbotspeed", "Main", 1, 1, 3)
        sad.create_checkbox(panel, "Delay-shot-smooth", "main_aimbotwait", "Main", 1)
        sad.create_checkbox(panel, "Anti-spread", "main_aimbotspread", "Main", 1)
        sad.create_checkbox(panel, "Anti-recoil", "main_aimbotrecoil", "Main", 1)
        sad.create_checkbox(panel, "Bunny-Hop", "main_bhop", "Main", 2)
        sad.create_checkbox(panel, "Strafer", "main_bhop_strafe", "Main", 2)
        sad.create_checkbox(panel, "Lag-exploit", "main_lag_exploit", "Main", 3)
        if options.main_lag_exploit ~= true then
            sad.create_checkbox(panel, "Fakelag", "main_fakelag", "Main", 3)
            if options.main_fakelag then
                sad.create_slider(panel, "Factor", "main_fakelag_factor", "Main", 3, 15, 1)
            end
        else
            options.main_fakelag = false
        end
        sad.create_checkbox(panel, "Always-Tabbed", "main_tabbed_out", "Main", 4)
        sad.create_checkbox(panel, "Low-Lerp", "main_low_lerp", "Main", 4)
        sad.create_checkbox(panel, "Anti-Aim(HvH!)", "main_anti_aim", "Main", 4)
        sad.create_checkbox(panel, "Anti-Anti-Aim(HvH!)", "main_anti_anti_aim", "Main", 4)
    elseif (sad.cur_tab == "Visuals") then
        sad.create_checkbox(panel, "Balloon-lead", "visuals_balloon_lead", "Visuals", 2)
        sad.create_checkbox(panel, "Recoil", "visuals_crosshair_recoil", "Visuals", 2)
        sad.create_checkbox(panel, "FoV", "visuals_fov_toggle", "Visuals", 2)
        sad.create_checkbox(panel, "Thirdperson", "visuals_thirdperson", "Visuals", 2)
        sad.create_checkbox(panel, "Info", "visuals_info_bar", "Visuals", 3)
        sad.create_checkbox(panel, "Hitmark", "visuals_hit_marker", "Visuals", 3)
        sad.create_slider(panel, "Amount", "visuals_fov", "Main", 2, 120, 0)
        sad.create_checkbox(panel, "Enabled", "visuals_enabled", "Visuals", 1)
        sad.create_checkbox(panel, "Players", "visuals_players", "Visuals", 1)
        sad.create_checkbox(panel, "Npcs", "visuals_npcs", "Visuals", 1)
        sad.create_checkbox(panel, "Target-mark", "visuals_target_indicator", "Visuals", 1)
        sad.create_checkbox(panel, "Render-on-local", "visuals_players_local", "Visuals", 1)
        sad.create_selection(panel, "Player", "visuals_type", {"full", "basic", "simple"}, "Visuals", 1)
        sad.create_selection(panel, "NPC", "visuals_type_npc", {"full", "basic", "simple"}, "Visuals", 1)
    elseif (sad.cur_tab == "Pac") then
        sad.create_drawtext(panel, "This is a work in progress", "Pac", 1)
        sad.create_drawtext(panel, "Pac status - " .. tostring(istable(pac)), "Pac", 1)
        if pac == nil then
            return
        end
        sad.create_drawtext(panel, "Pac data - " .. tostring(table.Count(sad.all_ent_parts)), "Pac", 1)
        sad.create_button(
            panel,
            "Start",
            "Pac",
            1,
            function()
                if sad.start_drama_loaded then
                    sad.all_ent_parts = {}
                    sad.eye_candy_parts = {}
                    sad.start_drama_loaded = false
                    sad.start_drama()
                else
                    sad.all_ent_parts = {}
                    sad.eye_candy_parts = {}
                    sad.start_drama_loaded = false
                    sad.start_drama()
                end
            end
        )
        sad.create_button(
            panel,
            "Save",
            "Pac",
            1,
            function()
                sad.Sav_ULL()
            end
        )
    end
end

function sad.create_menu_instance() --Creates menu
    if sad.frame ~= nil then
        return
    end
    local sad_main_frame = sad.setup_menu()
    sad_main_frame:MakePopup()
    local frame_self = nil
    local sad_scroll_frame = vgui.Create("DScrollPanel", sad_main_frame) --Make this actually work with painted elements that are not apart of derma
    sad_scroll_frame:Dock(BOTTOM)
    sad_scroll_frame:SetSize(740, 480)
    sad_scroll_frame.Paint = function(self, w, h)
        local frame = self
        --draw.RoundedBox( 0, 0, 0, w, h, sad.background_colors)
        frame.main_frame = sad_main_frame
        sad.sort_non_tabs(frame)
        sad.cur_tab_boxes = {}
    end
    sad.create_tabs(sad_main_frame)
    function sad_main_frame.Paint(self, w, h)
        local frame = self
        frame_self = frame
        draw.RoundedBox(0, 0, 0, w, h, sad.background_colors)
        --Background
        draw.RoundedBox(0, 0, 0, 88, h, sad.button_bar_color) --Buttons bar
        draw.RoundedBox(0, 0, 0, w, 5, sad.corner_colors)
        --Top bar
        draw.RoundedBox(0, 0, 0, 5, h, sad.corner_colors)
        --Left side bar
        draw.RoundedBox(0, w - 5, 0, 5, h, sad.corner_colors)
        --Right side bar
        draw.RoundedBox(0, 0, h - 5, w, h, sad.corner_colors)
        --Bottom bar
        --local tx = "Sad-Bot v2 by Tuxy"
        --local width, height = surface.GetTextSize( tx )
        --sad.draw_text(tx, (w/2) - 40, 0, "Sad1", Color(255,255,255))
        if sad.cur_tab ~= sad.previous_tab then
            sad.previous_tab = sad.cur_tab
        end
    end
    sad.buttons = 0
    sad.frame = sad_main_frame
    sad.menu_open = true
end

function sad.destroy_menu_instance() --Remove menu if visible
    if sad.frame ~= nil then
        sad.frame:Remove()
        sad.frame = nil
        sad.menu_open = false
    end
end

function sad.menu_think() --Process menu open and close key
    local menu_key = sad.input.ButtonPressed(KEY_INSERT)
    if menu_key then
        if sad.menu_open == false then
            sad.create_menu_instance()
        else
            sad.destroy_menu_instance()
        end
    end
end

--Config-Auto-save
timer.Create(
    "config_sort",
    0,
    0.3,
    function()
        if sad == nil then
            LocalPlayer():ChatPrint("config failure, reload script")
            timer.Remove("config_sort")
            return
        end
        if sad.frame then
            sad.saveconfig()
        end
    end
)

timer.Simple(
    0.1,
    function()
        if sad == nil then
            LocalPlayer():ChatPrint("config failure, reload script")
            timer.Remove("config_sort")
            return
        end
        print("[Sad-Bot] Config loaded")
        sad.loadconfig()
    end
)
--Config/Menu option autosave/load end
--Menu end

--Hooks
local servertime = 0
--Visual hooks
--Gets bext box bounds for esp
function sad.GetPLYBoxPos(v)
    if v == nil then
        return
    end
    local v = v
    local pos3D = v:GetPos()
    local max = v:OBBMaxs()
    local min = v:OBBMins()
    local Top = 0
    Bottom = 0
    Left = 0
    Right = 0
    local Points = {}
    local ScreenPoints = {}
    Points[0] = pos3D + Vector(max.x, max.y, max.z)
    Points[1] = pos3D + Vector(max.x, min.y, max.z)
    Points[2] = pos3D + Vector(min.x, max.y, max.z)
    Points[3] = pos3D + Vector(min.x, min.y, max.z)
    Points[4] = pos3D + Vector(max.x, max.y, min.z)
    Points[5] = pos3D + Vector(max.x, min.y, min.z)
    Points[6] = pos3D + Vector(min.x, max.y, min.z)
    Points[7] = pos3D + Vector(min.x, min.y, min.z)
    for i = 0, 7 do
        ScreenPoints[i] = Points[i]:ToScreen()
        if (i == 0) then
            Right = ScreenPoints[0].x
            Left = Right
            Bottom = ScreenPoints[0].y
            Top = Bottom
        --continue;
        end
        if (ScreenPoints[i].x < Left) then
            Left = ScreenPoints[i].x
        elseif (ScreenPoints[i].x > Right) then
            Right = ScreenPoints[i].x
        end
        if (ScreenPoints[i].y < Top) then
            Top = ScreenPoints[i].y
        elseif (ScreenPoints[i].y > Bottom) then
            Bottom = ScreenPoints[i].y
        end
    end
    UpperLeft = Vector(Left, Top, 0)
    UpperRight = Vector(Right, Top, 0)
    BottomLeft = Vector(Left, Bottom, 0)
    width = Right - Left
    height = Bottom - Top
    return {width, height, UpperLeft, pos3D, UpperRight, BottomLeft}
end

local last_ply_render = SysTime()
function sad.ply_esp(players) --Most esp elements are from the previous sadbot.
    if sad.get_target == nil then
        return
    end
    local full_mode = options.visuals_type == 1
    local basic_mode = options.visuals_type == 2
    local simple_mode = options.visuals_type == 3
    for k, v in pairs(players) do
        local isValid = v:IsValid()
        if isValid == true then
            local isSafe = (v:Alive() and v:Health() > 0) and (v:IsDormant() ~= true)
            if v == LocalPlayer() and options.visuals_players_local ~= true then
                isSafe = false
            end
            local pos_o = sad.GetPLYBoxPos(v)
            local w = pos_o[1]
            local h = pos_o[2]
            local pos = pos_o[3]
            local teamColor = team.GetColor(v:Team())
            if sad.visibletoscreen(pos.x, pos.y) and isSafe then
                local bottom_pos_y = pos.y + h
                if full_mode then
                    draw.OutlinedBox(pos.x, pos.y, w, h, teamColor)
                end
                local vName = v.Nick and v:Nick() or (v.GetName and v:GetName() or v:GetClass())
                if vName then
                    if full_mode then
                        sad.draw_text(vName, pos.x, pos.y - 13, "Sad1-Esp", Color(255, 255, 255))
                    else
                        sad.draw_text(vName, pos.x, bottom_pos_y + 10, "Sad1-Esp", Color(255, 255, 255))
                    end
                end
                local wep = v.GetActiveWeapon
                if wep then
                    local w = v:GetActiveWeapon()
                    local nullCheck = tostring(w) == "[NULL Entity]"
                    if w ~= nil and nullCheck == false then
                        w = w:GetClass()
                        sad.draw_text(w or "nil", pos.x, bottom_pos_y, "Sad1-Esp", Color(255, 255, 255))
                    else
                        local bottom_pos_y = pos.y + h
                        sad.draw_text("nil", pos.x, bottom_pos_y, "Sad1-Esp", Color(255, 255, 255))
                    end
                end
                local hp = v:Health()
                local hpc = math.Clamp(hp, 0, 100)
                local apc = math.Clamp(v:Armor(), 0, 100)
                local proper_h_hp = h * (hpc / 100)
                local proper_h_ar = h * (apc / 100)
                local size = 3
                if full_mode or basic_mode then
                    draw.RoundedBox(
                        0,
                        pos.x - (size + 1),
                        pos.y + (h - proper_h_hp),
                        size,
                        proper_h_hp,
                        Color(100 - hpc, 2.55 * hpc, 0)
                    )
                    draw.RoundedBox(
                        0,
                        pos.x - (size + 5),
                        pos.y + (h - proper_h_ar),
                        size,
                        proper_h_ar,
                        Color(100 - apc, 0, 2.55 * apc)
                    )
                else
                    sad.draw_text("HP:" .. hp, pos.x, bottom_pos_y + 20, "Sad1-Esp", Color(100 - hpc, 2.55 * hpc, 0))
                    sad.draw_text(
                        "AR:" .. v:Armor(),
                        pos.x,
                        bottom_pos_y + 30,
                        "Sad1-Esp",
                        Color(100 - apc, 0, 2.55 * apc)
                    )
                end
                if v == LocalPlayer() then 
                    local net_pos = (LocalPlayer():GetNetworkOrigin() + Vector(0,0,30)):ToScreen()
                    draw.RoundedBox(2, net_pos.x, net_pos.y, 5, 5, Color(255,0,0))
                end
                local target_get = sad.get_target()
                if target_get then
                    if target_get[1] == v then
                        local pos = target_get[2]:ToScreen()
                        if options.visuals_target_indicator then
                            draw.RoundedBox(2, pos.x, pos.y, 5, 5, Color(255,0,0))
                        end
                    end
                end
            end
        end
    end
end

local last_npc_render = SysTime()
function sad.npc_esp(list) --Most esp elements are from the previous sadbot.
    if sad.get_target == nil then
        return
    end
    local full_mode = options.visuals_type_npc == 1
    local basic_mode = options.visuals_type_npc == 2
    local simple_mode = options.visuals_type_npc == 3
    for k, v in pairs(list) do
        local isValid = v:IsValid()
        if isValid == true then
            local isSafe = (v:Health() > 0) and (v:IsDormant() ~= true) and (v ~= LocalPlayer())
            local pos_o = sad.GetPLYBoxPos(v)
            local w = pos_o[1]
            local h = pos_o[2]
            local pos = pos_o[3]
            local teamColor = Color(255, 255, 255)
            local bottom_pos_y = pos.y + h
            if sad.visibletoscreen(pos.x, pos.y) then
                if full_mode then
                    draw.OutlinedBox(pos.x, pos.y, w, h, Color(teamColor))
                end
                local vName = v.Nick and v:Nick() or (v.GetName and v:GetName() or v:GetClass())
                if vName then
                    if full_mode then
                        sad.draw_text(vName, pos.x, pos.y - 13, "Sad1-Esp", Color(255, 255, 255))
                    else
                        sad.draw_text(vName, pos.x, bottom_pos_y + 10, "Sad1-Esp", Color(255, 255, 255))
                    end
                end
                local wep = v.GetActiveWeapon
                if wep then
                    local w = v:GetActiveWeapon()
                    local nullCheck = tostring(w) == "[NULL Entity]"
                    if w ~= nil and nullCheck == false then
                        w = w:GetClass()
                        sad.draw_text(w or "nil", pos.x, bottom_pos_y, "Sad1-Esp", Color(255, 255, 255))
                    else
                        local bottom_pos_y = pos.y + h
                        sad.draw_text("nil", pos.x, bottom_pos_y, "Sad1-Esp", Color(255, 255, 255))
                    end
                end
                local hp = v:Health()
                local hpc = math.Clamp(hp, 0, 100)
                local proper_h_hp = h * (hpc / 100)
                local size = 3
                if full_mode or basic_mode then
                    draw.RoundedBox(
                        0,
                        pos.x - (size + 1),
                        pos.y + (h - proper_h_hp),
                        size,
                        proper_h_hp,
                        Color(100 - hpc, 2.55 * hpc, 0)
                    )
                else
                    sad.draw_text("HP:" .. hp, pos.x, bottom_pos_y + 20, "Sad1-Esp", Color(100 - hpc, 2.55 * hpc, 0))
                end
                local target_get = sad.get_target()
                if target_get then
                    if target_get[1] == v then
                        local pos = target_get[2]:ToScreen()
                        if options.visuals_target_indicator then
                            draw.RoundedBox(2, pos.x, pos.y, 5, 5, Color(255,0,0))
                        end
                    end
                end
            end
        end
    end
end

sad.die = false
function sad.balloon_lead_func() --I made this in a standalone script but i'm adding it here lazily since I don't feel like converting it properly.
    local travel_vel = 1940
    local finalpos =
        LocalPlayer():GetEyeTrace().HitPos -
        ((LocalPlayer():GetVelocity() - Vector(0, 0, travel_vel)) * engine.TickInterval() * 0.5)
    local towards_me = finalpos - (LocalPlayer():GetPos())
    towards_me = towards_me:Angle()
    local tr =
        util.TraceLine(
        {
            start = finalpos,
            endpos = finalpos + towards_me:Up() * 150
            --filter = {LocalPlayer()}
        }
    )
    local distancetotuxy = sad.distance_point_to_line(LocalPlayer():GetPos(), finalpos, finalpos + towards_me:Up())
    local distance = LocalPlayer():GetPos():Distance(finalpos)
    local time = ((distance / travel_vel) * 1000) + LocalPlayer():Ping()
    time = time / 1000
    local me_pos = LocalPlayer():GetPos() + (Vector(0, 0, 1939) * time)
    local diff = me_pos - finalpos
    diff = diff.x
    finalpos = finalpos:ToScreen()
    local color = Color(255, 0, 0)
    if diff < 15 and diff >= -2 then
        color = Color(0, 255, 0)
    end
    --filter = function( ent ) if ( ent:GetClass() == "prop_physics" ) then return true end end
    draw.RoundedBox(0, finalpos.x, finalpos.y - 2, 5, 5, Color(0, 0, 0))
    draw.RoundedBox(0, finalpos.x, finalpos.y + 2, 5, 5, Color(0, 0, 0))
    draw.RoundedBox(0, finalpos.x - 2, finalpos.y, 5, 5, Color(255, 255, 255))
    draw.RoundedBox(0, finalpos.x + 2, finalpos.y, 5, 5, Color(255, 255, 255))
    draw.RoundedBox(0, finalpos.x, finalpos.y, 5, 5, color)
    local tr_pos = tr.HitPos:ToScreen()
    draw.RoundedBox(0, tr_pos.x, tr_pos.y, 5, 5, Color(255, 0, 255))
    if tr.Entity == LocalPlayer() then
        sad.die = true
        draw.SimpleText(
            "die",
            "DermaDefault",
            600,
            600 + 62,
            Color(255, 255, 255, 255),
            TEXT_ALIGN_CENTER,
            TEXT_ALIGN_TOP
        )
    else
        sad.die = false
    end
    --end
    --end
end

function sad.crosshair()
    if options.visuals_crosshair_recoil then
        local w = LocalPlayer():GetActiveWeapon()
        local nullCheck = tostring(w) == "[NULL Entity]"
        if nullCheck ~= true then
            local punch = LocalPlayer():GetViewPunchAngles().x + LocalPlayer():GetViewPunchAngles().y
            punch = punch * 10
            local w = ScrW() / 2
            local h = ScrH() / 2
            local size = 2
            surface.DrawCircle(w, h, size, 200, 200, 200, 50 )
            surface.DrawCircle(w, h, size+0.5, 0, 0, 0, 50 )
            surface.DrawCircle(w, h, punch, 255, 0, 0, 50)
            --surface.DrawCircle(originX, originY, radius, r, g, b, a=255)
        end
    end
end

--FLOW_OUTGOING = 0
--FLOW_INCOMING = 1
--MAX_FLOWS = 2
function sad.InfoBar()
    if options.visuals_info_bar ~= true then
        return
    end
    local netchan = sad.get_netchan()
    local me = LocalPlayer()
    draw.RoundedBox(0, 1520, 20, 200, 90, Color(255, 0, 120, 120))
    local x, y = 1520, 20
    local outgoing_latency = math.Round(netchan:GetLatency(0) * 1000)
    local incoming_latency = math.Round(netchan:GetLatency(1) * 1000)
    local frametime = math.Round(RealFrameTime() * 1000)
    local fps = math.Round(1 / FrameTime())
    draw.DrawText("out:" .. outgoing_latency .. "ms", "Sad1", x, y, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
    draw.DrawText("in:" .. incoming_latency .. "ms", "Sad1", x + 90, y, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
    draw.DrawText(
        "frametime:" .. frametime .. "ms" .. "(" .. fps .. ")ps",
        "Sad1",
        x,
        y + 11,
        Color(255, 255, 255, 255),
        TEXT_ALIGN_LEFT
    )
    draw.DrawText("outseq:" .. netchan:GetOutSeq(), "Sad1", x, y + 22, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
    if me.IsTabbedOut then
        draw.DrawText(
            "[dlib] tab-out:" .. tostring(me:IsTabbedOut()),
            "Sad1",
            x,
            y + 33,
            Color(255, 255, 255, 255),
            TEXT_ALIGN_LEFT
        )
    end
    if sad.predict_mode_extra == nil then sad.predict_mode_extra = false; end
    if sad.shots_fired_aaa ~= nil then
        draw.DrawText("shots_fired:" .. tostring(sad.shots_fired_aaa), "Sad1", x, y + 44, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
    end
    if sad.pitch_aaa_mode ~= nil then
        draw.DrawText("pitch_correction:" .. tostring(sad.pitch_aaa_mode), "Sad1", x, y + 55, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
    end
    if sad.yaw_aaa_mode ~= nil then
        draw.DrawText("yaw_correction:" .. tostring(sad.yaw_aaa_mode), "Sad1", x, y + 66, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
    end
    if sad.viewangles ~= nil then
        draw.DrawText("angs:" .. tostring(sad.viewangles), "Sad1", x, y + 77, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
    end
    --if LocalPlayer().last_lc_broke ~= nil then
        --draw.DrawText("lag_comp_broke:" .. tostring(LocalPlayer().last_lc_broke), "Sad1", x, y + 77, Color(255, 255, 255, 255), TEXT_ALIGN_LEFT)
    --end
end

gameevent.Listen( "player_hurt" )
sad.AddHook( "player_hurt", "thurt", function( data )
	local health = data.health
	local id = data.userid
    local attackerid = data.attacker
    if attackerid == LocalPlayer():UserID() and options.visuals_hit_marker then
        sad.last_hit = CurTime()
        if sad.hits == nil then sad.hits = 0; end
        sad.hits = sad.hits + 1
        surface.PlaySound("npc/barnacle/neck_snap1.wav")
        surface.PlaySound("npc/barnacle/neck_snap1.wav")
        surface.PlaySound("npc/barnacle/neck_snap1.wav")
        surface.PlaySound("npc/barnacle/neck_snap1.wav")
    end
end )

function sad.aa_indicator()
    if options.main_anti_aim then
        local reeAngs = Angle(0, sad.antiaimvreal.y, 0)
        local feeAngs = Angle(0, sad.antiaimvfake.y, 0)
        local realpos = Vector(LocalPlayer():GetPos() + reeAngs:Forward()*30):ToScreen()
        local fakepos = Vector(LocalPlayer():GetPos() + feeAngs:Forward()*30):ToScreen()
        local mepos = LocalPlayer():GetPos():ToScreen()
        --draw.RoundedBox(0, mepos.x, mepos.y, 2, 2, Color(0,0,255,255))
        if sad.visibletoscreen(realpos.x, realpos.y) then
            draw.Line(mepos.x, mepos.y, realpos.x, realpos.y, Color(0,255,0))
            sad.draw_text("real", realpos.x, realpos.y, "Sad1", Color(0,255,0)) 
            --text, x, y, font, color
        end
        if sad.visibletoscreen(fakepos.x, fakepos.y)  then
            draw.Line(mepos.x, mepos.y, fakepos.x, fakepos.y, Color(255,0,0))
            sad.draw_text("fake", fakepos.x, fakepos.y, "Sad1", Color(255,0,0))  
        end
    end
end

function sad.hit_mark()
    if options.visuals_hit_marker and sad.last_hit and sad.hits > 0 then
        local time = CurTime() - sad.last_hit 
        if time <= 1.5 then
            local w, h = ScrW(), ScrH()
            surface.DrawCircle(w/2, h/2, math.Clamp(10 + sad.hits * 2.5, 0, 60), 0, 0, 255, 50)
            if time >= 0.3 then
                sad.hits = math.Clamp(sad.hits - 1, 0, 100000000)
                sad.last_hit = CurTime()
            end
        else
            sad.hits = 0
        end
    end
end

function sad.wallbang_indicator()
    if sad.clientview == nil then return; end
    local end_pos = (LocalPlayer():GetShootPos() + sad.clientview:Forward()) * 10
    local can_bang = sad.CanWallbang(LocalPlayer():GetShootPos(), end_pos)
    --print(can_Bang)
    local w, h = ScrW(), ScrH()
    sad.draw_text(tostring(can_bang), w/2, (h/2) - 10, "Sad1", Color(255,0,0))
end

function sad.HUDPaint() 
    if ss then return; end
    if options.visuals_enabled ~= true then
        return
    end
    if options.visuals_balloon_lead then
        sad.balloon_lead_func()
    end
    sad.hit_mark()
    sad.aa_indicator()
    sad.InfoBar()
    sad.crosshair()
    --sad.wallbang_indicator()
    local players = player.GetAll()
    if options.visuals_players then
        if SysTime() - last_ply_render > 0.001 then --Runs render every 3ms + hudpaintcall instead of when hudpaint is called instantly to help with lag
            sad.ply_esp(players)
            last_ply_render = SysTime()
        end
    end
    if options.visuals_npcs then
        local npc_list = ents.FindByClass("npc_*")
        if SysTime() - last_npc_render > 0.001 then --Runs render every 3ms + hudpaintcall instead of when hudpaint is called instantly to help with lag
            sad.npc_esp(npc_list)
            last_npc_render = SysTime()
        end
    end
end
sad.AddHook("HUDPaint", "sad_hudpaint", sad.HUDPaint)
--Visual hooks end

--CreatemoveHook

sad.AddHook(
    "Move",
    "",
    function()
        if (IsFirstTimePredicted() ~= true) then
            return
        end
        servertime = CurTime() + engine.TickInterval()
    end
)

--main_aimbot
function sad.find_best(ent)
    c_dist = 9999
    bestbone = 0
    for i = 0, 67 do
        if ent:GetBoneName(6) == "ValveBiped.Bip01_Head1" then return 6; end
        if ent:GetBoneName(i) ~= nil then
            local pos = Vector(ent:GetBonePosition(i))
            local pos_parent = ent:GetBonePosition(ent:GetBoneParent( i ))
            pos_parent = Vector(pos_parent)
            --local eye = ent:EyePos()
            local eye = ent.GetShootPos and ent:GetShootPos() or ent:EyePos()
            local eye_angs = ent:GetAngles()
            eye = eye + eye_angs:Forward() * 7
            local dist = pos:Distance(eye)
            local p_dist = pos_parent:Distance(eye)
            if p_dist < c_dist or dist < c_dist then
                if p_dist > dist then
                    c_dist = dist
                    bestbone = i
                else
                    c_dist = p_dist
                    bestbone = ent:GetBoneParent( i )
                end
            end
        end
    end
    return bestbone
end

function sad.NormalizeAngle(ang)
    ang.x = math.NormalizeAngle(ang.x)
    ang.x = math.Clamp(ang.p, -89, 89)
    ang.z = math.Clamp(ang.z, -20, 20)
end

function sad.NormalizeAngleNoClamp(ang)
    ang.x = math.NormalizeAngle(ang.x)
    --ang.x = math.Clamp(ang.p, -89, 89)
    ang.z = math.Clamp(ang.z, -20, 20)
end

function sad.get_headpos(ent)
    local bone = 6
    if ent == nil then
        return bone
    end
    if ent.bestbone == nil then
        bone = sad.find_best(ent)
        ent.foundmodel = ent:GetModel()
    else
        if ent.foundmodel == nil then
            bone = sad.find_best(ent)
            ent.foundmodel = ent:GetModel()
        else
            if ent.foundmodel ~= ent:GetModel() then
                bone = sad.find_best(ent)
                ent.foundmodel = ent:GetModel()
            else
                bone = ent.bestbone
            end
        end
    end
    local eyepos = ent.GetShootPos and ent:GetShootPos() or ent:GetBonePosition(bone)
    local eye_angs = ent:EyeAngles()
    sad.NormalizeAngle(eye_angs)
    eyepos = eyepos + eye_angs:Forward() * 7
    eyepos = eyepos + Vector(0, 0, 0)
    local bone_pos = ent:GetBonePosition(bone)
    if ent:GetBoneName(6) == "ValveBiped.Bip01_Head1" then
        bone_pos = bone_pos + Vector(2, 0, 3)
    end
    return options.main_aimbot_prefer_eye and eyepos or bone_pos 
end

function sad.aim_prediction(pos, ent, customvel)
    if options.main_aimbotpred ~= true then
        return pos
    end
    if customvel == nil then
        customvel = ent:GetVelocity()
    end
    local w = LocalPlayer():GetActiveWeapon()
    local nullCheck = tostring(w) == "[NULL Entity]"
    if nullCheck then
        return pos
    end
    if (w == nil or w:IsValid() == false) then
        return pos
    end

    local gravity = physenv.GetGravity()
    local graviy_len = gravity:Length()

    local velocity = customvel
    --velocity.z = velocity.z - (graviy_len * engine.TickInterval())

    local me_velocity = LocalPlayer():GetVelocity()
    
    local endResult
    if w:GetClass() == "weapon_crossbow" then
        netchan = sad.get_netchan()
        if netchan == nil then
            return
        end
        local lerptime =
            (math.max(
            GetConVarNumber("cl_interp"),
            GetConVarNumber("cl_interp_ratio") / GetConVarNumber("cl_updaterate")
        ))
        local travel_latency = sad.TIME_TO_TICKS(netchan:GetLatency(0) + lerptime)
        local distance = LocalPlayer():GetShootPos():Distance(pos)
        local time = (distance / 3500)
        pos = pos + (velocity * time)
        endResult = pos - ((me_velocity - velocity) * (engine.TickInterval() * travel_latency))
        endResult.z = endResult.z - 5
    else
        local g = FrameTime()
        local fps = math.Round(1 / FrameTime())
        local v = ent --i'm lazy
        local new_pos = pos
        if v.skip_count == nil then v.skip_count = 0; end
        if v.old_pos ~= nil then
            local dist = pos - v.old_pos
            local old_old_pos = v.old_pos
            v.old_pos = pos
            if old_old_pos == v.old_pos and velocity:Length() > 1 then
                v.skip_count = v.skip_count + 1
            else
                v.skip_count = 0
            end
            dist = dist:Length2DSqr()
            if dist > 4096 then
                new_pos = new_pos + (velocity * engine.TickInterval() * v.skip_count * LocalPlayer().choked_ticks)
            end
        else
            v.old_pos = pos
            v.old_vel = velocity
        end
        local pred_result = new_pos - ((me_velocity - velocity) * engine.TickInterval())
        endResult = pred_result
    end

    return endResult
end

sad.npc_target_blacklist = {
    ["npc_satchel"] = true,
    ["npc_grenade_frag"] = true,
    ["npc_grenade_bugbait"] = true
}

function sad.CanWallbang(sp, ep, ent)
    if options.main_aimbot_autowall ~= true then return false; end
    local fil
    if ent then
        fil = {ent, LocalPlayer()}
    else
        fil = {LocalPlayer()}
    end
    local tdata = {
    	start = sp,
        endpos = ep,
        filter = fil,
    	mask = 1577075107
    }

    local wall = util.TraceLine(tdata)
    tdata.start = ep 
    tdata.endpos = sp
    local wall2 = util.TraceLine(tdata)
    if 17.5 > (wall2.HitPos - wall.HitPos):Length2D() then
    	return true
    else
    	return false
    end
end

function sad.get_target()
    if sad.clientview == nil then return; end
    local all_ents = player.GetAll()
    table.Add(all_ents, ents.FindByClass("npc_*"))
    local best_target = nil
    local best_dist = 9999
    for k, v in pairs(all_ents) do
        local ent_safe = v:IsValid() and (v ~= LocalPlayer()) and (v:IsDormant() ~= true) and (v:Health() > 0) or false
        if v.Team then
            if tostring(v:Team()) == tostring(LocalPlayer():Team()) and options.main_aimbot_teamcheck then
                ent_safe = false
            end
        else
            ent_safe = false
        end
        if ent_safe then
            local headpos = sad.aim_prediction(sad.get_headpos(v), v)
            local me_head = sad.get_headpos(LocalPlayer())
            local view_dir = (sad.clientview + LocalPlayer():GetViewPunchAngles()):Forward()
            local dist_to_ent = sad.distance_point_to_line(headpos, me_head, view_dir)
            local head_vis = sad.SpotIsVisible(headpos, v) or sad.CanWallbang(LocalPlayer():GetShootPos(), headpos, v)
            local in_fov = sad.IsInFov(headpos, options.main_aimbotfov)
            local wanted = sad.npc_target_blacklist[v:GetClass()] ~= true
            --print(wanted)
            if wanted and dist_to_ent < best_dist and in_fov and head_vis then
                best_target = v
                best_dist = dist_to_ent
            end
        end
    end
    if best_target then
        sad.aimtarget = best_target
        local aim_ang = sad.aim_prediction(sad.get_headpos(best_target), best_target) - LocalPlayer():GetShootPos()
        aim_ang = aim_ang:Angle()
        return {best_target, sad.aim_prediction(sad.get_headpos(best_target), best_target), aim_ang}
    else
        return nil
    end
end

function sad.NormalizeAngle(ang)
    ang.x = math.NormalizeAngle(ang.x)
    ang.x = math.Clamp(ang.p, -89, 89)
    ang.z = 0
end

function sad.GetFas2Cone( cmd ) --thanks odium
    local ply = LocalPlayer()
    local gun = ply:GetActiveWeapon()
    local newang = ply:GetPunchAngle()
    math.randomseed( CurTime() )
    local cuntcone = gun.CurCone
    return newang
end

function sad.PredictSpread(cmd, ang)
    local wep = LocalPlayer():GetActiveWeapon() or nil
    if wep:IsValid() ~= true then
        return ang
    end
    if wep ~= nil then
        if wep.HipCone then return ang; end
        local wep_spread = spread[wep:GetClass()]
        if (wep_spread == nil) then
            return
        end
        local iCmdNumber = cmd:CommandNumber( )
        if( iCmdNumber == 0 ) then
        return end 

        local seed = md5.PseudoRandom(iCmdNumber)
         --No need to %256 since the function returns just 1 byte
        local x = engineSpread[seed][1]
        local y = engineSpread[seed][2]

        local forward = ang:Forward()
        local right = ang:Right()
        local up = ang:Up()

        local cd = forward + (x * wep_spread.x * right * -1) + (y * wep_spread.y * up * -1)

        local spreadAngles = cd:Angle()

        spreadAngles:Normalize()
        return spreadAngles
    end
end

function sad.PredictRecoil(cmd, ang) --Seeing if this works
    local wep = LocalPlayer():GetActiveWeapon() or nil
    if wep:IsValid() ~= true then
        return ang
    end
    if wep ~= nil then
        local punh = LocalPlayer():GetViewPunchAngles()
        if options.main_aimbotspread then
            local angle
            if options.main_aimbotrecoil then
                angle = sad.PredictSpread(cmd, (ang - punh))
            else
                angle = sad.PredictSpread(cmd, (ang))
            end
            if angle == nil and options.main_aimbotrecoil then
                return ang - punh
            end
            return sad.PredictSpread(cmd, (ang - punh))
        else
            if options.main_aimbotrecoil then
                return ang - punh
            else
                return ang
            end
        end
    end
end

--shitty aimbot/aa math

function sad.FixMove(cmd, ange)
	local angs = cmd:GetViewAngles()
	local fa = sad.clientview or Angle(0,0,0)
	if ange then
		fa = ange
    end
    angs.x = math.NormalizeAngle( angs.x )
    angs.y = math.NormalizeAngle( angs.y )
    angs = Angle(angs.x, angs.y, angs.z)
    --TODO fix high yaw values?
	local viewang = Angle(0, angs.y, 0)
    local fix = Vector(cmd:GetForwardMove(), cmd:GetSideMove(), 0)
    if fix == nil then return; end
    fix = (fix:Angle() + (viewang - fa)):Forward() * fix:Length()
    if angs.p > 90 or angs.p < -90 then
		fix.x = -fix.x
	end
	cmd:SetForwardMove(fix.x)
	cmd:SetSideMove(fix.y)
end

function sad.AngleVectors(angles)	
	local forward, right, up = Vector(), Vector(), Vector()
	local sr, sp, sy, cr, cp, cy

	local sy, cy = math.sin(angles[2]), math.cos(angles[2])
	local sp, cp = math.sin(angles[1]), math.cos(angles[1])
	local sr, cr = math.sin(angles[3]), math.cos(angles[3])

	forward.x = cp * cy
	forward.y = cp * sy
	forward.z = -sp

	right.x = -1 * sr * sp * cy + -1 * cr * -sy
	right.y = -1 * sr * sp * sy + -1 * cr * cy
	right.z = -1 * sr * cp

	up.x = cr * sp * cy + -sr * -sy
	up.y = cr * sp * sy + -sr * cy
	up.z = cr * cp

	return forward, right, up
end

local lastReload = servertime
local last_humanize = SysTime()
local isfiring = false
function sad.aimbot(cmd)
    if LocalPlayer():Alive() ~= true then return; end
    if sad.clientview == nil then print("no clientview(aimbot)"); return; end
    if options.main_aimbot ~= true then
        return
    end
    local forwardmove = cmd:GetForwardMove();
    local upmove = cmd:GetUpMove();
    local sidemove = cmd:GetSideMove();
    local w = LocalPlayer():GetActiveWeapon()
    local nullCheck = tostring(w) == "[NULL Entity]"
    if w.GetNextPrimaryFire == nil then return; end
    if options.main_ammocheck == true then
        if w ~= nil and nullCheck == false and w:Clip1() < 1 then
            if w.HasAmmo == nil then return; end
            if w:HasAmmo() == false then isfiring = false; return; end
            if cmd:KeyDown(IN_RELOAD) ~= true and options.main_aimbot_autoreload then
                if lastReload == nil then lastReload = servertime; end
                if servertime - lastReload > 0.1 then
                    cmd:SetButtons(cmd:GetButtons() + IN_RELOAD);
                    lastReload = servertime
                end
            end
            isfiring = false;
            return;
        end
    end
    local target_info = sad.get_target()
    if target_info == nil then
        isfiring = false
        return
    end
    local target = target_info[1]
    local aim_angle = target_info[3]
    local viewangles = sad.clientview

    if options.main_aimbotm1 and (cmd:KeyDown(IN_ATTACK) ~= true) then
        return
    end
    --randomize the angle, keep it interesting for spectators.
    --the lower the smoother, the higher the snappier
    local old_aim_angle
    if options.main_aimbotspeed < 1 then
        aim_angle = sad.PredictRecoil(cmd, aim_angle)
        old_aim_angle = aim_angle
        aim_angle = LerpAngle(options.main_aimbotspeed, viewangles, aim_angle)
    else
        aim_angle = sad.PredictRecoil(cmd, aim_angle)
        old_aim_angle = aim_angle
    end

    if options.main_aimbothumanize > 0 then
        local human_factor =
            Angle(
            math.random(-options.main_aimbothumanize, options.main_aimbothumanize),
            math.random(-options.main_aimbothumanize, options.main_aimbothumanize),
            0
        )
        if SysTime() - last_humanize > options.main_aimbothumanize_time then
            aim_angle.x = Lerp(options.main_aimbothumanize_delay, aim_angle.x, aim_angle.x + human_factor.x)
            aim_angle.y = Lerp(options.main_aimbothumanize_delay, aim_angle.y, aim_angle.y + human_factor.y)
            last_humanize = SysTime()
        end
    --aim_angle = LerpAngle(0.1, cmd:GetViewAngles(), viewangles + human_factor)
    end

    local clamped_angle = aim_angle
    if clamped_angle == nil then return; end
    sad.NormalizeAngle(clamped_angle)
    local curangdiff = math.abs(math.AngleDifference(viewangles.y, old_aim_angle.y))
    local curangdiffx = math.abs(math.AngleDifference(viewangles.x, old_aim_angle.x))
    local canShoot
    if options.main_aimbotwait then
        canShoot = tobool(curangdiff < 0.5 and curangdiffx < 1)
    else
        canShoot = true
    end

    if canShoot ~= true then
        cmd:RemoveKey(IN_ATTACK)
    end
    --cmd:SetViewAngles(clamped_angle)
    --if options.main_aimbot_silent then sad.FixMove( cmd ) end
    if options.main_aimbot_autofire then
        local oldview = cmd:GetViewAngles()
        if( isfiring == false and w:GetNextPrimaryFire() <= servertime and bSendPacket) then
            isfiring = true;
            cmd:SetViewAngles(clamped_angle)
            cmd:SetButtons( bit.bor( cmd:GetButtons(), IN_ATTACK ) ) 
        else              
            cmd:SetButtons( bit.band( cmd:GetButtons(), bit.bnot( IN_ATTACK ) ) )  
            isfiring = false
        end
    else
        cmd:SetViewAngles(clamped_angle)
        if( isfiring == false and w:GetNextPrimaryFire() <= servertime and cmd:KeyDown(IN_ATTACK)) then
            isfiring = true
        else
            isfiring = false
        end
    end
end
--main_aimbot end

local RightMovement
local IsActive
local StrafeAngle = 0

function sad.GetTraceFraction(start, final)
    local tr = util.TraceLine( {
        start = start,
        endpos = final,
        filter = {LocalPlayer()},
    } )
    return tr.Fraction
end

function sad.StartCStrafer(cmd) --kmeth cstrafer in lua lol
    if sad.clientview == nil then return; end
    if sad.AngleVectors == nil then return; end
	StrafeAngle = 0;
	IsActive = true;

	local CurrentAngles = sad.clientview;
    CurrentAngles.x = 0;
    
	local Forward = CurrentAngles:Forward();
	local Right = Forward:Cross(Vector(0, 0, 1));
    local Left = Vector(Right.x * -1, Right.y * -1, Right.z);
    --print(Forward, Right, Left)

    local leftpath = sad.GetTraceFraction(LocalPlayer():GetPos()+ Vector(0, 0, 10), LocalPlayer():GetPos() + (Left * 250) + Vector(0, 0, 10))
    local rightpath = sad.GetTraceFraction(LocalPlayer():GetPos()+ Vector(0, 0, 10), LocalPlayer():GetPos() + (Right * 250) + Vector(0, 0, 10))

    if (leftpath > rightpath) then
		RightMovement = -1
    else
		RightMovement = 1
    end
end

--fix stupid circle shit later
sad.m_pi = 3.14159265358979323846264338327950288
function sad.DoCStrafe(cmd)
	local Velocity = LocalPlayer():GetVelocity();
	Velocity.z = 0;
	local Speed = Velocity:Length();
	if (Speed < 45)  then Speed = 45; end

    local FinalPath = sad.GetTraceFraction(LocalPlayer():GetPos() + Vector(0, 0, 10), (LocalPlayer():GetPos() + Vector(0, 0, 10)) + Velocity / 3)
    local DeltaAngle = RightMovement * math.max((275 / Speed) * ( 2 / FinalPath) * (128 / (1.7 / engine.TickInterval())) * 4.2, 2);
	StrafeAngle = StrafeAngle + DeltaAngle
    print(FinalPath, DeltaAngle, StrafeAngle )

	if (math.abs(StrafeAngle) >= 360) then
		StrafeAngle = 0;
		IsActive = false;
		RightMovement = 0;
	else
		cmd:SetForwardMove(math.cos((StrafeAngle + 90 * RightMovement) * (sad.m_pi / 180)) * LocalPlayer():GetMaxSpeed());
		cmd:SetSideMove(math.sin((StrafeAngle + 90 * RightMovement) * (sad.m_pi / 180)) * LocalPlayer():GetMaxSpeed());
    end
end

function sad.CanStrafe(ply)
    if ply:GetMoveType() == MOVETYPE_NOCLIP then return false; end
    return (ply:WaterLevel() < 2 and ply:GetMoveType() ~= 8 and ply:GetMoveType() ~= 9 and ply:GetMoveType() ~= 10)
end

function sad.bhop(cmd)
    if options.main_bhop == false then
        return
    end
    if (LocalPlayer():OnGround() and cmd:KeyDown(IN_JUMP)) then
        cmd:SetButtons(bit.bor(cmd:GetButtons(), IN_JUMP))
    else
        cmd:RemoveKey(IN_JUMP)
    end
    local canStrafe = sad.CanStrafe(LocalPlayer())
    if canStrafe and options.main_bhop_strafe and LocalPlayer():OnGround() ~= true then
        if IsActive ~= true then
            cmd:SetForwardMove(5850 / LocalPlayer():GetVelocity():Length2D())
            cmd:SetSideMove((cmd:CommandNumber() % 2 == 0) and 450 or -450)
        end
    end
end

sad.blink_swap = false
sad.fucking_delay = CurTime()
sad.jitter_delay = CurTime()
function sad.LagExploit(cmd)
    if options.main_lag_exploit ~= true then
        return
    end
    local net = sad.get_netchan()
    if net then
        nSequenceNrOut = net:GetOutSeq()
        if cmd:KeyDown(IN_WALK) then --airstuck
            if CurTime() - sad.jitter_delay > 0.0001 then
                bSendPacket = false
                net:SetOutSeq(nSequenceNrOut + 120)
                sad.jitter_delay = CurTime()
            else
                bSendPacket = true
            end
        end
        if cmd:KeyDown(IN_SPEED) then
            if CurTime() - sad.jitter_delay > 0.05 then
                bSendPacket = false
                net:SetOutSeq(nSequenceNrOut + 2)
                sad.jitter_delay = CurTime()
            else
                bSendPacket = true
            end
        end
        if cmd:KeyDown(IN_ATTACK) then
            local w = LocalPlayer():GetActiveWeapon()
            local nullCheck = tostring(w) == "[NULL Entity]"
            if w ~= nil and nullCheck == false then
                if w:GetClass() == "blink_swep" then
                    net:SetOutSeq(nSequenceNrOut + 7)
                end
            end
        end
    end
end

DAFKCoolDown = 0
tabStatus = false
function sad.TabbedOut()
    local me = LocalPlayer()
    if options.main_tabbed_out and me.IsTabbedOut then
        if CurTime() - DAFKCoolDown <= 30 then
            if LocalPlayer():IsTabbedOut() ~= true then
                tabStatus = true
                net.Start("DAFK.HasFocus")
                net.WriteBool(false)
                net.SendToServer()
            end
        else
            if LocalPlayer():IsTabbedOut() then
                tabStatus = false
                net.Start("DAFK.HasFocus")
                net.WriteBool(true)
                net.SendToServer()
            end
            DAFKCoolDown = CurTime()
        end
    else
        if tabStatus == true then
            tabStatus = false
            net.Start("DAFK.HasFocus")
            net.WriteBool(true)
            net.SendToServer()
        end
    end
end

local fakelag_inc = 0
function sad.Fakelag(cmd)
    local wep = LocalPlayer():GetActiveWeapon()
    local nullCheck = tostring(wep) == "[NULL Entity]"
    if nullCheck then bSendPacket = true; return; end
    local shooting = isfiring or cmd:KeyDown(IN_ATTACK)
    if shooting and wep:GetNextPrimaryFire() < servertime then bSendPacket = true; return; end
    if options.main_fakelag then
        bSendPacket = cmd:CommandNumber() % math.Round(options.main_fakelag_factor) == 0
    elseif (options.main_fakelag ~= true and bSendPacket == false) then
        bSendPacket = true
    end
end

function sad.getNearestEnt() --fuck it lol i'm to lazy to fix spacing rn
        local best_dist = 999999
            for k, v in pairs(player.GetAll()) do
            if v:Team() ~= LocalPlayer():Team() then
            if v ~= nil then
            if v:IsDormant() ~= true then
            if v ~= LocalPlayer() then
            if v:Alive() then
                local _checkdist = v:GetPos():Distance(LocalPlayer():GetPos())
                if _checkdist < best_dist then
                    best_dist = _checkdist
                    return v; 
                end
            end
        end
        end
    end
end
end
end

local ending_angle = Angle()
local swap_ang = false
local packet2 = false
function sad.switch_swap()
    if swap_ang == true then
        swap_ang = false
    else
        swap_ang = true
    end
end
function sad.switch_packet()
    if packet2 == true then
        packet2 = false
    else
        packet2 = true
    end
end

sad.antiaimvreal = Angle()
sad.antiaimvfake = Angle()
sad.spin = 0
function sad.antiaim(cmd)
    local aa = sad.clientview
    local wep = LocalPlayer():GetActiveWeapon()
    local nullCheck = tostring(w) == "[NULL Entity]"
    if nullCheck then return; end
    local shooting = isfiring
    if LocalPlayer():Alive() ~= true then return; end
    if wep.GetNextPrimaryFire == nil then return; end
    if shooting and wep:GetNextPrimaryFire() <= servertime or cmd:KeyDown(IN_ATTACK) then ending_angle = aa; return; end
    local aa = Angle()
    local followAngle
    if sad.getNearestEnt() then
        followAngle = (sad.getNearestEnt():GetPos() - LocalPlayer():GetPos()):Angle()
    else
        followAngle = sad.clientview
    end
    aa.y = 180 + followAngle.y 
    if options.main_lag_exploit ~= true then --if lag exploit isn't on we can choke and fake angles the easy way
        aa.x = 89
        --sad.spin = sad.spin + (2 * (cmd:CommandNumber() % 4));
        if bSendPacket then
            aa.y = aa.y + 35
            aa.y = math.NormalizeAngle(aa.y)
            sad.antiaimvfake = aa
            --sad.antiaimvreal = aa
        else
            aa.y = aa.y - 35
            aa.y = math.NormalizeAngle(aa.y)
            sad.antiaimvreal = aa
            --sad.antiaimvfake = aa
        end
    else --bastard wants to abuse lag exploit, choking may cause freezing and forced retries!
        aa.x = 989
        aa.y = aa.y + (swap_ang and 90 or 95)
        aa.y = math.NormalizeAngle(aa.y)
        sad.antiaimvreal = aa
        sad.antiaimvfake = aa
    end
    aa.z = 0
    if bSendPacket ~= false then
        ending_angle = aa
    else
        ending_angle = ending_angle
    end
    --sad.NormalizeAngleNoClamp(aa)
    --print(aa)
    sad.fakex = math.Clamp(math.NormalizeAngle(aa.x), -89, 89)
    cmd:SetViewAngles(aa)
    sad.viewangles = cmd:GetViewAngles()
    --print(cmd:GetViewAngles())
    sad.switch_swap()
    --sad.FixMove(cmd)
end

function sad.doaashowlol(ply, ang)
    pitch = ang.x
    yaw = ang.y
    ply:SetPoseParameter("head_pitch", pitch)
    ply:SetPoseParameter("aim_pitch", pitch)
    ply:SetPoseParameter("aim_yaw", 0)
    ply:SetRenderAngles(Angle(0, yaw, 0))
    ply:InvalidateBoneCache()
end

sad.yaw_aaa_mode = false
function sad.switch_yaaa_mode()
    if sad.yaw_aaa_mode == true then
        sad.yaw_aaa_mode = false
    else
        sad.yaw_aaa_mode = true
    end
end
function sad.doAAA(ply, ang)
    if ply == LocalPlayer() then return; end
    if sad.shots_fired[LocalPlayer():EntIndex()] == nil then sad.shots_fired[LocalPlayer():EntIndex()] = 0; end
    local ply_shots = sad.shots_fired[LocalPlayer():EntIndex()]
    if ply_shots == 0 then
        sad.switch_yaaa_mode()
        sad.shots_fired[LocalPlayer():EntIndex()] = 1
    end
    --print(ply_shots)
    if sad.shots_fired_aaa == nil then sad.shots_fired_aaa = 0; end
    sad.shots_fired_aaa = tonumber(ply_shots)
    local new_ang_y = math.NormalizeAngle(ang.y)
    if sad.yaw_aaa_mode then
        new_ang_y = new_ang_y + 180
    end
    local new_ang_x = math.Clamp(math.NormalizeAngle(ply_shots * 60), -90, 90)
    sad.pitch_aaa_mode = new_ang_x
    new_ang_x = math.Clamp(new_ang_x, -89, 89)
    pitch = new_ang_x
    yaw = new_ang_y
    ang = sad.NormalizeAngle(ang)
    ply:SetPoseParameter("head_pitch", pitch)
    ply:SetPoseParameter("aim_pitch", pitch)
    ply:SetPoseParameter("aim_yaw", 0)
    ply:SetRenderAngles(Angle(0, yaw, 0))
    ply:InvalidateBoneCache()
end

sad.fakeangleold_removed = false
function sad.RenderAAA()
    if options.main_anti_aim and options.visuals_thirdperson then
        sad.doaashowlol(LocalPlayer(), sad.antiaimvreal)
        if(sad.fakeangle == nil) then --was gonna do something like this but i'm lazy so I just pasted it, i'll make something different later
            if sad.fakeangleold_removed ~= true and fakeangle_old then
                print(sad.fakeangleold_removed, fakeangle_old)
                fakeangle_old:Remove()
                sad.fakeangleold_removed = true
            end
            sad.fakeangle = ClientsideModel(LocalPlayer():GetModel(), 1)
            fakeangle_old = sad.fakeangle
        end
        if sad.fakex and sad.antiaimvfake then
            sad.fakeangle:SetNoDraw(false)
            sad.fakeangle:SetSequence(LocalPlayer():GetSequence())
            sad.fakeangle:SetCycle(LocalPlayer():GetCycle())

            sad.fakeangle:SetModel(LocalPlayer():GetModel())
            local oldpos = LocalPlayer().packet_pos or LocalPlayer():GetPos()
            sad.fakeangle:SetPos(Vector(oldpos.x, oldpos.y, oldpos.z))
    
            --sad.fakeangle:SetAngles(Angle(sad.fakex, sad.antiaimvfake.y, 0))
            sad.fakeangle:SetPoseParameter("head_pitch", sad.fakex)
            sad.fakeangle:SetPoseParameter("aim_pitch",  sad.fakex)
            sad.fakeangle:SetPoseParameter("move_x", LocalPlayer():GetPoseParameter("move_x"))
            sad.fakeangle:SetPoseParameter("move_y", LocalPlayer():GetPoseParameter("move_y"))
            sad.fakeangle:SetPoseParameter("body_yaw", sad.antiaimvfake.y)
            sad.fakeangle:SetPoseParameter("aim_yaw", 0)
    
            sad.fakeangle:InvalidateBoneCache()
            sad.fakeangle:SetRenderAngles(Angle(0, sad.antiaimvfake.y, 0))
        end
    else
        if sad.fakeangle then
            sad.fakeangle:Remove()
            sad.fakeangle = nil
        end
    end
    if options.main_anti_anti_aim then
        for k, v in pairs(player.GetAll()) do
            if v:Team() ~= LocalPlayer():Team() then
                sad.doAAA(v, v:EyeAngles())
            end
        end
    end
end
sad.AddHook("RenderScene", "aaa", sad.RenderAAA)

sad.chamtexture1 = CreateMaterial( "a", "VertexLitGeneric", {
	["$ignorez"] = 0,
	["$model"] = 1,
	["$basetexture"] = "models/debug/debugwhite",
} )

function sad.DrawModel(v, texture)
    cam.Start3D()
        if(v:IsValid()) then
            render.MaterialOverride(texture)
            render.SetColorModulation(0.8, 0.8, 0.8, 0.8)
            v:DrawModel()
        end
    cam.End3D()
end

sad.AddHook("RenderScreenspaceEffects", function()
    if options.main_anti_aim and options.visuals_thirdperson then
        sad.DrawModel(sad.fakeangle, sad.chamtexture1)
    end
end)

sad.clientview = Angle()
function sad.CreateMove(cmd)
    sad.Fakelag(cmd)
    if sad.clientview == nil then sad.clientview = cmd:GetViewAngles(); end
    sad.clientview = sad.clientview + Angle(cmd:GetMouseY() * 0.023, cmd:GetMouseX() * -0.023, 0);
    if bSendPacket == false then
        LocalPlayer().choked = true
        if LocalPlayer().choked_ticks == nil then LocalPlayer().choked_ticks = 0; end
        LocalPlayer().choked_ticks = LocalPlayer().choked_ticks + 1
    else
        LocalPlayer().choked = false
        if LocalPlayer().choked_ticks == nil then LocalPlayer().choked_ticks = 0; end
        LocalPlayer().choked_ticks = 0
    end
    sad.NormalizeAngle(sad.clientview)
    sad.bhop(cmd)
    if options.main_fakelag ~= true and options.main_anti_aim then
        bSendPacket = cmd:CommandNumber() % 3 == 0 -- quick fix for shitty modulo
    end
    sad.LagExploit(cmd)
    if sad.input.ButtonPressed(KEY_END) then
        if sad.UnLoad then
            timer.Simple(
                0.2,
                function()
                    sad.UnLoad()
                end
            )
        end
    end
    sad.TabbedOut()
    sad.menu_think()
    if options.main_low_lerp then
        local i_check = math.Round(GetConVarNumber("cl_interp"), 3) > 0.01
        local cmd_check = math.Round(GetConVarNumber("cl_cmdrate"), 0) < GetConVarNumber("sv_maxcmdrate")
        local up_check =  math.Round(GetConVarNumber("cl_updaterate"), 0) < 2500000
        if i_check then
            RunConsoleCommand("cl_interp", "0.01")
        end
        if up_check then
             RunConsoleCommand("cl_updaterate", "2500000")
        end
        if cmd_check then
            RunConsoleCommand("cl_cmdrate", GetConVarNumber("sv_maxcmdrate"))
        end
    end
    if cmd:CommandNumber() > 0 then
        if options.main_anti_aim then
            sad.antiaim(cmd)
            if bSendPacket then
                LocalPlayer().packet_pos = LocalPlayer():GetPos()
            end
        else
            sad.viewangles = cmd:GetViewAngles()
        end
        sad.aimbot(cmd)
        if options.main_anti_aim or options.main_aimbot_silent then
             sad.FixMove(cmd)
        end
    else
        if options.main_aimbot_silent then
            cmd:SetViewAngles(sad.clientview)
        else
            sad.clientview = cmd:GetViewAngles()
        end
    end
end
sad.AddHook("CreateMove", "sad_create_move", sad.CreateMove)
--Createmove end

--calcview

sad.AddHook(
    "ShouldDrawLocalPlayer",
    "check_tp",
    function(ply)
        if options.visuals_thirdperson then
            return true
        end
    end
)

function sad.CalcView(ply, pos, angles, fov)
    if options.visuals_fov_toggle then
        local view = {}
        view.fov = options.visuals_fov
        if options.visuals_thirdperson then
            view.origin = pos - (angles:Forward() * 100)
        end
        return view
    else
        if options.visuals_thirdperson then
            local view = {}
            view.origin = pos - (angles:Forward() * 100)
            return view
        end
    end
    return
end
sad.AddHook("CalcView", "CalcView", sad.CalcView)

--calcview end

function sad.CustomDisconnect(reason)
    local netchan = CNetChan()
    local buf = netchan:GetReliableBuffer()

    buf:WriteUInt(net_Disconnect, NET_MESSAGE_BITS)
    buf:WriteString(reason)

    netchan:Transmit()
end

local stop_disconnect = false
concommand.Add(
    "disconnect_ponyscape",
    function(blah, blah, args)
        stop_disconnect = false
        local reason = tostring(table.concat(args, " "))
        reason = "You have been banned from this server (" .. reason .. "), please visitbans.ponyscape.com"
        print("[Sad-Bot] (In 8 seconds) Disconnecting you for the reason: " .. tostring(reason))
        print("[Sad-Bot] You can cancel with disconnect_cancel")
        timer.Simple(
            8,
            function()
                if stop_disconnect == false then
                    print("[Sad-Bot] bye retard")
                    sad.CustomDisconnect(reason)
                else
                    print("[Sad-Bot] disconnect cancelled")
                end
            end
        )
    end
)

concommand.Add(
    "disconnect_custom",
    function(blah, blah, args)
        stop_disconnect = false
        local reason = tostring(table.concat(args, " "))
        print("[Sad-Bot] (In 8 seconds) Disconnecting you for the reason: " .. tostring(reason))
        print("[Sad-Bot] You can cancel with disconnect_cancel")
        timer.Simple(
            8,
            function()
                if stop_disconnect == false then
                    print("[Sad-Bot] bye retard")
                    sad.CustomDisconnect(reason)
                else
                    print("[Sad-Bot] disconnect cancelled")
                end
            end
        )
    end
)

concommand.Add(
    "disconnect_cancel",
    function()
        stop_disconnect = true
    end
)

--End script
function sad.UnLoad()
    for a, b in pairs(sad.hooks) do
        sad.UnHook(b[1], b[2])
    end
    sad.destroy_menu_instance()
    sad = nil --Remove EVERYTHING in the sad table, so any functions you don't want staying around should start with sad
    spread = nil
    md5 = nil
    _R.Entity.FireBullets = of
    bSendPacket = true
    --ex function sad.test() instead of function test()
end
--sad.UnLoad()
--]]);


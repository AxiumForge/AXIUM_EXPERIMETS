Yes! 😄 Lad os lave et konkret **LÖVR 3D SDF-raymarch eksempel**, hvor to hårde “maskin”-overflader (bokse) er forbundet af en **organisk, blød SDF-bro** (capsule + smooth union).

Her får du et *kørbart* `main.lua` med:

* 3D SDF scene (to hard surface-bokse)
* En organisk “muskel/slange”-forbindelse imellem dem
* Raymarching i fragment shader
* Simpel lys + normals, så formen træder tydeligt frem

---

## `main.lua` – komplet LÖVR SDF-raymarch scene

Smid dette i en tom mappe som `main.lua` og kør `lovr .`:

```lua
local shader
local t = 0

local frag = [[
uniform vec2 u_resolution;
uniform float u_time;

// --------- SDF helpers ---------

float sdBox(vec3 p, vec3 b) {
  vec3 q = abs(p) - b;
  return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0);
}

float sdCapsule(vec3 p, vec3 a, vec3 b, float r) {
  vec3 pa = p - a;
  vec3 ba = b - a;
  float h = clamp(dot(pa, ba) / dot(ba, ba), 0.0, 1.0);
  return length(pa - ba * h) - r;
}

// Smooth union – “organisk” blød overgang
float opSmoothUnion(float d1, float d2, float k) {
  float h = clamp(0.5 + 0.5 * (d2 - d1) / k, 0.0, 1.0);
  return mix(d2, d1, h) - k * h * (1.0 - h);
}

// --------- Scene: 2 hard surfaces + organisk link ---------

float map(vec3 p) {
  // Lidt animation i Y for livet
  p.y += sin(u_time * 0.5) * 0.1;

  // To hårde bokse (hard surfaces)
  vec3 p1 = p - vec3(-0.9, 0.0, 0.0);
  vec3 p2 = p - vec3( 0.9, 0.0, 0.0);

  float box1 = sdBox(p1, vec3(0.5, 0.3, 0.4));
  float box2 = sdBox(p2, vec3(0.5, 0.3, 0.4));

  // Organisk link: capsule mellem “indvendige” sider af boksene
  vec3 a = vec3(-0.4, 0.0, 0.0);
  vec3 b = vec3( 0.4, 0.0, 0.0);
  float link = sdCapsule(p, a, b, 0.2);

  // Hard surfaces: ren min
  float hard = min(box1, box2);

  // Organisk blød fusion mellem hårdt og link
  float res = opSmoothUnion(hard, link, 0.25);

  return res;
}

// --------- Normal, lighting, raymarch ---------

vec3 calcNormal(vec3 p) {
  const vec2 e = vec2(1e-3, 0.0);
  float dx = map(p + vec3(e.x, e.y, e.y)) - map(p - vec3(e.x, e.y, e.y));
  float dy = map(p + vec3(e.y, e.x, e.y)) - map(p - vec3(e.y, e.x, e.y));
  float dz = map(p + vec3(e.y, e.y, e.x)) - map(p - vec3(e.y, e.y, e.x));
  return normalize(vec3(dx, dy, dz));
}

float raymarch(vec3 ro, vec3 rd, out vec3 p) {
  float t = 0.0;
  const float MAX_DIST = 20.0;
  const int MAX_STEPS = 128;
  const float EPS = 0.0005;

  for (int i = 0; i < MAX_STEPS; i++) {
    p = ro + rd * t;
    float d = map(p);
    if (d < EPS) {
      return t;
    }
    t += d;
    if (t > MAX_DIST) break;
  }
  return -1.0;
}

vec3 shade(vec3 p, vec3 rd) {
  vec3 n = calcNormal(p);

  // Lysretning
  vec3 lightDir = normalize(vec3(0.6, 0.8, -0.4));
  float diff = max(dot(n, lightDir), 0.0);

  // Rim light / edge highlight
  float rim = pow(1.0 - max(dot(n, -rd), 0.0), 2.0);

  // Farver: hårde bokse vs organisk link (heuristik på x-afstand)
  float linkMask = smoothstep(0.4, 0.0, abs(p.x)); // mest midt i mellem boksene
  vec3 hardColor = vec3(0.3, 0.35, 0.4);
  vec3 organicColor = vec3(0.8, 0.4, 0.2);
  vec3 baseColor = mix(hardColor, organicColor, linkMask);

  vec3 col = baseColor * (0.15 + 0.85 * diff);
  col += rim * vec3(0.6, 0.7, 1.0);

  // Simpel ambient
  col += vec3(0.05, 0.06, 0.07);

  return col;
}

// --------- Main fragment ---------

vec4 lovrMain() {
  // Normaliserede skærmkoords
  vec2 uv = (gl_FragCoord.xy / u_resolution.xy) * 2.0 - 1.0;
  uv.x *= u_resolution.x / u_resolution.y;

  // Kamera
  vec3 ro = vec3(0.0, 0.0, 4.0);
  vec3 rd = normalize(vec3(uv, -1.8));

  vec3 p;
  float tHit = raymarch(ro, rd, p);

  vec3 col;
  if (tHit > 0.0) {
    col = shade(p, rd);
  } else {
    // Baggrund
    float v = 0.15 + 0.1 * uv.y;
    col = vec3(v, v * 1.1, v * 1.3);
  }

  return vec4(col, 1.0);
}
]]

function lovr.load()
  shader = lovr.graphics.newShader(nil, frag)
end

function lovr.update(dt)
  t = t + dt
  shader:send('u_time', t)
  shader:send('u_resolution', { lovr.graphics.getWidth(), lovr.graphics.getHeight() })
end

function lovr.draw()
  lovr.graphics.setShader(shader)
  -- Stor plane, vi bruger kun gl_FragCoord i shaderen
  lovr.graphics.plane('fill', 0, 0, -1, 4, 4)
  lovr.graphics.setShader()
end
```

---

## Hvad du får visuelt

* To tydelige **hårde bokse** til venstre og højre (hard surface).
* Midt i mellem dem en **organisk, blød “muskel”/slange** (capsule) som er smeltet sammen med boksene via *smooth union* → ingen hård kant, men en glidende overgang.
* En simpel kant-lysning (rim light) fremhæver den organiske form.
* En lille vertikal “puls” i Y (`p.y += sin(u_time * 0.5) * 0.1`) gør forbindelsen lidt levende.

---

Hvis du vil, kan vi i næste trin:

* Splitte `map()` op i **named SDF-“dele** (HARD_LEFT, HARD_RIGHT, LINK_ORGANIC).
* Eller portere **den samme SDF-scene** til Heaps/HXSL, så du har 1:1 udseende i begge engines.

# Tier 4 — IMMERSIVO: Definizione Tecnica Completa

## Principio
Esperienza 3D interattiva. Canvas WebGL come elemento centrale. Richiede fallback obbligatorio per dispositivi non compatibili. Adatto a showcase di prodotto 3D, portfolio creativo estremo, esperienze interattive.

## Stack
- `three` — Three.js core
- `@react-three/fiber` (R3F) — React renderer per Three.js
- `@react-three/drei` — helpers e componenti pronti
- `@react-three/postprocessing` — effetti post-processo

**Installazione:**
```bash
npm install three @react-three/fiber @react-three/drei @react-three/postprocessing
npm install -D @types/three
```

## Feature Detection (OBBLIGATORIO)
```tsx
// lib/webgl-detect.ts
export function detectWebGL(): boolean {
  try {
    const canvas = document.createElement('canvas')
    const gl = canvas.getContext('webgl') || canvas.getContext('experimental-webgl')
    return !!(gl && gl instanceof WebGLRenderingContext)
  } catch {
    return false
  }
}

// Uso nel componente
export function Scene3D() {
  const [supportsWebGL, setSupportsWebGL] = useState(false)
  useEffect(() => { setSupportsWebGL(detectWebGL()) }, [])
  if (!supportsWebGL) return <Fallback2D />
  return <Canvas>...</Canvas>
}
```

## Fallback 2D (OBBLIGATORIO)
Il fallback 2D deve essere una versione equivalente del contenuto, non solo un messaggio di errore:
- Stesse informazioni presenti nella scena 3D
- Design coerente con il resto del sito (Tier 3 visual)
- Immagine/video statico come alternativa alla scena

## Setup R3F Base
```tsx
import { Canvas } from '@react-three/fiber'
import { OrbitControls, Environment, useGLTF } from '@react-three/drei'

export function Scene() {
  return (
    <Canvas
      camera={{ position: [0, 0, 5], fov: 45 }}
      gl={{ antialias: true, alpha: true }}
      dpr={[1, 2]} // pixel ratio limitato per performance
    >
      <ambientLight intensity={0.5} />
      <directionalLight position={[10, 10, 5]} intensity={1} />
      <Environment preset="city" />
      <Model />
      <OrbitControls enableZoom={false} />
    </Canvas>
  )
}
```

## Caricamento Modelli .glb
```tsx
function Model() {
  const { scene } = useGLTF('/models/product.glb')
  return <primitive object={scene} />
}
// Preload
useGLTF.preload('/models/product.glb')
```

## Performance Budget
- Target: **60fps** su hardware mid-range
- Max poligoni: **500.000** per scena
- Texture: max 2048x2048, preferire 1024x1024
- Ottimizzazioni obbligatorie:
  - **Draco compression**: `draco-loader` per modelli compressi
  - **Texture atlas**: combina texture multiple in una
  - **LOD** (Level of Detail): modelli a bassa risoluzione per distanza
  - **Lazy loading**: carica modelli solo quando visibili (Intersection Observer)
  - **Dispose**: rimuovi geometrie/materiali al unmount del componente

## Loading Screen 3D
```tsx
import { Html, useProgress } from '@react-three/drei'
function Loader() {
  const { progress } = useProgress()
  return (
    <Html center>
      <div className="loading-screen">
        <div className="progress-bar" style={{ width: `${progress}%` }} />
        <span>{progress.toFixed(0)}%</span>
      </div>
    </Html>
  )
}
// In Canvas:
<Suspense fallback={<Loader />}>
  <Model />
</Suspense>
```

## Post-Processing (opzionale)
```tsx
import { EffectComposer, Bloom, ChromaticAberration } from '@react-three/postprocessing'
<EffectComposer>
  <Bloom intensity={0.3} luminanceThreshold={0.9} />
  <ChromaticAberration offset={[0.001, 0.001]} />
</EffectComposer>
```

## Regole Assolute
- MAI usare tier 4 per gestionali, ERP, tool interni
- Fallback 2D obbligatorio — il sito deve funzionare senza WebGL
- Performance audit prima del deploy (usa Stats da drei per debug)
- Mobile: considera di ridurre qualità su `dpr` per mobile (`dpr={[1, 1.5]}`)
- Accessibility: tutta la scena 3D deve avere equivalente testuale (ARIA)

## PATTERN AVANZATI TIER 4

### GLSL Shader personalizzato con React Three Fiber
```typescript
// npm install @react-three/fiber @react-three/drei three
import { shaderMaterial } from '@react-three/drei'
import { extend, useFrame } from '@react-three/fiber'
import { useRef } from 'react'
import * as THREE from 'three'

const WaveMaterial = shaderMaterial(
  { uTime: 0, uColor: new THREE.Color(0.2, 0.5, 1.0) },
  // Vertex shader
  `
    varying vec2 vUv;
    uniform float uTime;
    void main() {
      vUv = uv;
      vec3 pos = position;
      pos.z += sin(pos.x * 3.0 + uTime) * 0.1;
      gl_Position = projectionMatrix * modelViewMatrix * vec4(pos, 1.0);
    }
  `,
  // Fragment shader
  `
    uniform vec3 uColor;
    uniform float uTime;
    varying vec2 vUv;
    void main() {
      float alpha = smoothstep(0.0, 1.0, vUv.y);
      gl_FragColor = vec4(uColor, alpha * 0.8);
    }
  `
)
extend({ WaveMaterial })

// Aggiunge il tipo TypeScript
declare module '@react-three/fiber' {
  interface ThreeElements {
    waveMaterial: { uTime?: number; uColor?: THREE.Color; transparent?: boolean }
  }
}

export function WaveMesh() {
  const matRef = useRef<any>(null)
  useFrame(({ clock }) => {
    if (matRef.current) matRef.current.uTime = clock.elapsedTime
  })
  return (
    <mesh>
      <planeGeometry args={[5, 5, 32, 32]} />
      <waveMaterial ref={matRef} transparent />
    </mesh>
  )
}
```

---

### React Spring + R3F — Animazioni fisiche 3D
```typescript
// npm install @react-spring/three
import { useSpring, animated } from '@react-spring/three'
import { useState } from 'react'

export function SpringBox() {
  const [active, setActive] = useState(false)

  const { scale, rotation } = useSpring({
    scale: active ? 1.5 : 1,
    rotation: active ? [0, Math.PI, 0] as [number, number, number] : [0, 0, 0] as [number, number, number],
    config: { mass: 2, tension: 200, friction: 25 }, // fisico: massa, molla, smorzamento
  })

  return (
    <animated.mesh
      scale={scale}
      rotation={rotation}
      onClick={() => setActive(!active)}
    >
      <boxGeometry />
      <meshStandardMaterial color={active ? '#ff6030' : '#2050ff'} />
    </animated.mesh>
  )
}
```

---

### Video Texture su Mesh Three.js
```typescript
import { useEffect, useRef } from 'react'
import * as THREE from 'three'

export function VideoMesh({ src }: { src: string }) {
  const videoRef = useRef<HTMLVideoElement | null>(null)
  const textureRef = useRef<THREE.VideoTexture | null>(null)

  useEffect(() => {
    const video = document.createElement('video')
    video.src = src
    video.loop = true
    video.muted = true  // obbligatorio per autoplay
    video.playsInline = true
    video.play()
    videoRef.current = video

    const texture = new THREE.VideoTexture(video)
    texture.colorSpace = THREE.SRGBColorSpace
    textureRef.current = texture

    return () => { video.pause(); texture.dispose() }
  }, [src])

  return (
    <mesh>
      <planeGeometry args={[16/9, 1]} />
      <meshBasicMaterial map={textureRef.current ?? undefined} toneMapped={false} />
    </mesh>
  )
}
```

---

### Performance mobile con `prefers-reduced-motion` in R3F
```typescript
// Hook per reduce motion
import { useEffect, useState } from 'react'

export function usePrefersReducedMotion() {
  const [reduced, setReduced] = useState(false)
  useEffect(() => {
    const mq = window.matchMedia('(prefers-reduced-motion: reduce)')
    setReduced(mq.matches)
    const handler = (e: MediaQueryListEvent) => setReduced(e.matches)
    mq.addEventListener('change', handler)
    return () => mq.removeEventListener('change', handler)
  }, [])
  return reduced
}

// Nel componente Canvas:
export function Scene() {
  const reducedMotion = usePrefersReducedMotion()

  if (reducedMotion) {
    // Fallback 2D statico per accessibilità
    return <StaticHeroImage />
  }

  return (
    <Canvas
      dpr={Math.min(window.devicePixelRatio, 1.5)} // limita DPR su mobile
      performance={{ min: 0.5 }}  // abbassa qualità sotto 30fps
    >
      <AnimatedScene />
    </Canvas>
  )
}
```
**Regole performance mobile Tier 4:**
- DPR: non superare 1.5 su dispositivi mobili
- Geometrie: massimo 50k vertices per oggetto su mobile
- Texture: usare `.ktx2` compresso invece di PNG per mobile
- Draw calls: monitorare con `r3f-perf` in dev (`npm install r3f-perf`)
- Shadow: disabilitare su mobile, usare fake shadow (plane con material trasparente)

# Visual Identity

Current target: vivid 2D cartoon tank-survivor visuals with bold black outlines, saturated colors, readable silhouettes, and responsive juice. The game still uses Godot's default font by design.

## Style Rules

- Use chunky black outlines for gameplay objects.
- Prefer saturated, varied colors with warm highlights and cool shadows.
- Keep enemy and boss sprites tintable so the data-driven variant catalog can reuse the same scenes.
- Keep effects readable at bullet-heaven density: short flashes, clear rings, small particles, and fast fadeouts.
- Do not add sound in this pass.

## Integrated Asset Families

| Area | Assets |
|---|---|
| World | `assets/backgrounds/wasteland_arena_generated.png`, cloud shadow textures |
| Menu | `assets/backgrounds/menu_backdrop_generated.png`, `assets/visual/ui/chunky_panel.png` |
| Player | `assets/visual/player/tank_base_cartoon.png`, `assets/visual/player/tank_cannon_cartoon.png`, `assets/visual/effects/radial_player_light.png` |
| Enemies | `assets/visual/enemies/enemy_scout_cartoon.png`, `enemy_bruiser_cartoon.png`, `enemy_shield_cartoon.png` |
| Bosses | `assets/visual/enemies/boss_core_cartoon.png` |
| Pickups | EXP crystals, dynamite, magnet, supply boxes, wrench |
| Projectiles | Tank shell and soldier projectile sprites |
| Ability Items | Landmine, circular saw, footsoldier sprites |

## Juice Hooks

- Projectile trails draw behind each tank shot.
- Enemy and boss hits trigger white flashes, scale pops, and short particle chips.
- Enemy deaths and boss deaths spawn layered outlined bursts.
- Splash explosions draw filled flash, black shock outline, orange ring, yellow inner ring, and smoke spokes.
- Player damage triggers red screen modulation and red particles.
- Boss defeats trigger a warmer screen flash.
- EXP pickup feedback uses brighter outlined particles on the HUD.

## Regeneration

The asset generator is `tools/generate_visual_identity_assets.ps1`. It takes the generated source background path and rebuilds the project-local PNG assets.

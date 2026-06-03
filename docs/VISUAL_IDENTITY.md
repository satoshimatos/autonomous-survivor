# Visual Identity

Current target: clean semi-real cartoon tank-survivor visuals with readable silhouettes, beveled metal shading, controlled black outlines, saturated accents, and responsive juice. The game still uses Godot's default font by design.

## Style Rules

- Use controlled dark outlines for gameplay objects, avoiding rough sketch strokes.
- Prefer saturated, varied colors with metallic highlights, cool shadows, and semi-real bevels.
- Keep icons as clean object-symbol cards with consistent lighting instead of doodled symbols.
- Keep backgrounds readable and low-noise so bullets, enemies, pickups, and UI remain clear.
- Keep enemy and boss sprites tintable so the data-driven variant catalog can reuse the same scenes.
- Keep effects readable at bullet-heaven density: short flashes, clear rings, small particles, and fast fadeouts.
- Do not add sound in this pass.

## Integrated Asset Families

| Area | Assets |
|---|---|
| Branding | `assets/ui/branding/app_icon_1024.png`, `app_icon_256.png`, `logo_autonomous_survivor.png`, `wordmark_autonomous_survivor.png` |
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

## Branding

The game name is `Autonomous Survivor`. The project icon, boot splash, and main menu use the generated branding set in `assets/ui/branding/`. The visual mark combines a shield, tank silhouette, cyan/yellow energy accents, and the `AS` monogram so the icon remains readable at launcher size.

## Regeneration

The current semi-real cartoon asset generator is `tools/generate_semireal_assets.ps1`. It rebuilds the project-local PNG assets in place while preserving existing filenames and dimensions.

The branding generator is `tools/generate_branding_assets.ps1`. It creates the app icon, compact icon, full logo, and wordmark with deterministic vector-like drawing through `System.Drawing`.

The older cartoon pass generator, if present, should be treated as historical reference only; new visual refreshes should extend the semi-real generator unless a future art direction replaces it.

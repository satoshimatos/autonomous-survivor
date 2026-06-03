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
| Branding | `assets/ui/branding/app_icon_1024.png`, `app_icon_512.png`, `app_icon_256.png`, `app_icon_128.png`, `app_icon_64.png`, `app_icon_32.png`, `app_icon.ico`, `brand_mark_autonomous_survivor.png`, `logo_autonomous_survivor.png`, `wordmark_autonomous_survivor.png`, `icon_menu_play.png`, `icon_menu_compendium.png`, `icon_menu_quit.png` |
| World | `assets/backgrounds/wasteland_arena_generated.png`, cloud shadow textures |
| Menu | `assets/backgrounds/menu_backdrop_generated.png`, `assets/visual/ui/chunky_panel.png` |
| Player | `assets/visual/player/tank_base_cartoon.png`, `assets/visual/player/tank_cannon_cartoon.png`, `assets/visual/effects/radial_player_light.png` |
| Enemies | `assets/visual/enemies/enemy_scout_cartoon.png`, `enemy_bruiser_cartoon.png`, `enemy_shield_cartoon.png` |
| Bosses | `assets/visual/enemies/boss_core_cartoon.png` |
| Clockwork Spiral | `assets/backgrounds/map12_clockwork_spiral.png`, `assets/visual/enemies/map12/*.png` |
| Quantum Reef | `assets/backgrounds/map13_quantum_reef.png`, `assets/visual/enemies/map13/*.png` |
| Solar Bastion | `assets/backgrounds/map14_solar_bastion.png`, `assets/visual/enemies/map14/*.png` |
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

The game name is `Autonomous Survivor`. The project icon, native Windows icon, boot splash, main menu logo, and main menu action icons use the generated branding set in `assets/ui/branding/`. The visual mark combines a shield, tank silhouette, cyan/yellow energy accents, a compact `AS` badge, and a square launcher-safe silhouette so it remains readable at desktop and small taskbar sizes. `brand_mark_autonomous_survivor.png` is the compact reusable mark for smaller UI placements, while `icon_menu_play.png`, `icon_menu_compendium.png`, and `icon_menu_quit.png` keep primary menu actions visually branded. The old default Godot `icon.svg` assets are intentionally removed so the project only exposes Autonomous Survivor branding.

## Regeneration

The current semi-real cartoon asset generator is `tools/generate_semireal_assets.ps1`. It rebuilds the project-local PNG assets in place while preserving existing filenames and dimensions.

The branding generator is `tools/generate_branding_assets.ps1`. It creates the PNG app icons at 1024, 512, 256, 128, 64, and 32 pixels, compact brand mark, full logo, wordmark, menu action icons, and multi-size Windows `.ico` with deterministic vector-like drawing through `System.Drawing`.

The Clockwork Spiral generator is `tools/generate_map12_assets.ps1`. It creates the map 12 machine background and dedicated clockwork enemy/boss sprites under `assets/visual/enemies/map12/`.

The Quantum Reef generator is `tools/generate_map13_assets.ps1`. It creates the map 13 prism-current background and dedicated reef enemy/boss sprites under `assets/visual/enemies/map13/`.

The Solar Bastion generator is `tools/generate_map14_assets.ps1`. It creates the map 14 sun-forged background and dedicated solar enemy/boss sprites under `assets/visual/enemies/map14/`.

The older cartoon pass generator, if present, should be treated as historical reference only; new visual refreshes should extend the semi-real generator unless a future art direction replaces it.

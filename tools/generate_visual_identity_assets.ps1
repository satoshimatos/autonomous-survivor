param(
    [string]$SourceBackground = ""
)

Add-Type -AssemblyName System.Drawing

$root = Split-Path -Parent (Split-Path -Parent $MyInvocation.MyCommand.Path)

function Ensure-Dir($path) {
    if (-not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path | Out-Null
    }
}

function New-Bitmap($width, $height) {
    return New-Object System.Drawing.Bitmap($width, $height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
}

function Save-Png($bitmap, $relativePath) {
    $path = Join-Path $root $relativePath
    Ensure-Dir (Split-Path -Parent $path)
    $bitmap.Save($path, [System.Drawing.Imaging.ImageFormat]::Png)
    $bitmap.Dispose()
}

function New-Graphics($bitmap) {
    $g = [System.Drawing.Graphics]::FromImage($bitmap)
    $g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $g.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
    $g.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
    $g.Clear([System.Drawing.Color]::Transparent)
    return $g
}

function Color-Html($hex) {
    return [System.Drawing.ColorTranslator]::FromHtml($hex)
}

function Color-Argb($a, $hex) {
    $c = Color-Html $hex
    return [System.Drawing.Color]::FromArgb($a, $c.R, $c.G, $c.B)
}

function Brush($hex) {
    return New-Object System.Drawing.SolidBrush((Color-Html $hex))
}

function BrushA($a, $hex) {
    return New-Object System.Drawing.SolidBrush((Color-Argb $a $hex))
}

function PenC($hex, $width) {
    $p = New-Object System.Drawing.Pen((Color-Html $hex), $width)
    $p.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
    $p.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $p.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
    return $p
}

function Draw-RoundRect($g, $rect, $radius, $fill, $stroke, $strokeWidth) {
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $d = $radius * 2
    $path.AddArc($rect.X, $rect.Y, $d, $d, 180, 90)
    $path.AddArc($rect.Right - $d, $rect.Y, $d, $d, 270, 90)
    $path.AddArc($rect.Right - $d, $rect.Bottom - $d, $d, $d, 0, 90)
    $path.AddArc($rect.X, $rect.Bottom - $d, $d, $d, 90, 90)
    $path.CloseFigure()
    if ($fill -ne $null) { $g.FillPath($fill, $path) }
    if ($stroke -ne $null) { $g.DrawPath($stroke, $path) }
    $path.Dispose()
}

function Draw-Polygon($g, [System.Drawing.PointF[]]$points, $fill, $stroke, $strokeWidth) {
    if ($fill -ne $null) { $g.FillPolygon($fill, $points) }
    if ($stroke -ne $null) { $g.DrawPolygon($stroke, $points) }
}

function Draw-Line($g, $x1, $y1, $x2, $y2, $hex, $width) {
    $p = PenC $hex $width
    $g.DrawLine($p, $x1, $y1, $x2, $y2)
    $p.Dispose()
}

function Draw-TankBase {
    $bmp = New-Bitmap 128 128
    $g = New-Graphics $bmp
    Draw-RoundRect $g ([System.Drawing.RectangleF]::new(16, 22, 26, 84)) 10 (Brush "#202a35") (PenC "#050608" 6) 6
    Draw-RoundRect $g ([System.Drawing.RectangleF]::new(86, 22, 26, 84)) 10 (Brush "#202a35") (PenC "#050608" 6) 6
    for ($i = 0; $i -lt 7; $i++) {
        $y = 27 + $i * 11
        Draw-RoundRect $g ([System.Drawing.RectangleF]::new(17, $y, 24, 8)) 3 (Brush "#536472") (PenC "#111820" 2) 2
        Draw-RoundRect $g ([System.Drawing.RectangleF]::new(87, $y, 24, 8)) 3 (Brush "#536472") (PenC "#111820" 2) 2
    }
    Draw-RoundRect $g ([System.Drawing.RectangleF]::new(35, 18, 58, 92)) 12 (Brush "#8fe15b") (PenC "#050608" 7) 7
    Draw-RoundRect $g ([System.Drawing.RectangleF]::new(44, 29, 40, 18)) 5 (Brush "#d5ff71") (PenC "#263712" 3) 3
    Draw-RoundRect $g ([System.Drawing.RectangleF]::new(43, 58, 42, 28)) 5 (Brush "#6aaa40") (PenC "#263712" 3) 3
    Draw-Line $g 50 65 78 65 "#17210d" 4
    Draw-Line $g 50 73 78 73 "#17210d" 4
    foreach ($p in @(@(43,52),@(85,52),@(43,96),@(85,96))) {
        $g.FillEllipse((Brush "#f5ff8b"), $p[0]-4, $p[1]-4, 8, 8)
        $g.DrawEllipse((PenC "#050608" 3), $p[0]-4, $p[1]-4, 8, 8)
    }
    $g.FillRectangle((BrushA 42 "#ffffff"), 45, 21, 26, 84)
    $g.Dispose()
    Save-Png $bmp "assets/visual/player/tank_base_cartoon.png"
}

function Draw-TankCannon {
    $bmp = New-Bitmap 128 160
    $g = New-Graphics $bmp
    Draw-RoundRect $g ([System.Drawing.RectangleF]::new(38, 60, 52, 58)) 14 (Brush "#89d950") (PenC "#050608" 7) 7
    $g.FillEllipse((Brush "#6baa43"), 31, 70, 66, 62)
    $g.DrawEllipse((PenC "#050608" 6), 31, 70, 66, 62)
    Draw-RoundRect $g ([System.Drawing.RectangleF]::new(51, 13, 26, 78)) 8 (Brush "#93e05a") (PenC "#050608" 6) 6
    Draw-RoundRect $g ([System.Drawing.RectangleF]::new(48, 8, 32, 14)) 6 (Brush "#baf46b") (PenC "#050608" 5) 5
    Draw-RoundRect $g ([System.Drawing.RectangleF]::new(48, 82, 32, 36)) 9 (Brush "#528a35") (PenC "#050608" 5) 5
    Draw-Line $g 59 18 59 85 "#d8ff86" 3
    Draw-Line $g 70 18 70 85 "#3d6128" 3
    foreach ($p in @(@(43,86),@(85,86),@(43,122),@(85,122))) {
        $g.FillEllipse((Brush "#f5ff8b"), $p[0]-4, $p[1]-4, 8, 8)
        $g.DrawEllipse((PenC "#050608" 3), $p[0]-4, $p[1]-4, 8, 8)
    }
    $g.Dispose()
    Save-Png $bmp "assets/visual/player/tank_cannon_cartoon.png"
}

function Draw-Enemy($relativePath, $fill, $accent, $shape) {
    $bmp = New-Bitmap 96 96
    $g = New-Graphics $bmp
    if ($shape -eq "shield") {
        $points = [System.Drawing.PointF[]]@(
            [System.Drawing.PointF]::new(48, 10), [System.Drawing.PointF]::new(78, 24),
            [System.Drawing.PointF]::new(74, 64), [System.Drawing.PointF]::new(48, 84),
            [System.Drawing.PointF]::new(22, 64), [System.Drawing.PointF]::new(18, 24)
        )
        Draw-Polygon $g $points (Brush $fill) (PenC "#050608" 7) 7
        Draw-Polygon $g ([System.Drawing.PointF[]]@(
            [System.Drawing.PointF]::new(48, 22), [System.Drawing.PointF]::new(65, 31),
            [System.Drawing.PointF]::new(63, 59), [System.Drawing.PointF]::new(48, 70),
            [System.Drawing.PointF]::new(33, 59), [System.Drawing.PointF]::new(31, 31)
        )) (Brush $accent) (PenC "#192024" 3) 3
    } elseif ($shape -eq "bruiser") {
        Draw-RoundRect $g ([System.Drawing.RectangleF]::new(16, 18, 64, 58)) 18 (Brush $fill) (PenC "#050608" 8) 8
        Draw-RoundRect $g ([System.Drawing.RectangleF]::new(24, 56, 48, 26)) 8 (Brush $accent) (PenC "#050608" 5) 5
    } else {
        $points = [System.Drawing.PointF[]]@(
            [System.Drawing.PointF]::new(48, 9), [System.Drawing.PointF]::new(60, 27),
            [System.Drawing.PointF]::new(82, 28), [System.Drawing.PointF]::new(68, 47),
            [System.Drawing.PointF]::new(78, 70), [System.Drawing.PointF]::new(53, 63),
            [System.Drawing.PointF]::new(36, 85), [System.Drawing.PointF]::new(34, 58),
            [System.Drawing.PointF]::new(12, 50), [System.Drawing.PointF]::new(33, 38)
        )
        Draw-Polygon $g $points (Brush $fill) (PenC "#050608" 7) 7
    }
    $g.FillEllipse((Brush "#fff4a6"), 31, 35, 12, 15)
    $g.FillEllipse((Brush "#fff4a6"), 54, 35, 12, 15)
    $g.FillEllipse((Brush "#050608"), 35, 40, 5, 6)
    $g.FillEllipse((Brush "#050608"), 58, 40, 5, 6)
    Draw-Line $g 34 62 62 62 "#050608" 4
    $g.FillEllipse((BrushA 52 "#ffffff"), 25, 17, 29, 12)
    $g.Dispose()
    Save-Png $bmp $relativePath
}

function Draw-Boss {
    $bmp = New-Bitmap 192 192
    $g = New-Graphics $bmp
    $points = [System.Drawing.PointF[]]@(
        [System.Drawing.PointF]::new(96, 12), [System.Drawing.PointF]::new(137, 38),
        [System.Drawing.PointF]::new(172, 81), [System.Drawing.PointF]::new(158, 142),
        [System.Drawing.PointF]::new(96, 180), [System.Drawing.PointF]::new(34, 142),
        [System.Drawing.PointF]::new(20, 81), [System.Drawing.PointF]::new(55, 38)
    )
    Draw-Polygon $g $points (Brush "#f15a9b") (PenC "#050608" 11) 11
    $g.FillEllipse((Brush "#7b2be8"), 44, 42, 104, 104)
    $g.DrawEllipse((PenC "#050608" 8), 44, 42, 104, 104)
    $g.FillEllipse((Brush "#1cf5ff"), 67, 63, 58, 58)
    $g.DrawEllipse((PenC "#050608" 7), 67, 63, 58, 58)
    $g.FillEllipse((BrushA 110 "#ffffff"), 75, 65, 22, 15)
    for ($i = 0; $i -lt 8; $i++) {
        $angle = [Math]::PI * 2 * $i / 8
        $x1 = 96 + [Math]::Cos($angle) * 58
        $y1 = 96 + [Math]::Sin($angle) * 58
        $x2 = 96 + [Math]::Cos($angle) * 83
        $y2 = 96 + [Math]::Sin($angle) * 83
        Draw-Line $g $x1 $y1 $x2 $y2 "#050608" 5
    }
    $g.Dispose()
    Save-Png $bmp "assets/visual/enemies/boss_core_cartoon.png"
}

function Draw-Crystal($relativePath, $fill, $glow) {
    $bmp = New-Bitmap 64 64
    $g = New-Graphics $bmp
    $g.FillEllipse((BrushA 70 $glow), 4, 4, 56, 56)
    $points = [System.Drawing.PointF[]]@(
        [System.Drawing.PointF]::new(32, 5), [System.Drawing.PointF]::new(48, 25),
        [System.Drawing.PointF]::new(42, 54), [System.Drawing.PointF]::new(22, 54),
        [System.Drawing.PointF]::new(16, 25)
    )
    Draw-Polygon $g $points (Brush $fill) (PenC "#050608" 5) 5
    Draw-Line $g 32 8 32 52 "#ffffff" 3
    Draw-Line $g 19 25 45 25 "#ffffff" 2
    $g.Dispose()
    Save-Png $bmp $relativePath
}

function Draw-Pickups {
    Draw-Crystal "assets/exp/exp_crystal_green.png" "#65ff4f" "#65ff4f"
    Draw-Crystal "assets/exp/exp_crystal_blue.png" "#39c9ff" "#39c9ff"
    Draw-Crystal "assets/exp/exp_crystal_red.png" "#ff4d4d" "#ff4d4d"
    Draw-Crystal "assets/exp/exp_crystal_purple.png" "#c55cff" "#c55cff"

    $bmp = New-Bitmap 96 96; $g = New-Graphics $bmp
    Draw-RoundRect $g ([System.Drawing.RectangleF]::new(20, 16, 56, 64)) 10 (Brush "#ff4545") (PenC "#050608" 7) 7
    Draw-Line $g 34 22 34 74 "#ffd166" 5; Draw-Line $g 62 22 62 74 "#ffd166" 5
    Draw-Line $g 48 12 69 2 "#050608" 4; Draw-Line $g 68 2 76 8 "#ffe66d" 4
    $g.Dispose(); Save-Png $bmp "assets/pickups/dynamite_pickup_sprite.png"

    $bmp = New-Bitmap 96 96; $g = New-Graphics $bmp
    Draw-RoundRect $g ([System.Drawing.RectangleF]::new(18, 24, 24, 48)) 8 (Brush "#f54272") (PenC "#050608" 7) 7
    Draw-RoundRect $g ([System.Drawing.RectangleF]::new(54, 24, 24, 48)) 8 (Brush "#39c9ff") (PenC "#050608" 7) 7
    Draw-Line $g 30 24 66 24 "#f5f8ff" 7
    $g.Dispose(); Save-Png $bmp "assets/pickups/magnet_pickup_sprite.png"

    $bmp = New-Bitmap 96 96; $g = New-Graphics $bmp
    Draw-Line $g 25 65 58 32 "#d6dde4" 13; Draw-Line $g 25 65 58 32 "#050608" 18
    Draw-Line $g 25 65 58 32 "#d6dde4" 11
    $g.DrawArc((PenC "#050608" 8), 47, 13, 32, 32, 20, 265)
    $g.DrawArc((PenC "#d6dde4" 5), 47, 13, 32, 32, 20, 265)
    $g.Dispose(); Save-Png $bmp "assets/pickups/wrench.png"

    foreach ($entry in @(@("assets/pickups/supply_box_green.png","#66ff74"),@("assets/pickups/supply_box_blue.png","#3ec9ff"))) {
        $bmp = New-Bitmap 96 96; $g = New-Graphics $bmp
        Draw-RoundRect $g ([System.Drawing.RectangleF]::new(16, 20, 64, 56)) 9 (Brush $entry[1]) (PenC "#050608" 7) 7
        Draw-Line $g 16 45 80 45 "#050608" 5
        Draw-Line $g 48 20 48 76 "#050608" 5
        $g.FillEllipse((Brush "#fff4a6"), 39, 36, 18, 18)
        $g.Dispose(); Save-Png $bmp $entry[0]
    }
}

function Draw-ProjectilesAndAbilities {
    $bmp = New-Bitmap 64 96; $g = New-Graphics $bmp
    $points = [System.Drawing.PointF[]]@(
        [System.Drawing.PointF]::new(32, 5), [System.Drawing.PointF]::new(50, 44),
        [System.Drawing.PointF]::new(32, 90), [System.Drawing.PointF]::new(14, 44)
    )
    Draw-Polygon $g $points (Brush "#ffe042") (PenC "#050608" 6) 6
    Draw-Line $g 32 12 32 82 "#ffffff" 4
    $g.Dispose(); Save-Png $bmp "assets/projectiles/tank_projectile.png"

    $bmp = New-Bitmap 48 48; $g = New-Graphics $bmp
    $g.FillEllipse((Brush "#87f8ff"), 8, 8, 32, 32)
    $g.DrawEllipse((PenC "#050608" 5), 8, 8, 32, 32)
    $g.FillEllipse((Brush "#ffffff"), 16, 12, 13, 10)
    $g.Dispose(); Save-Png $bmp "assets/projectiles/soldier_projectile.png"

    $bmp = New-Bitmap 96 96; $g = New-Graphics $bmp
    $g.FillEllipse((Brush "#2b3542"), 22, 22, 52, 52)
    $g.DrawEllipse((PenC "#050608" 7), 22, 22, 52, 52)
    Draw-Line $g 48 18 48 78 "#ffd166" 5
    Draw-Line $g 18 48 78 48 "#ffd166" 5
    $g.Dispose(); Save-Png $bmp "assets/abilities/landmine.png"

    $bmp = New-Bitmap 96 96; $g = New-Graphics $bmp
    $g.FillEllipse((Brush "#dfe9f0"), 14, 14, 68, 68)
    $g.DrawEllipse((PenC "#050608" 7), 14, 14, 68, 68)
    for ($i = 0; $i -lt 8; $i++) {
        $a = [Math]::PI * 2 * $i / 8
        Draw-Line $g 48 48 (48 + [Math]::Cos($a) * 38) (48 + [Math]::Sin($a) * 38) "#050608" 4
    }
    $g.FillEllipse((Brush "#39c9ff"), 36, 36, 24, 24)
    $g.Dispose(); Save-Png $bmp "assets/abilities/circular_saw.png"

    $bmp = New-Bitmap 96 96; $g = New-Graphics $bmp
    Draw-RoundRect $g ([System.Drawing.RectangleF]::new(28, 20, 40, 50)) 11 (Brush "#ffb84d") (PenC "#050608" 7) 7
    Draw-Line $g 48 18 48 5 "#050608" 7
    Draw-Line $g 48 22 72 40 "#050608" 7
    $g.FillEllipse((Brush "#fff4a6"), 38, 32, 8, 10)
    $g.FillEllipse((Brush "#fff4a6"), 52, 32, 8, 10)
    $g.Dispose(); Save-Png $bmp "assets/abilities/footsoldier.png"
}

function Draw-CloudShadow($relativePath, $w, $h, $alpha) {
    $bmp = New-Bitmap $w $h
    $g = New-Graphics $bmp
    for ($i = 0; $i -lt 8; $i++) {
        $x = 20 + ($i * 59) % ($w - 80)
        $y = 18 + ($i * 37) % ($h - 70)
        $g.FillEllipse((BrushA $alpha "#181a24"), $x, $y, 110, 42)
    }
    $g.Dispose()
    Save-Png $bmp $relativePath
}

function Draw-Panel {
    $bmp = New-Bitmap 96 96
    $g = New-Graphics $bmp
    Draw-RoundRect $g ([System.Drawing.RectangleF]::new(6, 6, 84, 84)) 14 (Brush "#253348") (PenC "#050608" 8) 8
    Draw-RoundRect $g ([System.Drawing.RectangleF]::new(14, 14, 68, 68)) 9 (BrushA 85 "#8fe1ff") (PenC "#42566e" 2) 2
    $g.FillRectangle((BrushA 35 "#ffffff"), 18, 14, 48, 18)
    $g.Dispose()
    Save-Png $bmp "assets/visual/ui/chunky_panel.png"
}

function Draw-RadialLight {
    $bmp = New-Bitmap 256 256
    $g = New-Graphics $bmp
    $path = New-Object System.Drawing.Drawing2D.GraphicsPath
    $path.AddEllipse(4, 4, 248, 248)
    $brush = New-Object System.Drawing.Drawing2D.PathGradientBrush($path)
    $brush.CenterColor = [System.Drawing.Color]::FromArgb(210, 255, 234, 132)
    $brush.SurroundColors = @([System.Drawing.Color]::FromArgb(0, 255, 234, 132))
    $g.FillEllipse($brush, 4, 4, 248, 248)
    $brush.Dispose()
    $path.Dispose()
    $g.Dispose()
    Save-Png $bmp "assets/visual/effects/radial_player_light.png"

    $bmp = New-Bitmap 128 128
    $g = New-Graphics $bmp
    $points = [System.Drawing.PointF[]]@(
        [System.Drawing.PointF]::new(64, 6), [System.Drawing.PointF]::new(76, 44),
        [System.Drawing.PointF]::new(118, 64), [System.Drawing.PointF]::new(76, 82),
        [System.Drawing.PointF]::new(64, 122), [System.Drawing.PointF]::new(50, 82),
        [System.Drawing.PointF]::new(10, 64), [System.Drawing.PointF]::new(50, 44)
    )
    Draw-Polygon $g $points (Brush "#fff25a") (PenC "#050608" 8) 8
    $g.FillEllipse((BrushA 155 "#ff6b20"), 33, 33, 62, 62)
    $g.FillEllipse((BrushA 185 "#ffffff"), 48, 48, 32, 32)
    $g.Dispose()
    Save-Png $bmp "assets/visual/effects/impact_starburst.png"
}

function Copy-Backgrounds {
    if ($SourceBackground -eq "" -or -not (Test-Path $SourceBackground)) {
        return
    }
    Ensure-Dir (Join-Path $root "assets/backgrounds")
    $source = [System.Drawing.Image]::FromFile($SourceBackground)
    foreach ($entry in @(@("assets/backgrounds/wasteland_arena_generated.png",1408,808),@("assets/backgrounds/menu_backdrop_generated.png",1920,1080))) {
        $bmp = New-Bitmap $entry[1] $entry[2]
        $g = New-Graphics $bmp
        $scale = [Math]::Max($entry[1] / $source.Width, $entry[2] / $source.Height)
        $drawW = $source.Width * $scale
        $drawH = $source.Height * $scale
        $x = ($entry[1] - $drawW) / 2
        $y = ($entry[2] - $drawH) / 2
        $g.DrawImage($source, [System.Drawing.RectangleF]::new($x, $y, $drawW, $drawH))
        $g.Dispose()
        Save-Png $bmp $entry[0]
    }
    $source.Dispose()
}

Copy-Backgrounds
Draw-TankBase
Draw-TankCannon
Draw-Enemy "assets/visual/enemies/enemy_scout_cartoon.png" "#ffffff" "#f3f7ff" "scout"
Draw-Enemy "assets/visual/enemies/enemy_bruiser_cartoon.png" "#ffffff" "#f4b365" "bruiser"
Draw-Enemy "assets/visual/enemies/enemy_shield_cartoon.png" "#f3f7ff" "#cfd8e8" "shield"
Draw-Boss
Draw-Pickups
Draw-ProjectilesAndAbilities
Draw-CloudShadow "assets/backgrounds/cloud_shadow_large.png" 640 320 34
Draw-CloudShadow "assets/backgrounds/cloud_shadow_small.png" 420 220 28
Draw-Panel
Draw-RadialLight

Write-Host "Generated visual identity assets."

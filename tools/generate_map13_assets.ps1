Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$BackgroundDir = Join-Path $Root "assets/backgrounds"
$EnemyDir = Join-Path $Root "assets/visual/enemies/map13"
New-Item -ItemType Directory -Force -Path $BackgroundDir | Out-Null
New-Item -ItemType Directory -Force -Path $EnemyDir | Out-Null

function New-Canvas([int]$Width, [int]$Height) {
	$bitmap = New-Object System.Drawing.Bitmap($Width, $Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
	$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
	$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
	$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
	$graphics.Clear([System.Drawing.Color]::Transparent)
	return @($bitmap, $graphics)
}

function New-Brush($Color) {
	return New-Object System.Drawing.SolidBrush($Color)
}

function New-Pen2($Color, [float]$Width) {
	$pen = New-Object System.Drawing.Pen($Color, $Width)
	$pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
	$pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
	$pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
	return $pen
}

function Draw-RoundedRectangle($Graphics, [System.Drawing.RectangleF]$Rect, [float]$Radius, $Brush, $Pen = $null) {
	$path = New-Object System.Drawing.Drawing2D.GraphicsPath
	$diameter = $Radius * 2.0
	$path.AddArc($Rect.X, $Rect.Y, $diameter, $diameter, 180, 90)
	$path.AddArc($Rect.Right - $diameter, $Rect.Y, $diameter, $diameter, 270, 90)
	$path.AddArc($Rect.Right - $diameter, $Rect.Bottom - $diameter, $diameter, $diameter, 0, 90)
	$path.AddArc($Rect.X, $Rect.Bottom - $diameter, $diameter, $diameter, 90, 90)
	$path.CloseFigure()
	if ($Brush -ne $null) { $Graphics.FillPath($Brush, $path) }
	if ($Pen -ne $null) { $Graphics.DrawPath($Pen, $path) }
	$path.Dispose()
}

function Draw-Diamond($Graphics, [float]$X, [float]$Y, [float]$W, [float]$H, [System.Drawing.Color]$Fill, [System.Drawing.Color]$Outline, [float]$Stroke) {
	$path = New-Object System.Drawing.Drawing2D.GraphicsPath
	$path.AddPolygon(@(
		[System.Drawing.PointF]::new($X, $Y - $H * 0.5),
		[System.Drawing.PointF]::new($X + $W * 0.5, $Y),
		[System.Drawing.PointF]::new($X, $Y + $H * 0.5),
		[System.Drawing.PointF]::new($X - $W * 0.5, $Y)
	))
	$Graphics.FillPath((New-Brush $Fill), $path)
	$Graphics.DrawPath((New-Pen2 $Outline $Stroke), $path)
	$path.Dispose()
}

function Save-Png($Bitmap, $Graphics, [string]$Path) {
	$Graphics.Dispose()
	$Bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
	$Bitmap.Dispose()
}

function Draw-EnemySprite([string]$Path, [string]$Kind, [System.Drawing.Color]$Primary, [System.Drawing.Color]$Accent, [int]$Size = 192) {
	$canvas = New-Canvas $Size $Size
	$bitmap = $canvas[0]
	$graphics = $canvas[1]
	$black = [System.Drawing.Color]::FromArgb(255, 12, 16, 24)
	$outline = New-Pen2 $black 10
	if ($Kind -eq "fry") {
		Draw-Diamond $graphics 96 96 88 104 $Primary $black 10
		$graphics.FillEllipse((New-Brush $Accent), 70, 76, 52, 42)
		$graphics.DrawEllipse($outline, 70, 76, 52, 42)
	} elseif ($Kind -eq "eel") {
		$eelPath = New-Object System.Drawing.Drawing2D.GraphicsPath
		$eelPath.AddBezier(34, 106, 72, 22, 120, 170, 160, 86)
		$graphics.DrawPath((New-Pen2 $black 24), $eelPath)
		$graphics.DrawPath((New-Pen2 $Primary 14), $eelPath)
		$eelPath.Dispose()
		Draw-Diamond $graphics 152 84 38 48 $Accent $black 6
	} elseif ($Kind -eq "bulwark") {
		Draw-RoundedRectangle $graphics ([System.Drawing.RectangleF]::new(42, 46, 108, 98)) 24 (New-Brush $Primary) $outline
		Draw-Diamond $graphics 96 94 66 82 $Accent $black 7
	} elseif ($Kind -eq "wraith") {
		$graphics.FillEllipse((New-Brush $Primary), 42, 38, 108, 108)
		$graphics.DrawEllipse($outline, 42, 38, 108, 108)
		Draw-Diamond $graphics 96 96 54 72 $Accent $black 7
		$graphics.DrawLine((New-Pen2 $Primary 12), 58, 138, 42, 166)
		$graphics.DrawLine((New-Pen2 $Primary 12), 134, 138, 150, 166)
	} elseif ($Kind -eq "colossus") {
		Draw-RoundedRectangle $graphics ([System.Drawing.RectangleF]::new(32, 36, 128, 124)) 28 (New-Brush $Primary) $outline
		Draw-Diamond $graphics 76 96 54 76 $Accent $black 7
		Draw-Diamond $graphics 122 96 54 76 $Accent $black 7
	} elseif ($Kind -eq "leviathan") {
		$graphics.FillEllipse((New-Brush $Primary), 28, 42, 200, 150)
		$graphics.DrawEllipse((New-Pen2 $black 14), 28, 42, 200, 150)
		Draw-Diamond $graphics 128 116 92 116 $Accent $black 9
	} elseif ($Kind -eq "kraken") {
		Draw-RoundedRectangle $graphics ([System.Drawing.RectangleF]::new(52, 36, 152, 142)) 36 (New-Brush $Primary) (New-Pen2 $black 14)
		for ($i = 0; $i -lt 5; $i++) {
			$x = 38 + $i * 42
			$graphics.DrawLine((New-Pen2 $black 18), 128, 162, $x, 232)
			$graphics.DrawLine((New-Pen2 $Accent 9), 128, 162, $x, 232)
		}
		Draw-Diamond $graphics 128 108 82 96 $Accent $black 9
	}
	$outline.Dispose()
	Save-Png $bitmap $graphics $Path
}

$background = New-Canvas 2048 1536
$bgBitmap = $background[0]
$bg = $background[1]
$bg.Clear([System.Drawing.Color]::FromArgb(255, 12, 38, 52))
for ($i = 0; $i -lt 16; $i++) {
	$pen = New-Pen2 ([System.Drawing.Color]::FromArgb(70, 94, 232, 255)) (10 + ($i % 4) * 5)
	$y = 80 + $i * 92
	$bg.DrawBezier($pen, -80, $y, 480, $y - 180, 1320, $y + 180, 2140, $y - 60)
	$pen.Dispose()
}
for ($i = 0; $i -lt 28; $i++) {
	$x = 80 + ($i * 239) % 1900
	$y = 90 + ($i * 157) % 1340
	$w = 70 + ($i % 5) * 24
	$h = 90 + ($i % 4) * 26
	$fill = [System.Drawing.Color]::FromArgb(55 + ($i % 3) * 18, 72, 230, 255)
	Draw-Diamond $bg $x $y $w $h $fill ([System.Drawing.Color]::FromArgb(120, 8, 18, 28)) 9
}
for ($i = 0; $i -lt 100; $i++) {
	$x = ($i * 151) % 2048
	$y = ($i * 223) % 1536
	$bg.FillEllipse((New-Brush ([System.Drawing.Color]::FromArgb(90, 160, 255, 238))), $x, $y, 7, 7)
}
Save-Png $bgBitmap $bg (Join-Path $BackgroundDir "map13_quantum_reef.png")

Draw-EnemySprite (Join-Path $EnemyDir "quantum_fry.png") "fry" ([System.Drawing.Color]::FromArgb(255, 52, 210, 236)) ([System.Drawing.Color]::FromArgb(255, 184, 255, 242))
Draw-EnemySprite (Join-Path $EnemyDir "phase_eel.png") "eel" ([System.Drawing.Color]::FromArgb(255, 82, 156, 255)) ([System.Drawing.Color]::FromArgb(255, 214, 252, 255))
Draw-EnemySprite (Join-Path $EnemyDir "coral_bulwark.png") "bulwark" ([System.Drawing.Color]::FromArgb(255, 42, 132, 166)) ([System.Drawing.Color]::FromArgb(255, 112, 244, 222))
Draw-EnemySprite (Join-Path $EnemyDir "tide_wraith.png") "wraith" ([System.Drawing.Color]::FromArgb(255, 112, 92, 230)) ([System.Drawing.Color]::FromArgb(255, 140, 248, 255))
Draw-EnemySprite (Join-Path $EnemyDir "reef_colossus.png") "colossus" ([System.Drawing.Color]::FromArgb(255, 34, 96, 138)) ([System.Drawing.Color]::FromArgb(255, 96, 230, 212))
Draw-EnemySprite (Join-Path $EnemyDir "boss_reef_leviathan.png") "leviathan" ([System.Drawing.Color]::FromArgb(255, 42, 176, 220)) ([System.Drawing.Color]::FromArgb(255, 196, 255, 238)) 256
Draw-EnemySprite (Join-Path $EnemyDir "boss_quantum_kraken.png") "kraken" ([System.Drawing.Color]::FromArgb(255, 92, 78, 214)) ([System.Drawing.Color]::FromArgb(255, 120, 240, 255)) 256

Write-Host "Generated Quantum Reef assets."

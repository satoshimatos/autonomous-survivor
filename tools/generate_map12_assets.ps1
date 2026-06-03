Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$BackgroundDir = Join-Path $Root "assets/backgrounds"
$EnemyDir = Join-Path $Root "assets/visual/enemies/map12"
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

function Save-Png($Bitmap, $Graphics, [string]$Path) {
	$Graphics.Dispose()
	$Bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
	$Bitmap.Dispose()
}

function Draw-Gear($Graphics, [float]$X, [float]$Y, [float]$Radius, [int]$Teeth, [System.Drawing.Color]$Fill, [System.Drawing.Color]$Outline) {
	$points = New-Object System.Collections.Generic.List[System.Drawing.PointF]
	for ($i = 0; $i -lt $Teeth * 2; $i++) {
		$angle = -[Math]::PI / 2.0 + ([Math]::PI * 2.0 * $i / ($Teeth * 2))
		$r = if ($i % 2 -eq 0) { $Radius } else { $Radius * 0.78 }
		$points.Add([System.Drawing.PointF]::new($X + [Math]::Cos($angle) * $r, $Y + [Math]::Sin($angle) * $r))
	}
	$path = New-Object System.Drawing.Drawing2D.GraphicsPath
	$path.AddPolygon($points.ToArray())
	$Graphics.FillPath((New-Brush $Fill), $path)
	$Graphics.DrawPath((New-Pen2 $Outline ($Radius * 0.13)), $path)
	$path.Dispose()
	$hole = [System.Drawing.RectangleF]::new($X - $Radius * 0.28, $Y - $Radius * 0.28, $Radius * 0.56, $Radius * 0.56)
	$Graphics.FillEllipse((New-Brush ([System.Drawing.Color]::FromArgb(255, 42, 31, 20))), $hole)
	$Graphics.DrawEllipse((New-Pen2 $Outline ($Radius * 0.07)), $hole)
}

function Draw-EnemySprite([string]$Path, [string]$Kind, [System.Drawing.Color]$Primary, [System.Drawing.Color]$Accent, [int]$Size = 192) {
	$canvas = New-Canvas $Size $Size
	$bitmap = $canvas[0]
	$graphics = $canvas[1]
	$black = [System.Drawing.Color]::FromArgb(255, 15, 14, 18)
	$dark = [System.Drawing.Color]::FromArgb(255, 48, 34, 24)
	$outline = New-Pen2 $black 10
	$thin = New-Pen2 ([System.Drawing.Color]::FromArgb(255, 76, 58, 34)) 4
	if ($Kind -eq "mite") {
		Draw-Gear $graphics 96 98 56 12 $Primary $black
		$graphics.FillEllipse((New-Brush $Accent), 72, 74, 48, 48)
		$graphics.DrawEllipse($outline, 72, 74, 48, 48)
	} elseif ($Kind -eq "lancer") {
		$body = New-Object System.Drawing.Drawing2D.GraphicsPath
		$body.AddPolygon(@([System.Drawing.PointF]::new(96, 22), [System.Drawing.PointF]::new(146, 128), [System.Drawing.PointF]::new(96, 166), [System.Drawing.PointF]::new(46, 128)))
		$graphics.FillPath((New-Brush $Primary), $body)
		$graphics.DrawPath($outline, $body)
		$body.Dispose()
		$graphics.DrawLine((New-Pen2 $Accent 12), 96, 34, 96, 142)
		$graphics.DrawLine($thin, 66, 112, 126, 112)
	} elseif ($Kind -eq "guardian") {
		Draw-RoundedRectangle $graphics ([System.Drawing.RectangleF]::new(42, 52, 108, 88)) 20 (New-Brush $Primary) $outline
		Draw-Gear $graphics 96 96 36 10 $Accent $black
		$graphics.DrawLine((New-Pen2 $dark 9), 48, 146, 144, 146)
	} elseif ($Kind -eq "spring") {
		$graphics.DrawLine((New-Pen2 $Accent 17), 58, 142, 134, 48)
		$graphics.DrawLine((New-Pen2 $Accent 17), 58, 48, 134, 142)
		Draw-Gear $graphics 96 96 44 9 $Primary $black
		$graphics.FillEllipse((New-Brush ([System.Drawing.Color]::FromArgb(255, 255, 92, 48))), 80, 80, 32, 32)
		$graphics.DrawEllipse($outline, 80, 80, 32, 32)
	} elseif ($Kind -eq "titan") {
		Draw-RoundedRectangle $graphics ([System.Drawing.RectangleF]::new(34, 44, 124, 108)) 24 (New-Brush $Primary) $outline
		Draw-Gear $graphics 74 98 34 10 $Accent $black
		Draw-Gear $graphics 120 98 34 10 $Accent $black
		$graphics.DrawLine((New-Pen2 ([System.Drawing.Color]::FromArgb(255, 245, 202, 86)) 8), 54, 64, 138, 64)
	} elseif ($Kind -eq "boss_judge") {
		Draw-Gear $graphics 96 94 72 14 $Primary $black
		Draw-RoundedRectangle $graphics ([System.Drawing.RectangleF]::new(50, 66, 92, 68)) 18 (New-Brush $Accent) $outline
		$graphics.DrawLine((New-Pen2 ([System.Drawing.Color]::FromArgb(255, 255, 232, 124)) 10), 96, 34, 96, 150)
	} elseif ($Kind -eq "boss_foundry") {
		Draw-RoundedRectangle $graphics ([System.Drawing.RectangleF]::new(34, 36, 124, 120)) 26 (New-Brush $Primary) $outline
		Draw-Gear $graphics 96 96 58 12 $Accent $black
		$graphics.FillRectangle((New-Brush ([System.Drawing.Color]::FromArgb(255, 255, 112, 42))), 74, 72, 44, 48)
		$graphics.DrawRectangle($outline, 74, 72, 44, 48)
	}
	$outline.Dispose()
	$thin.Dispose()
	Save-Png $bitmap $graphics $Path
}

$background = New-Canvas 2048 1536
$bgBitmap = $background[0]
$bg = $background[1]
$bg.Clear([System.Drawing.Color]::FromArgb(255, 38, 29, 24))
for ($i = 0; $i -lt 18; $i++) {
	$alpha = 25 + ($i % 4) * 12
	$color = [System.Drawing.Color]::FromArgb($alpha, 238, 174, 70)
	$x = 110 + ($i * 227) % 1900
	$y = 92 + ($i * 163) % 1320
	Draw-Gear $bg $x $y (70 + ($i % 5) * 28) (10 + ($i % 4)) $color ([System.Drawing.Color]::FromArgb(80, 12, 12, 16))
}
for ($i = 0; $i -lt 14; $i++) {
	$pen = New-Pen2 ([System.Drawing.Color]::FromArgb(80, 198, 138, 58)) (12 + ($i % 3) * 4)
	$y = 80 + $i * 104
	$bg.DrawLine($pen, 0, $y, 2048, $y + (($i % 2) * 120 - 60))
	$pen.Dispose()
}
for ($i = 0; $i -lt 90; $i++) {
	$x = ($i * 149) % 2048
	$y = ($i * 211) % 1536
	$bg.FillEllipse((New-Brush ([System.Drawing.Color]::FromArgb(90, 255, 202, 96))), $x, $y, 8, 8)
}
Save-Png $bgBitmap $bg (Join-Path $BackgroundDir "map12_clockwork_spiral.png")

Draw-EnemySprite (Join-Path $EnemyDir "gear_mite.png") "mite" ([System.Drawing.Color]::FromArgb(255, 205, 147, 48)) ([System.Drawing.Color]::FromArgb(255, 92, 212, 242))
Draw-EnemySprite (Join-Path $EnemyDir "pendulum_lancer.png") "lancer" ([System.Drawing.Color]::FromArgb(255, 223, 173, 58)) ([System.Drawing.Color]::FromArgb(255, 255, 232, 126))
Draw-EnemySprite (Join-Path $EnemyDir "brass_guardian.png") "guardian" ([System.Drawing.Color]::FromArgb(255, 138, 92, 36)) ([System.Drawing.Color]::FromArgb(255, 229, 178, 72))
Draw-EnemySprite (Join-Path $EnemyDir "spring_horror.png") "spring" ([System.Drawing.Color]::FromArgb(255, 205, 88, 42)) ([System.Drawing.Color]::FromArgb(255, 241, 184, 70))
Draw-EnemySprite (Join-Path $EnemyDir "clockwork_titan.png") "titan" ([System.Drawing.Color]::FromArgb(255, 116, 74, 35)) ([System.Drawing.Color]::FromArgb(255, 215, 159, 64))
Draw-EnemySprite (Join-Path $EnemyDir "boss_gear_judge.png") "boss_judge" ([System.Drawing.Color]::FromArgb(255, 208, 142, 44)) ([System.Drawing.Color]::FromArgb(255, 88, 58, 35)) 256
Draw-EnemySprite (Join-Path $EnemyDir "boss_time_foundry.png") "boss_foundry" ([System.Drawing.Color]::FromArgb(255, 122, 76, 36)) ([System.Drawing.Color]::FromArgb(255, 221, 158, 62)) 256

Write-Host "Generated Clockwork Spiral assets."

Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$BackgroundDir = Join-Path $Root "assets/backgrounds"
$EnemyDir = Join-Path $Root "assets/visual/enemies/map15"
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

function Draw-Keyhole($Graphics, [float]$X, [float]$Y, [float]$Size, [System.Drawing.Color]$Fill, [System.Drawing.Color]$Outline, [float]$Stroke) {
	$Graphics.FillEllipse((New-Brush $Fill), $X - $Size * 0.33, $Y - $Size * 0.5, $Size * 0.66, $Size * 0.66)
	$Graphics.DrawEllipse((New-Pen2 $Outline $Stroke), $X - $Size * 0.33, $Y - $Size * 0.5, $Size * 0.66, $Size * 0.66)
	$path = New-Object System.Drawing.Drawing2D.GraphicsPath
	$path.AddPolygon(@(
		[System.Drawing.PointF]::new($X - $Size * 0.18, $Y),
		[System.Drawing.PointF]::new($X + $Size * 0.18, $Y),
		[System.Drawing.PointF]::new($X + $Size * 0.3, $Y + $Size * 0.48),
		[System.Drawing.PointF]::new($X - $Size * 0.3, $Y + $Size * 0.48)
	))
	$Graphics.FillPath((New-Brush $Fill), $path)
	$Graphics.DrawPath((New-Pen2 $Outline $Stroke), $path)
	$path.Dispose()
}

function Draw-Burst($Graphics, [float]$X, [float]$Y, [float]$Radius, [System.Drawing.Color]$Fill, [System.Drawing.Color]$Outline, [float]$Stroke) {
	$path = New-Object System.Drawing.Drawing2D.GraphicsPath
	$points = New-Object System.Collections.Generic.List[System.Drawing.PointF]
	for ($i = 0; $i -lt 14; $i++) {
		$r = $(if ($i % 2 -eq 0) { $Radius } else { $Radius * 0.58 })
		$a = -[Math]::PI / 2.0 + [Math]::PI * 2.0 * $i / 14.0
		$points.Add([System.Drawing.PointF]::new($X + [Math]::Cos($a) * $r, $Y + [Math]::Sin($a) * $r))
	}
	$path.AddPolygon($points.ToArray())
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
	$black = [System.Drawing.Color]::FromArgb(255, 10, 8, 16)
	$outline = New-Pen2 $black 10
	$cx = $Size * 0.5
	$cy = $Size * 0.5
	if ($Kind -eq "echo") {
		Draw-Burst $graphics $cx $cy ($Size * 0.39) $Primary $black ($Size * 0.05)
		Draw-Keyhole $graphics $cx $cy ($Size * 0.48) $Accent $black ($Size * 0.035)
	} elseif ($Kind -eq "imp") {
		$shapePath = New-Object System.Drawing.Drawing2D.GraphicsPath
		$shapePath.AddPolygon(@(
			[System.Drawing.PointF]::new($Size * 0.78, $Size * 0.5),
			[System.Drawing.PointF]::new($Size * 0.28, $Size * 0.22),
			[System.Drawing.PointF]::new($Size * 0.38, $Size * 0.5),
			[System.Drawing.PointF]::new($Size * 0.28, $Size * 0.78)
		))
		$graphics.FillPath((New-Brush $Primary), $shapePath)
		$graphics.DrawPath($outline, $shapePath)
		$shapePath.Dispose()
		Draw-Diamond $graphics ($Size * 0.5) $cy ($Size * 0.27) ($Size * 0.35) $Accent $black ($Size * 0.035)
	} elseif ($Kind -eq "guard") {
		Draw-RoundedRectangle $graphics ([System.Drawing.RectangleF]::new($Size * 0.19, $Size * 0.18, $Size * 0.62, $Size * 0.64)) ($Size * 0.14) (New-Brush $Primary) $outline
		Draw-Keyhole $graphics $cx $cy ($Size * 0.52) $Accent $black ($Size * 0.035)
	} elseif ($Kind -eq "wraith") {
		$graphics.FillEllipse((New-Brush $Primary), $Size * 0.19, $Size * 0.16, $Size * 0.62, $Size * 0.62)
		$graphics.DrawEllipse($outline, $Size * 0.19, $Size * 0.16, $Size * 0.62, $Size * 0.62)
		Draw-Burst $graphics $cx $cy ($Size * 0.28) $Accent $black ($Size * 0.035)
		$graphics.DrawLine((New-Pen2 $Primary ($Size * 0.065)), $Size * 0.33, $Size * 0.72, $Size * 0.18, $Size * 0.9)
		$graphics.DrawLine((New-Pen2 $Primary ($Size * 0.065)), $Size * 0.67, $Size * 0.72, $Size * 0.82, $Size * 0.9)
	} elseif ($Kind -eq "goliath") {
		Draw-RoundedRectangle $graphics ([System.Drawing.RectangleF]::new($Size * 0.14, $Size * 0.17, $Size * 0.72, $Size * 0.7)) ($Size * 0.14) (New-Brush $Primary) $outline
		Draw-Diamond $graphics ($Size * 0.38) $cy ($Size * 0.28) ($Size * 0.44) $Accent $black ($Size * 0.035)
		Draw-Diamond $graphics ($Size * 0.63) $cy ($Size * 0.28) ($Size * 0.44) $Accent $black ($Size * 0.035)
	} elseif ($Kind -eq "auditor") {
		Draw-Burst $graphics $cx $cy ($Size * 0.43) $Primary $black ($Size * 0.055)
		Draw-Keyhole $graphics $cx $cy ($Size * 0.58) $Accent $black ($Size * 0.04)
	} elseif ($Kind -eq "treasury") {
		Draw-RoundedRectangle $graphics ([System.Drawing.RectangleF]::new($Size * 0.16, $Size * 0.12, $Size * 0.68, $Size * 0.76)) ($Size * 0.13) (New-Brush $Primary) (New-Pen2 $black ($Size * 0.055))
		Draw-Diamond $graphics $cx ($Size * 0.42) ($Size * 0.48) ($Size * 0.42) $Accent $black ($Size * 0.04)
		Draw-Keyhole $graphics $cx ($Size * 0.62) ($Size * 0.38) ([System.Drawing.Color]::FromArgb(255, 12, 8, 18)) $black ($Size * 0.025)
	}
	$outline.Dispose()
	Save-Png $bitmap $graphics $Path
}

$background = New-Canvas 2048 1536
$bgBitmap = $background[0]
$bg = $background[1]
$bg.Clear([System.Drawing.Color]::FromArgb(255, 18, 12, 34))
for ($i = 0; $i -lt 16; $i++) {
	$pen = New-Pen2 ([System.Drawing.Color]::FromArgb(76, 154, 86, 232)) (8 + ($i % 4) * 5)
	$x = -220 + $i * 160
	$bg.DrawLine($pen, $x, -80, $x + 420, 1620)
	$pen.Dispose()
}
for ($i = 0; $i -lt 30; $i++) {
	$x = 70 + ($i * 229) % 1900
	$y = 90 + ($i * 173) % 1340
	$w = 120 + ($i % 5) * 34
	$h = 66 + ($i % 4) * 28
	$fill = [System.Drawing.Color]::FromArgb(72 + ($i % 3) * 16, 38, 24, 66)
	Draw-RoundedRectangle $bg ([System.Drawing.RectangleF]::new($x, $y, $w, $h)) 18 (New-Brush $fill) (New-Pen2 ([System.Drawing.Color]::FromArgb(130, 206, 158, 74)) 6)
}
for ($i = 0; $i -lt 68; $i++) {
	$x = ($i * 181) % 2048
	$y = ($i * 263) % 1536
	Draw-Keyhole $bg $x $y (24 + ($i % 3) * 8) ([System.Drawing.Color]::FromArgb(64, 216, 170, 82)) ([System.Drawing.Color]::FromArgb(70, 12, 8, 18)) 3
}
Save-Png $bgBitmap $bg (Join-Path $BackgroundDir "map15_umbral_vault.png")

Draw-EnemySprite (Join-Path $EnemyDir "vault_echo.png") "echo" ([System.Drawing.Color]::FromArgb(255, 92, 54, 150)) ([System.Drawing.Color]::FromArgb(255, 218, 174, 84))
Draw-EnemySprite (Join-Path $EnemyDir "ledger_imp.png") "imp" ([System.Drawing.Color]::FromArgb(255, 214, 142, 42)) ([System.Drawing.Color]::FromArgb(255, 112, 58, 186))
Draw-EnemySprite (Join-Path $EnemyDir "lockstep_guard.png") "guard" ([System.Drawing.Color]::FromArgb(255, 42, 32, 76)) ([System.Drawing.Color]::FromArgb(255, 226, 178, 78))
Draw-EnemySprite (Join-Path $EnemyDir "interest_wraith.png") "wraith" ([System.Drawing.Color]::FromArgb(255, 138, 78, 222)) ([System.Drawing.Color]::FromArgb(255, 238, 200, 92))
Draw-EnemySprite (Join-Path $EnemyDir "vault_goliath.png") "goliath" ([System.Drawing.Color]::FromArgb(255, 34, 22, 54)) ([System.Drawing.Color]::FromArgb(255, 184, 132, 64))
Draw-EnemySprite (Join-Path $EnemyDir "boss_vault_auditor.png") "auditor" ([System.Drawing.Color]::FromArgb(255, 108, 56, 196)) ([System.Drawing.Color]::FromArgb(255, 236, 188, 78)) 256
Draw-EnemySprite (Join-Path $EnemyDir "boss_black_treasury.png") "treasury" ([System.Drawing.Color]::FromArgb(255, 34, 22, 56)) ([System.Drawing.Color]::FromArgb(255, 208, 148, 64)) 256

Write-Host "Generated Umbral Vault assets."

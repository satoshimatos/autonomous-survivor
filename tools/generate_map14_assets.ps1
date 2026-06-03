Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$BackgroundDir = Join-Path $Root "assets/backgrounds"
$EnemyDir = Join-Path $Root "assets/visual/enemies/map14"
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

function Draw-SunBurst($Graphics, [float]$X, [float]$Y, [float]$Radius, [System.Drawing.Color]$Fill, [System.Drawing.Color]$Outline, [float]$Stroke) {
	$path = New-Object System.Drawing.Drawing2D.GraphicsPath
	$points = New-Object System.Collections.Generic.List[System.Drawing.PointF]
	for ($i = 0; $i -lt 16; $i++) {
		$r = $(if ($i % 2 -eq 0) { $Radius } else { $Radius * 0.62 })
		$a = -[Math]::PI / 2.0 + [Math]::PI * 2.0 * $i / 16.0
		$points.Add([System.Drawing.PointF]::new($X + [Math]::Cos($a) * $r, $Y + [Math]::Sin($a) * $r))
	}
	$path.AddPolygon($points.ToArray())
	$Graphics.FillPath((New-Brush $Fill), $path)
	$Graphics.DrawPath((New-Pen2 $Outline $Stroke), $path)
	$path.Dispose()
}

function Draw-EnemySprite([string]$Path, [string]$Kind, [System.Drawing.Color]$Primary, [System.Drawing.Color]$Accent, [int]$Size = 192) {
	$canvas = New-Canvas $Size $Size
	$bitmap = $canvas[0]
	$graphics = $canvas[1]
	$black = [System.Drawing.Color]::FromArgb(255, 16, 14, 12)
	$outline = New-Pen2 $black 10
	if ($Kind -eq "spark") {
		Draw-SunBurst $graphics 96 96 76 $Primary $black 10
		$graphics.FillEllipse((New-Brush $Accent), 72, 72, 48, 48)
		$graphics.DrawEllipse($outline, 72, 72, 48, 48)
	} elseif ($Kind -eq "lancer") {
		$shapePath = New-Object System.Drawing.Drawing2D.GraphicsPath
		$shapePath.AddPolygon(@(
			[System.Drawing.PointF]::new(152, 96),
			[System.Drawing.PointF]::new(56, 38),
			[System.Drawing.PointF]::new(78, 96),
			[System.Drawing.PointF]::new(56, 154)
		))
		$graphics.FillPath((New-Brush $Primary), $shapePath)
		$graphics.DrawPath($outline, $shapePath)
		$shapePath.Dispose()
		Draw-Diamond $graphics 92 96 48 58 $Accent $black 7
	} elseif ($Kind -eq "guard") {
		Draw-RoundedRectangle $graphics ([System.Drawing.RectangleF]::new(38, 42, 116, 108)) 22 (New-Brush $Primary) $outline
		Draw-SunBurst $graphics 96 96 54 $Accent $black 7
	} elseif ($Kind -eq "wraith") {
		$graphics.FillEllipse((New-Brush $Primary), 38, 34, 116, 116)
		$graphics.DrawEllipse($outline, 38, 34, 116, 116)
		Draw-SunBurst $graphics 96 96 48 $Accent $black 7
		$graphics.DrawLine((New-Pen2 $Primary 12), 58, 138, 34, 166)
		$graphics.DrawLine((New-Pen2 $Primary 12), 134, 138, 158, 166)
	} elseif ($Kind -eq "colossus") {
		Draw-RoundedRectangle $graphics ([System.Drawing.RectangleF]::new(30, 34, 132, 128)) 26 (New-Brush $Primary) $outline
		Draw-Diamond $graphics 72 96 54 76 $Accent $black 7
		Draw-Diamond $graphics 124 96 54 76 $Accent $black 7
	} elseif ($Kind -eq "judicator") {
		Draw-SunBurst $graphics 128 128 110 $Primary $black 14
		Draw-Diamond $graphics 128 128 104 124 $Accent $black 10
	} elseif ($Kind -eq "citadel") {
		Draw-RoundedRectangle $graphics ([System.Drawing.RectangleF]::new(42, 34, 172, 174)) 34 (New-Brush $Primary) (New-Pen2 $black 14)
		Draw-SunBurst $graphics 128 122 82 $Accent $black 10
		for ($i = 0; $i -lt 5; $i++) {
			$x = 56 + $i * 36
			$graphics.DrawLine((New-Pen2 $black 16), $x, 206, $x, 238)
			$graphics.DrawLine((New-Pen2 $Primary 8), $x, 206, $x, 238)
		}
	}
	$outline.Dispose()
	Save-Png $bitmap $graphics $Path
}

$background = New-Canvas 2048 1536
$bgBitmap = $background[0]
$bg = $background[1]
$bg.Clear([System.Drawing.Color]::FromArgb(255, 56, 24, 8))
for ($i = 0; $i -lt 18; $i++) {
	$pen = New-Pen2 ([System.Drawing.Color]::FromArgb(70, 255, 188, 52)) (9 + ($i % 4) * 5)
	$x = -140 + $i * 132
	$bg.DrawLine($pen, $x, -90, $x + 560, 1620)
	$pen.Dispose()
}
for ($i = 0; $i -lt 24; $i++) {
	$x = 80 + ($i * 271) % 1900
	$y = 80 + ($i * 181) % 1340
	$w = 110 + ($i % 4) * 34
	$h = 64 + ($i % 5) * 22
	$fill = [System.Drawing.Color]::FromArgb(70 + ($i % 3) * 18, 255, 146, 32)
	Draw-RoundedRectangle $bg ([System.Drawing.RectangleF]::new($x, $y, $w, $h)) 18 (New-Brush $fill) (New-Pen2 ([System.Drawing.Color]::FromArgb(110, 18, 12, 6)) 7)
}
for ($i = 0; $i -lt 70; $i++) {
	$x = ($i * 193) % 2048
	$y = ($i * 251) % 1536
	Draw-SunBurst $bg $x $y (12 + ($i % 4) * 4) ([System.Drawing.Color]::FromArgb(76, 255, 220, 94)) ([System.Drawing.Color]::FromArgb(80, 96, 42, 8)) 3
}
Save-Png $bgBitmap $bg (Join-Path $BackgroundDir "map14_solar_bastion.png")

Draw-EnemySprite (Join-Path $EnemyDir "sun_spark.png") "spark" ([System.Drawing.Color]::FromArgb(255, 255, 190, 46)) ([System.Drawing.Color]::FromArgb(255, 255, 244, 148))
Draw-EnemySprite (Join-Path $EnemyDir "flare_lancer.png") "lancer" ([System.Drawing.Color]::FromArgb(255, 255, 102, 24)) ([System.Drawing.Color]::FromArgb(255, 255, 224, 88))
Draw-EnemySprite (Join-Path $EnemyDir "heliostat_guard.png") "guard" ([System.Drawing.Color]::FromArgb(255, 172, 88, 26)) ([System.Drawing.Color]::FromArgb(255, 255, 204, 68))
Draw-EnemySprite (Join-Path $EnemyDir "corona_wraith.png") "wraith" ([System.Drawing.Color]::FromArgb(255, 255, 212, 70)) ([System.Drawing.Color]::FromArgb(255, 255, 252, 160))
Draw-EnemySprite (Join-Path $EnemyDir "bastion_colossus.png") "colossus" ([System.Drawing.Color]::FromArgb(255, 132, 52, 16)) ([System.Drawing.Color]::FromArgb(255, 255, 156, 38))
Draw-EnemySprite (Join-Path $EnemyDir "boss_solar_judicator.png") "judicator" ([System.Drawing.Color]::FromArgb(255, 255, 134, 26)) ([System.Drawing.Color]::FromArgb(255, 255, 230, 100)) 256
Draw-EnemySprite (Join-Path $EnemyDir "boss_helios_citadel.png") "citadel" ([System.Drawing.Color]::FromArgb(255, 206, 72, 18)) ([System.Drawing.Color]::FromArgb(255, 255, 180, 42)) 256

Write-Host "Generated Solar Bastion assets."

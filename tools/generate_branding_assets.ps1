Add-Type -AssemblyName System.Drawing

$ErrorActionPreference = "Stop"

$Root = Split-Path -Parent $PSScriptRoot
$OutDir = Join-Path $Root "assets/ui/branding"
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null

function New-Canvas([int]$Width, [int]$Height) {
	$bitmap = New-Object System.Drawing.Bitmap($Width, $Height, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
	$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
	$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
	$graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAliasGridFit
	$graphics.Clear([System.Drawing.Color]::Transparent)
	return @($bitmap, $graphics)
}

function New-SolidBrush($Color) {
	return New-Object System.Drawing.SolidBrush($Color)
}

function New-Pen($Color, [float]$Width) {
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

function Draw-BrandMark($Graphics, [float]$X, [float]$Y, [float]$Size) {
	$black = [System.Drawing.Color]::FromArgb(255, 18, 20, 28)
	$navy = [System.Drawing.Color]::FromArgb(255, 28, 46, 72)
	$cyan = [System.Drawing.Color]::FromArgb(255, 72, 212, 240)
	$orange = [System.Drawing.Color]::FromArgb(255, 255, 139, 40)
	$yellow = [System.Drawing.Color]::FromArgb(255, 255, 217, 84)
	$green = [System.Drawing.Color]::FromArgb(255, 72, 214, 128)
	$white = [System.Drawing.Color]::FromArgb(255, 238, 248, 255)
	$outline = New-Pen $black ($Size * 0.045)
	$heavyOutline = New-Pen $black ($Size * 0.07)
	
	$shield = New-Object System.Drawing.Drawing2D.GraphicsPath
	$shield.AddPolygon(@(
		[System.Drawing.PointF]::new($X + $Size * 0.50, $Y + $Size * 0.04),
		[System.Drawing.PointF]::new($X + $Size * 0.88, $Y + $Size * 0.22),
		[System.Drawing.PointF]::new($X + $Size * 0.82, $Y + $Size * 0.72),
		[System.Drawing.PointF]::new($X + $Size * 0.50, $Y + $Size * 0.94),
		[System.Drawing.PointF]::new($X + $Size * 0.18, $Y + $Size * 0.72),
		[System.Drawing.PointF]::new($X + $Size * 0.12, $Y + $Size * 0.22)
	))
	$Graphics.FillPath((New-SolidBrush $navy), $shield)
	$Graphics.DrawPath($heavyOutline, $shield)
	$shield.Dispose()
	
	$glow = New-SolidBrush ([System.Drawing.Color]::FromArgb(90, 96, 230, 255))
	$Graphics.FillEllipse($glow, $X + $Size * 0.24, $Y + $Size * 0.18, $Size * 0.52, $Size * 0.52)
	$glow.Dispose()
	
	$tankBody = [System.Drawing.RectangleF]::new($X + $Size * 0.24, $Y + $Size * 0.54, $Size * 0.52, $Size * 0.20)
	Draw-RoundedRectangle $Graphics $tankBody ($Size * 0.06) (New-SolidBrush $green) $outline
	$tankTop = [System.Drawing.RectangleF]::new($X + $Size * 0.36, $Y + $Size * 0.42, $Size * 0.28, $Size * 0.20)
	Draw-RoundedRectangle $Graphics $tankTop ($Size * 0.07) (New-SolidBrush $cyan) $outline
	$barrel = New-Pen $yellow ($Size * 0.095)
	$Graphics.DrawLine($barrel, $X + $Size * 0.50, $Y + $Size * 0.46, $X + $Size * 0.50, $Y + $Size * 0.22)
	$Graphics.DrawLine($outline, $X + $Size * 0.50, $Y + $Size * 0.46, $X + $Size * 0.50, $Y + $Size * 0.22)
	$Graphics.FillEllipse((New-SolidBrush $orange), $X + $Size * 0.43, $Y + $Size * 0.16, $Size * 0.14, $Size * 0.14)
	$Graphics.DrawEllipse($outline, $X + $Size * 0.43, $Y + $Size * 0.16, $Size * 0.14, $Size * 0.14)
	for ($i = 0; $i -lt 3; $i++) {
		$cx = $X + $Size * (0.32 + 0.18 * $i)
		$Graphics.FillEllipse((New-SolidBrush $white), $cx, $Y + $Size * 0.61, $Size * 0.075, $Size * 0.075)
		$Graphics.DrawEllipse($outline, $cx, $Y + $Size * 0.61, $Size * 0.075, $Size * 0.075)
	}
	$barrel.Dispose()
	$outline.Dispose()
	$heavyOutline.Dispose()
}

function Draw-CenteredText($Graphics, [string]$Text, [string]$FontName, [float]$Size, [System.Drawing.RectangleF]$Rect, $Brush, $OutlineBrush = $null, [float]$OutlineOffset = 0.0) {
	$format = New-Object System.Drawing.StringFormat
	$format.Alignment = [System.Drawing.StringAlignment]::Center
	$format.LineAlignment = [System.Drawing.StringAlignment]::Center
	$format.Trimming = [System.Drawing.StringTrimming]::EllipsisCharacter
	$font = New-Object System.Drawing.Font($FontName, $Size, [System.Drawing.FontStyle]::Bold, [System.Drawing.GraphicsUnit]::Pixel)
	if ($OutlineBrush -ne $null -and $OutlineOffset -gt 0.0) {
		foreach ($dx in @(-$OutlineOffset, 0, $OutlineOffset)) {
			foreach ($dy in @(-$OutlineOffset, 0, $OutlineOffset)) {
				if ($dx -ne 0 -or $dy -ne 0) {
					$offsetRect = [System.Drawing.RectangleF]::new($Rect.X + $dx, $Rect.Y + $dy, $Rect.Width, $Rect.Height)
					$Graphics.DrawString($Text, $font, $OutlineBrush, $offsetRect, $format)
				}
			}
		}
	}
	$Graphics.DrawString($Text, $font, $Brush, $Rect, $format)
	$font.Dispose()
	$format.Dispose()
}

function Draw-HighlightStripe($Graphics, [System.Drawing.RectangleF]$Rect, [System.Drawing.Color]$Color) {
	$path = New-Object System.Drawing.Drawing2D.GraphicsPath
	$path.AddEllipse($Rect)
	$brush = New-SolidBrush ([System.Drawing.Color]::FromArgb(70, $Color.R, $Color.G, $Color.B))
	$Graphics.FillPath($brush, $path)
	$brush.Dispose()
	$path.Dispose()
}

function New-LinearBrush([System.Drawing.RectangleF]$Rect, [System.Drawing.Color]$StartColor, [System.Drawing.Color]$EndColor, [float]$Angle) {
	return New-Object System.Drawing.Drawing2D.LinearGradientBrush($Rect, $StartColor, $EndColor, $Angle)
}

function Draw-AngledPanel($Graphics, [System.Drawing.RectangleF]$Rect, [System.Drawing.Color]$StartColor, [System.Drawing.Color]$EndColor, [float]$Radius, [float]$OutlineWidth) {
	$black = [System.Drawing.Color]::FromArgb(255, 7, 9, 14)
	$brush = New-LinearBrush $Rect $StartColor $EndColor 25
	Draw-RoundedRectangle $Graphics $Rect $Radius $brush (New-Pen $black $OutlineWidth)
	$brush.Dispose()
	$inset = [System.Drawing.RectangleF]::new($Rect.X + $OutlineWidth * 1.5, $Rect.Y + $OutlineWidth * 1.5, $Rect.Width - $OutlineWidth * 3.0, $Rect.Height - $OutlineWidth * 3.0)
	Draw-RoundedRectangle $Graphics $inset ($Radius * 0.72) $null (New-Pen ([System.Drawing.Color]::FromArgb(175, 92, 224, 255)) ($OutlineWidth * 0.34))
}

function Draw-EnergyRays($Graphics, [float]$CenterX, [float]$CenterY, [float]$Radius, [System.Drawing.Color]$Color) {
	$brush = New-SolidBrush ([System.Drawing.Color]::FromArgb(90, $Color.R, $Color.G, $Color.B))
	for ($i = 0; $i -lt 16; $i++) {
		$angle = ($i * 22.5) * [Math]::PI / 180.0
		$nextAngle = (($i * 22.5) + 7.0) * [Math]::PI / 180.0
		$inner = $Radius * 0.30
		$outer = $Radius * (0.76 + (($i % 3) * 0.06))
		$path = New-Object System.Drawing.Drawing2D.GraphicsPath
		$path.AddPolygon(@(
			[System.Drawing.PointF]::new($CenterX + [Math]::Cos($angle) * $inner, $CenterY + [Math]::Sin($angle) * $inner),
			[System.Drawing.PointF]::new($CenterX + [Math]::Cos(($angle + $nextAngle) * 0.5) * $outer, $CenterY + [Math]::Sin(($angle + $nextAngle) * 0.5) * $outer),
			[System.Drawing.PointF]::new($CenterX + [Math]::Cos($nextAngle) * $inner, $CenterY + [Math]::Sin($nextAngle) * $inner)
		))
		$Graphics.FillPath($brush, $path)
		$path.Dispose()
	}
	$brush.Dispose()
}

function Draw-LauncherBase($Graphics, [int]$Size) {
	$rect = [System.Drawing.RectangleF]::new($Size * 0.035, $Size * 0.035, $Size * 0.93, $Size * 0.93)
	Draw-AngledPanel $Graphics $rect ([System.Drawing.Color]::FromArgb(255, 11, 19, 34)) ([System.Drawing.Color]::FromArgb(255, 31, 53, 84)) ($Size * 0.17) ($Size * 0.035)
	Draw-EnergyRays $Graphics ($Size * 0.5) ($Size * 0.48) ($Size * 0.56) ([System.Drawing.Color]::FromArgb(255, 255, 199, 65))
	$Graphics.FillEllipse((New-SolidBrush ([System.Drawing.Color]::FromArgb(82, 78, 225, 255))), $Size * 0.18, $Size * 0.18, $Size * 0.64, $Size * 0.64)
	$Graphics.DrawEllipse((New-Pen ([System.Drawing.Color]::FromArgb(210, 76, 226, 255)) ($Size * 0.018)), $Size * 0.18, $Size * 0.18, $Size * 0.64, $Size * 0.64)
}

function Draw-ASBadge($Graphics, [float]$X, [float]$Y, [float]$Size) {
	$black = [System.Drawing.Color]::FromArgb(255, 7, 9, 14)
	$badge = [System.Drawing.RectangleF]::new($X, $Y, $Size, $Size * 0.58)
	Draw-RoundedRectangle $Graphics $badge ($Size * 0.12) (New-SolidBrush ([System.Drawing.Color]::FromArgb(245, 255, 211, 76))) (New-Pen $black ($Size * 0.055))
	Draw-CenteredText $Graphics "AS" "Arial Black" ($Size * 0.34) $badge (New-SolidBrush ([System.Drawing.Color]::FromArgb(255, 20, 27, 40))) $null 0
}

function Draw-TankGlyph($Graphics, [float]$X, [float]$Y, [float]$Size) {
	$black = [System.Drawing.Color]::FromArgb(255, 14, 16, 22)
	$steel = [System.Drawing.Color]::FromArgb(255, 87, 119, 139)
	$steelLight = [System.Drawing.Color]::FromArgb(255, 160, 202, 215)
	$cyan = [System.Drawing.Color]::FromArgb(255, 80, 218, 244)
	$amber = [System.Drawing.Color]::FromArgb(255, 255, 194, 70)
	$green = [System.Drawing.Color]::FromArgb(255, 75, 210, 130)
	$outline = New-Pen $black ($Size * 0.06)
	$thin = New-Pen ([System.Drawing.Color]::FromArgb(255, 35, 50, 62)) ($Size * 0.022)

	$leftTrack = [System.Drawing.RectangleF]::new($X + $Size * 0.10, $Y + $Size * 0.50, $Size * 0.80, $Size * 0.18)
	$rightTrack = [System.Drawing.RectangleF]::new($X + $Size * 0.14, $Y + $Size * 0.66, $Size * 0.72, $Size * 0.15)
	Draw-RoundedRectangle $Graphics $leftTrack ($Size * 0.07) (New-SolidBrush ([System.Drawing.Color]::FromArgb(255, 42, 58, 72))) $outline
	Draw-RoundedRectangle $Graphics $rightTrack ($Size * 0.06) (New-SolidBrush ([System.Drawing.Color]::FromArgb(255, 28, 38, 48))) $outline
	for ($i = 0; $i -lt 5; $i++) {
		$wheelX = $X + $Size * (0.18 + 0.14 * $i)
		$Graphics.FillEllipse((New-SolidBrush $steelLight), $wheelX, $Y + $Size * 0.55, $Size * 0.075, $Size * 0.075)
		$Graphics.DrawEllipse($thin, $wheelX, $Y + $Size * 0.55, $Size * 0.075, $Size * 0.075)
	}
	$body = [System.Drawing.RectangleF]::new($X + $Size * 0.18, $Y + $Size * 0.36, $Size * 0.64, $Size * 0.22)
	Draw-RoundedRectangle $Graphics $body ($Size * 0.07) (New-SolidBrush $green) $outline
	$turret = [System.Drawing.RectangleF]::new($X + $Size * 0.34, $Y + $Size * 0.22, $Size * 0.32, $Size * 0.23)
	Draw-RoundedRectangle $Graphics $turret ($Size * 0.08) (New-SolidBrush $cyan) $outline
	$barrel = New-Pen $amber ($Size * 0.105)
	$Graphics.DrawLine($outline, $X + $Size * 0.50, $Y + $Size * 0.27, $X + $Size * 0.50, $Y + $Size * 0.05)
	$Graphics.DrawLine($barrel, $X + $Size * 0.50, $Y + $Size * 0.27, $X + $Size * 0.50, $Y + $Size * 0.05)
	$Graphics.DrawLine((New-Pen ([System.Drawing.Color]::FromArgb(255, 255, 236, 142)) ($Size * 0.028)), $X + $Size * 0.47, $Y + $Size * 0.22, $X + $Size * 0.47, $Y + $Size * 0.06)
	$Graphics.FillEllipse((New-SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 125, 46))), $X + $Size * 0.405, $Y + $Size * -0.02, $Size * 0.19, $Size * 0.19)
	$Graphics.DrawEllipse($outline, $X + $Size * 0.405, $Y + $Size * -0.02, $Size * 0.19, $Size * 0.19)
	Draw-HighlightStripe $Graphics ([System.Drawing.RectangleF]::new($X + $Size * 0.22, $Y + $Size * 0.30, $Size * 0.58, $Size * 0.20)) $steel
	$barrel.Dispose()
	$outline.Dispose()
	$thin.Dispose()
}

function Draw-LogoPlate($Graphics, [System.Drawing.RectangleF]$Rect) {
	$black = [System.Drawing.Color]::FromArgb(255, 12, 14, 20)
	$dark = [System.Drawing.Color]::FromArgb(235, 17, 25, 41)
	$edge = [System.Drawing.Color]::FromArgb(255, 77, 218, 245)
	Draw-RoundedRectangle $Graphics $Rect 44 (New-SolidBrush $dark) (New-Pen $black 14)
	$inner = [System.Drawing.RectangleF]::new($Rect.X + 14, $Rect.Y + 14, $Rect.Width - 28, $Rect.Height - 28)
	Draw-RoundedRectangle $Graphics $inner 32 $null (New-Pen ([System.Drawing.Color]::FromArgb(210, $edge.R, $edge.G, $edge.B)) 5)
	Draw-HighlightStripe $Graphics ([System.Drawing.RectangleF]::new($Rect.X + $Rect.Width * 0.06, $Rect.Y + $Rect.Height * 0.02, $Rect.Width * 0.56, $Rect.Height * 0.28)) $edge
}

function Draw-MenuIcon($Graphics, [string]$Kind, [int]$Size, [System.Drawing.Color]$Accent) {
	$black = [System.Drawing.Color]::FromArgb(255, 12, 14, 20)
	$dark = [System.Drawing.Color]::FromArgb(255, 22, 30, 48)
	$light = [System.Drawing.Color]::FromArgb(255, 238, 248, 255)
	$outline = New-Pen $black ($Size * 0.055)
	Draw-RoundedRectangle $Graphics ([System.Drawing.RectangleF]::new($Size * 0.08, $Size * 0.08, $Size * 0.84, $Size * 0.84)) ($Size * 0.17) (New-SolidBrush $dark) $outline
	Draw-HighlightStripe $Graphics ([System.Drawing.RectangleF]::new($Size * 0.18, $Size * 0.13, $Size * 0.54, $Size * 0.24)) $Accent
	if ($Kind -eq "play") {
		$path = New-Object System.Drawing.Drawing2D.GraphicsPath
		$path.AddPolygon(@(
			[System.Drawing.PointF]::new($Size * 0.40, $Size * 0.28),
			[System.Drawing.PointF]::new($Size * 0.40, $Size * 0.72),
			[System.Drawing.PointF]::new($Size * 0.74, $Size * 0.50)
		))
		$Graphics.FillPath((New-SolidBrush $Accent), $path)
		$Graphics.DrawPath($outline, $path)
		$path.Dispose()
	} elseif ($Kind -eq "compendium") {
		for ($i = 0; $i -lt 3; $i++) {
			$x = $Size * (0.27 + 0.16 * $i)
			Draw-RoundedRectangle $Graphics ([System.Drawing.RectangleF]::new($x, $Size * 0.30, $Size * 0.13, $Size * 0.44)) ($Size * 0.035) (New-SolidBrush $Accent) $outline
			$Graphics.DrawLine((New-Pen $light ($Size * 0.018)), $x + $Size * 0.03, $Size * 0.38, $x + $Size * 0.10, $Size * 0.38)
		}
	} elseif ($Kind -eq "quit") {
		$bolt = New-Object System.Drawing.Drawing2D.GraphicsPath
		$bolt.AddPolygon(@(
			[System.Drawing.PointF]::new($Size * 0.58, $Size * 0.22),
			[System.Drawing.PointF]::new($Size * 0.35, $Size * 0.52),
			[System.Drawing.PointF]::new($Size * 0.49, $Size * 0.52),
			[System.Drawing.PointF]::new($Size * 0.40, $Size * 0.78),
			[System.Drawing.PointF]::new($Size * 0.68, $Size * 0.43),
			[System.Drawing.PointF]::new($Size * 0.53, $Size * 0.43)
		))
		$Graphics.FillPath((New-SolidBrush $Accent), $bolt)
		$Graphics.DrawPath($outline, $bolt)
		$bolt.Dispose()
	}
	$outline.Dispose()
}

function Save-Png($Bitmap, $Graphics, [string]$Path) {
	$Graphics.Dispose()
	$Bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
	$Bitmap.Dispose()
}

function New-ScaledBitmap([string]$SourcePath, [int]$Size) {
	$source = [System.Drawing.Image]::FromFile($SourcePath)
	$bitmap = New-Object System.Drawing.Bitmap($Size, $Size, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
	$graphics = [System.Drawing.Graphics]::FromImage($bitmap)
	$graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
	$graphics.InterpolationMode = [System.Drawing.Drawing2D.InterpolationMode]::HighQualityBicubic
	$graphics.PixelOffsetMode = [System.Drawing.Drawing2D.PixelOffsetMode]::HighQuality
	$graphics.Clear([System.Drawing.Color]::Transparent)
	$graphics.DrawImage($source, 0, 0, $Size, $Size)
	$graphics.Dispose()
	$source.Dispose()
	return $bitmap
}

function Save-Ico([string]$SourcePath, [string]$Path, [int[]]$Sizes) {
	$file = [System.IO.File]::Open($Path, [System.IO.FileMode]::Create)
	$writer = New-Object System.IO.BinaryWriter($file)
	try {
		$pngPayloads = @()
		foreach ($size in $Sizes) {
			$bitmap = New-ScaledBitmap $SourcePath $size
			$stream = New-Object System.IO.MemoryStream
			$bitmap.Save($stream, [System.Drawing.Imaging.ImageFormat]::Png)
			$pngPayloads += ,@{
				Size = $size
				Bytes = $stream.ToArray()
			}
			$stream.Dispose()
			$bitmap.Dispose()
		}

		$writer.Write([UInt16]0)
		$writer.Write([UInt16]1)
		$writer.Write([UInt16]$pngPayloads.Count)
		$imageOffset = 6 + (16 * $pngPayloads.Count)
		foreach ($payload in $pngPayloads) {
			$sizeByte = if ($payload.Size -ge 256) { 0 } else { $payload.Size }
			$writer.Write([byte]$sizeByte)
			$writer.Write([byte]$sizeByte)
			$writer.Write([byte]0)
			$writer.Write([byte]0)
			$writer.Write([UInt16]1)
			$writer.Write([UInt16]32)
			$writer.Write([UInt32]$payload.Bytes.Length)
			$writer.Write([UInt32]$imageOffset)
			$imageOffset += $payload.Bytes.Length
		}
		foreach ($payload in $pngPayloads) {
			$writer.Write($payload.Bytes)
		}
	}
	finally {
		$writer.Dispose()
		$file.Dispose()
	}
}

$icon = New-Canvas 1024 1024
$iconBitmap = $icon[0]
$iconGraphics = $icon[1]
Draw-LauncherBase $iconGraphics 1024
Draw-BrandMark $iconGraphics 214 126 596
Draw-TankGlyph $iconGraphics 286 246 452
Draw-ASBadge $iconGraphics 328 774 368
Save-Png $iconBitmap $iconGraphics (Join-Path $OutDir "app_icon_1024.png")

$mark = New-Canvas 512 512
$markBitmap = $mark[0]
$markGraphics = $mark[1]
Draw-LauncherBase $markGraphics 512
Draw-BrandMark $markGraphics 100 62 312
Draw-TankGlyph $markGraphics 146 130 220
Save-Png $markBitmap $markGraphics (Join-Path $OutDir "brand_mark_autonomous_survivor.png")

foreach ($size in @(512, 256, 128, 64, 32)) {
	$scaledIcon = New-ScaledBitmap (Join-Path $OutDir "app_icon_1024.png") $size
	$scaledGraphics = [System.Drawing.Graphics]::FromImage($scaledIcon)
	Save-Png $scaledIcon $scaledGraphics (Join-Path $OutDir ("app_icon_{0}.png" -f $size))
}

$logo = New-Canvas 1536 512
$logoBitmap = $logo[0]
$logoGraphics = $logo[1]
Draw-LogoPlate $logoGraphics ([System.Drawing.RectangleF]::new(24, 28, 1488, 456))
Draw-EnergyRays $logoGraphics 260 250 280 ([System.Drawing.Color]::FromArgb(255, 255, 199, 65))
Draw-BrandMark $logoGraphics 68 62 384
Draw-TankGlyph $logoGraphics 150 150 220
Draw-ASBadge $logoGraphics 202 360 116
Draw-CenteredText $logoGraphics "AUTONOMOUS" "Arial Black" 92 ([System.Drawing.RectangleF]::new(470, 58, 998, 126)) (New-SolidBrush ([System.Drawing.Color]::FromArgb(255, 114, 234, 255))) (New-SolidBrush ([System.Drawing.Color]::FromArgb(255, 5, 8, 15))) 7
Draw-CenteredText $logoGraphics "SURVIVOR" "Arial Black" 150 ([System.Drawing.RectangleF]::new(470, 176, 998, 180)) (New-SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 216, 72))) (New-SolidBrush ([System.Drawing.Color]::FromArgb(255, 5, 8, 15))) 10
Draw-CenteredText $logoGraphics "TANK BULLET HEAVEN" "Arial Black" 42 ([System.Drawing.RectangleF]::new(480, 374, 980, 62)) (New-SolidBrush ([System.Drawing.Color]::FromArgb(255, 236, 249, 255))) (New-SolidBrush ([System.Drawing.Color]::FromArgb(255, 5, 8, 15))) 4
Save-Png $logoBitmap $logoGraphics (Join-Path $OutDir "logo_autonomous_survivor.png")

$wordmark = New-Canvas 1280 320
$wordmarkBitmap = $wordmark[0]
$wordmarkGraphics = $wordmark[1]
Draw-LogoPlate $wordmarkGraphics ([System.Drawing.RectangleF]::new(20, 26, 1240, 268))
Draw-CenteredText $wordmarkGraphics "AUTONOMOUS" "Arial Black" 76 ([System.Drawing.RectangleF]::new(44, 42, 1192, 100)) (New-SolidBrush ([System.Drawing.Color]::FromArgb(255, 116, 230, 255))) (New-SolidBrush ([System.Drawing.Color]::FromArgb(255, 16, 18, 28))) 6
Draw-CenteredText $wordmarkGraphics "SURVIVOR" "Arial Black" 120 ([System.Drawing.RectangleF]::new(44, 126, 1192, 142)) (New-SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 217, 84))) (New-SolidBrush ([System.Drawing.Color]::FromArgb(255, 16, 18, 28))) 8
Save-Png $wordmarkBitmap $wordmarkGraphics (Join-Path $OutDir "wordmark_autonomous_survivor.png")

foreach ($button in @(
	@{ Name = "icon_menu_play.png"; Kind = "play"; Accent = [System.Drawing.Color]::FromArgb(255, 88, 226, 132) },
	@{ Name = "icon_menu_compendium.png"; Kind = "compendium"; Accent = [System.Drawing.Color]::FromArgb(255, 112, 190, 255) },
	@{ Name = "icon_menu_quit.png"; Kind = "quit"; Accent = [System.Drawing.Color]::FromArgb(255, 255, 104, 104) }
)) {
	$buttonCanvas = New-Canvas 128 128
	Draw-MenuIcon $buttonCanvas[1] $button.Kind 128 $button.Accent
	Save-Png $buttonCanvas[0] $buttonCanvas[1] (Join-Path $OutDir $button.Name)
}

Save-Ico (Join-Path $OutDir "app_icon_1024.png") (Join-Path $OutDir "app_icon.ico") @(16, 24, 32, 48, 64, 128, 256)

Write-Host "Generated branding assets in $OutDir"

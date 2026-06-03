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

function Save-Png($Bitmap, $Graphics, [string]$Path) {
	$Graphics.Dispose()
	$Bitmap.Save($Path, [System.Drawing.Imaging.ImageFormat]::Png)
	$Bitmap.Dispose()
}

$icon = New-Canvas 1024 1024
$iconBitmap = $icon[0]
$iconGraphics = $icon[1]
$iconGraphics.FillEllipse((New-SolidBrush ([System.Drawing.Color]::FromArgb(255, 11, 17, 31))), 48, 48, 928, 928)
$iconGraphics.DrawEllipse((New-Pen ([System.Drawing.Color]::FromArgb(255, 12, 12, 18)) 34), 48, 48, 928, 928)
$iconGraphics.DrawEllipse((New-Pen ([System.Drawing.Color]::FromArgb(255, 72, 212, 240)) 18), 90, 90, 844, 844)
Draw-BrandMark $iconGraphics 172 118 680
Draw-CenteredText $iconGraphics "AS" "Arial" 184 ([System.Drawing.RectangleF]::new(0, 755, 1024, 180)) (New-SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 217, 84))) (New-SolidBrush ([System.Drawing.Color]::FromArgb(255, 18, 20, 28))) 8
Save-Png $iconBitmap $iconGraphics (Join-Path $OutDir "app_icon_1024.png")

$smallIcon = New-Object System.Drawing.Bitmap(256, 256, [System.Drawing.Imaging.PixelFormat]::Format32bppArgb)
$smallGraphics = [System.Drawing.Graphics]::FromImage($smallIcon)
$smallGraphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::HighQuality
$smallGraphics.DrawImage([System.Drawing.Image]::FromFile((Join-Path $OutDir "app_icon_1024.png")), 0, 0, 256, 256)
Save-Png $smallIcon $smallGraphics (Join-Path $OutDir "app_icon_256.png")

$logo = New-Canvas 1536 512
$logoBitmap = $logo[0]
$logoGraphics = $logo[1]
Draw-BrandMark $logoGraphics 44 56 400
Draw-CenteredText $logoGraphics "AUTONOMOUS" "Arial" 118 ([System.Drawing.RectangleF]::new(430, 56, 1040, 160)) (New-SolidBrush ([System.Drawing.Color]::FromArgb(255, 116, 230, 255))) (New-SolidBrush ([System.Drawing.Color]::FromArgb(255, 16, 18, 28))) 7
Draw-CenteredText $logoGraphics "SURVIVOR" "Arial" 150 ([System.Drawing.RectangleF]::new(430, 194, 1040, 196)) (New-SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 217, 84))) (New-SolidBrush ([System.Drawing.Color]::FromArgb(255, 16, 18, 28))) 9
Draw-CenteredText $logoGraphics "TANK BULLET HEAVEN" "Arial" 44 ([System.Drawing.RectangleF]::new(432, 380, 1038, 70)) (New-SolidBrush ([System.Drawing.Color]::FromArgb(255, 226, 244, 255))) (New-SolidBrush ([System.Drawing.Color]::FromArgb(255, 16, 18, 28))) 3
Save-Png $logoBitmap $logoGraphics (Join-Path $OutDir "logo_autonomous_survivor.png")

$wordmark = New-Canvas 1280 320
$wordmarkBitmap = $wordmark[0]
$wordmarkGraphics = $wordmark[1]
Draw-CenteredText $wordmarkGraphics "AUTONOMOUS" "Arial" 82 ([System.Drawing.RectangleF]::new(0, 24, 1280, 106)) (New-SolidBrush ([System.Drawing.Color]::FromArgb(255, 116, 230, 255))) (New-SolidBrush ([System.Drawing.Color]::FromArgb(255, 16, 18, 28))) 6
Draw-CenteredText $wordmarkGraphics "SURVIVOR" "Arial" 128 ([System.Drawing.RectangleF]::new(0, 116, 1280, 160)) (New-SolidBrush ([System.Drawing.Color]::FromArgb(255, 255, 217, 84))) (New-SolidBrush ([System.Drawing.Color]::FromArgb(255, 16, 18, 28))) 8
Save-Png $wordmarkBitmap $wordmarkGraphics (Join-Path $OutDir "wordmark_autonomous_survivor.png")

Write-Host "Generated branding assets in $OutDir"

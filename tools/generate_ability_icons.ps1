param(
	[string]$OutputDir = "assets/ui/icons/abilities"
)

Add-Type -AssemblyName System.Drawing

$root = Resolve-Path "."
$target = Join-Path $root $OutputDir
New-Item -ItemType Directory -Force -Path $target | Out-Null

$abilities = @(
	@{ id="landmine"; rarity="Common"; motif="mine" },
	@{ id="circular_saw"; rarity="Common"; motif="saw" },
	@{ id="footsoldier"; rarity="Uncommon"; motif="soldier" },
	@{ id="shock_field"; rarity="Uncommon"; motif="shock" },
	@{ id="artillery"; rarity="Rare"; motif="target" },
	@{ id="drone_swarm"; rarity="Uncommon"; motif="drone" },
	@{ id="oil_slick"; rarity="Common"; motif="oil" },
	@{ id="freeze_pulse"; rarity="Rare"; motif="snow" },
	@{ id="chain_lightning"; rarity="Rare"; motif="bolt" },
	@{ id="guardian_satellite"; rarity="Uncommon"; motif="satellite" },
	@{ id="overdrive_core"; rarity="Rare"; motif="engine" },
	@{ id="flame_wave"; rarity="Uncommon"; motif="flame" },
	@{ id="repair_beacon"; rarity="Uncommon"; motif="cross" },
	@{ id="missile_pod"; rarity="Uncommon"; motif="missile" },
	@{ id="gravity_well"; rarity="Rare"; motif="gravity" },
	@{ id="railgun_orbiter"; rarity="Rare"; motif="rail" },
	@{ id="tesla_pylon"; rarity="Rare"; motif="pylon" },
	@{ id="nanite_cloud"; rarity="Uncommon"; motif="cloud" },
	@{ id="ricochet_rounds"; rarity="Rare"; motif="ricochet" },
	@{ id="chrono_burst"; rarity="Rare"; motif="clock" }
)

$rarityColors = @{
	Common = [System.Drawing.Color]::FromArgb(255, 56, 136, 190)
	Uncommon = [System.Drawing.Color]::FromArgb(255, 48, 178, 230)
	Rare = [System.Drawing.Color]::FromArgb(255, 88, 112, 255)
	Epic = [System.Drawing.Color]::FromArgb(255, 170, 90, 255)
}

function Brush([System.Drawing.Color]$Color) { New-Object System.Drawing.SolidBrush($Color) }
function Pen([System.Drawing.Color]$Color, [float]$Width) {
	$pen = New-Object System.Drawing.Pen($Color, $Width)
	$pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
	$pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
	$pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
	return $pen
}

function Draw-Motif($g, [string]$motif) {
	$black = Pen ([System.Drawing.Color]::Black) 6
	$white = Pen ([System.Drawing.Color]::White) 3
	$fill = Brush ([System.Drawing.Color]::FromArgb(245, 255, 255, 255))
	switch ($motif) {
		"mine" { $g.FillEllipse($fill,18,22,28,24); $g.DrawEllipse($black,18,22,28,24); for($i=0;$i -lt 6;$i++){ $a=$i*60*[Math]::PI/180; $g.DrawLine($black,32+[Math]::Cos($a)*11,34+[Math]::Sin($a)*10,32+[Math]::Cos($a)*20,34+[Math]::Sin($a)*18) } }
		"saw" { $pts=@(); for($i=0;$i -lt 16;$i++){ $a=$i*22.5*[Math]::PI/180; $r= if($i%2 -eq 0){23}else{15}; $pts += [System.Drawing.Point]::new([int](32+[Math]::Cos($a)*$r),[int](32+[Math]::Sin($a)*$r)) }; $g.FillPolygon($fill,$pts); $g.DrawPolygon($black,$pts); $g.DrawEllipse($black,25,25,14,14) }
		"soldier" { $g.FillEllipse($fill,25,12,14,14); $g.DrawEllipse($black,25,12,14,14); $g.DrawRectangle($black,22,28,20,22); $g.DrawLine($white,26,34,38,34) }
		"shock" { for($i=0;$i -lt 3;$i++){ $x=20+$i*8; $g.DrawLine($black,$x,14,$x+9,31); $g.DrawLine($black,$x+9,31,$x+2,50); $g.DrawLine($white,$x+2,17,$x+9,31) } }
		"target" { $g.DrawEllipse($black,14,14,36,36); $g.DrawEllipse($white,20,20,24,24); $g.DrawLine($black,32,9,32,55); $g.DrawLine($black,9,32,55,32) }
		"drone" { $g.FillEllipse($fill,25,25,14,14); $g.DrawEllipse($black,25,25,14,14); $g.DrawEllipse($black,13,13,14,14); $g.DrawEllipse($black,37,13,14,14); $g.DrawEllipse($black,13,37,14,14); $g.DrawEllipse($black,37,37,14,14) }
		"oil" { $pts=@([System.Drawing.Point]::new(31,12),[System.Drawing.Point]::new(45,31),[System.Drawing.Point]::new(38,49),[System.Drawing.Point]::new(21,47),[System.Drawing.Point]::new(17,30)); $g.FillPolygon($fill,$pts); $g.DrawPolygon($black,$pts); $g.DrawLine($white,28,20,23,38) }
		"snow" { $g.DrawLine($black,32,13,32,51); $g.DrawLine($black,16,22,48,42); $g.DrawLine($black,48,22,16,42); $g.DrawLine($white,32,16,32,48) }
		"bolt" { $pts=@([System.Drawing.Point]::new(36,10),[System.Drawing.Point]::new(20,35),[System.Drawing.Point]::new(32,35),[System.Drawing.Point]::new(27,54),[System.Drawing.Point]::new(46,27),[System.Drawing.Point]::new(34,27)); $g.FillPolygon($fill,$pts); $g.DrawPolygon($black,$pts) }
		"satellite" { $g.DrawEllipse($black,24,24,16,16); $g.DrawRectangle($black,11,25,12,14); $g.DrawRectangle($black,41,25,12,14); $g.DrawLine($white,18,32,46,32) }
		"engine" { $g.DrawRectangle($black,18,18,28,28); $g.DrawEllipse($white,24,24,16,16); $g.DrawLine($black,32,10,32,18); $g.DrawLine($black,32,46,32,54) }
		"flame" { $pts=@([System.Drawing.Point]::new(33,11),[System.Drawing.Point]::new(47,36),[System.Drawing.Point]::new(32,52),[System.Drawing.Point]::new(18,38),[System.Drawing.Point]::new(27,28)); $g.FillPolygon($fill,$pts); $g.DrawPolygon($black,$pts) }
		"cross" { $g.FillRectangle($fill,27,14,10,36); $g.FillRectangle($fill,14,27,36,10); $g.DrawRectangle($black,27,14,10,36); $g.DrawRectangle($black,14,27,36,10) }
		"missile" { $pts=@([System.Drawing.Point]::new(32,12),[System.Drawing.Point]::new(44,34),[System.Drawing.Point]::new(36,50),[System.Drawing.Point]::new(28,50),[System.Drawing.Point]::new(20,34)); $g.FillPolygon($fill,$pts); $g.DrawPolygon($black,$pts) }
		"gravity" { $g.DrawEllipse($black,15,15,34,34); $g.FillEllipse($fill,25,25,14,14); $g.DrawEllipse($black,25,25,14,14); $g.DrawArc($white,19,12,26,40,35,290) }
		"rail" { $g.DrawLine($black,14,24,50,24); $g.DrawLine($black,14,40,50,40); $g.DrawLine($white,18,24,46,40); $g.DrawLine($white,18,40,46,24) }
		"pylon" { $g.DrawLine($black,32,12,20,52); $g.DrawLine($black,32,12,44,52); $g.DrawLine($black,24,38,40,38); $g.DrawLine($white,32,18,27,38) }
		"cloud" { $g.FillEllipse($fill,15,28,20,16); $g.FillEllipse($fill,27,20,22,22); $g.FillEllipse($fill,36,30,14,14); $g.DrawEllipse($black,15,28,20,16); $g.DrawEllipse($black,27,20,22,22); $g.DrawEllipse($black,36,30,14,14) }
		"ricochet" { $g.DrawLine($black,14,44,34,24); $g.DrawLine($black,34,24,49,35); $g.DrawLine($white,17,42,34,25); $g.DrawLine($black,43,27,49,35); $g.DrawLine($black,40,39,49,35) }
		"clock" { $g.DrawEllipse($black,15,15,34,34); $g.DrawLine($black,32,32,32,20); $g.DrawLine($black,32,32,43,38); $g.DrawEllipse($white,20,20,24,24) }
	}
	$black.Dispose(); $white.Dispose(); $fill.Dispose()
}

foreach ($ability in $abilities) {
	$bitmap = New-Object System.Drawing.Bitmap(64, 64)
	$g = [System.Drawing.Graphics]::FromImage($bitmap)
	$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
	$g.Clear([System.Drawing.Color]::Transparent)
	$base = $rarityColors[$ability.rarity]
	$dark = [System.Drawing.Color]::FromArgb(255, [Math]::Max(0, $base.R - 72), [Math]::Max(0, $base.G - 72), [Math]::Max(0, $base.B - 72))
	$g.FillRectangle((Brush ([System.Drawing.Color]::Black)), 5, 5, 54, 54)
	$g.FillRectangle((Brush $dark), 8, 8, 48, 48)
	$g.FillEllipse((Brush $base), 8, 6, 48, 48)
	Draw-Motif $g $ability.motif
	$out = Join-Path $target ("icon_ability_{0}.png" -f $ability.id)
	$bitmap.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
	$g.Dispose()
	$bitmap.Dispose()
}

Write-Host "Generated $($abilities.Count) ability icons in $target"

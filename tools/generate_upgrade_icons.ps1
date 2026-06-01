param(
	[string]$OutputDir = "assets/ui/icons/upgrades"
)

Add-Type -AssemblyName System.Drawing

$root = Resolve-Path "."
$target = Join-Path $root $OutputDir
New-Item -ItemType Directory -Force -Path $target | Out-Null

$upgrades = @(
	@{ id="speed"; tag="mobility"; motif="arrow" },
	@{ id="fire_rate"; tag="weapon"; motif="burst" },
	@{ id="damage"; tag="power"; motif="blast" },
	@{ id="regeneration"; tag="sustain"; motif="heart" },
	@{ id="exp"; tag="economy"; motif="crystal" },
	@{ id="splash"; tag="area"; motif="rings" },
	@{ id="piercing"; tag="clear"; motif="pierce" },
	@{ id="barbed_wire"; tag="contact"; motif="wire" },
	@{ id="armor"; tag="defense"; motif="shield" },
	@{ id="magnet"; tag="economy"; motif="magnet" },
	@{ id="cannon"; tag="multishot"; motif="cannon" },
	@{ id="targeting_array"; tag="precision"; motif="target" },
	@{ id="accelerator"; tag="mobility"; motif="arrow" },
	@{ id="alloy_plating"; tag="defense"; motif="shield" },
	@{ id="recycler"; tag="economy"; motif="cycle" },
	@{ id="payload_rack"; tag="area"; motif="crate" },
	@{ id="reactive_shield"; tag="defense"; motif="shield" },
	@{ id="gyro_stabilizer"; tag="control"; motif="gyro" },
	@{ id="rapid_loader"; tag="weapon"; motif="burst" },
	@{ id="high_caliber"; tag="power"; motif="cannon" },
	@{ id="nanobots"; tag="sustain"; motif="cross" },
	@{ id="kinetic_treads"; tag="mobility"; motif="tread" },
	@{ id="ammo_synthesizer"; tag="multishot"; motif="bullets" },
	@{ id="shatter_rounds"; tag="area"; motif="shatter" },
	@{ id="phase_core"; tag="clear"; motif="diamond" },
	@{ id="capacitor_bank"; tag="power"; motif="bolt" },
	@{ id="salvage_magnet"; tag="economy"; motif="magnet" },
	@{ id="emergency_repairs"; tag="sustain"; motif="cross" },
	@{ id="combustion_mix"; tag="area"; motif="flame" },
	@{ id="heat_sinks"; tag="tempo"; motif="cool" },
	@{ id="overclocked_barrel"; tag="weapon"; motif="cannon" },
	@{ id="rail_stabilizer"; tag="precision"; motif="rail" },
	@{ id="missile_guidance"; tag="area"; motif="missile" },
	@{ id="ordnance_bay"; tag="area"; motif="crate" },
	@{ id="field_amplifier"; tag="aura"; motif="rings" },
	@{ id="volt_coils"; tag="power"; motif="bolt" },
	@{ id="gravity_anchor"; tag="control"; motif="anchor" },
	@{ id="repair_drones"; tag="sustain"; motif="drone" },
	@{ id="crystal_lens"; tag="economy"; motif="crystal" },
	@{ id="munition_printer"; tag="multishot"; motif="bullets" },
	@{ id="stabilized_chassis"; tag="defense"; motif="tread" },
	@{ id="vector_thrusters"; tag="mobility"; motif="arrow" },
	@{ id="impact_fuse"; tag="area"; motif="blast" },
	@{ id="armor_piercers"; tag="clear"; motif="pierce" },
	@{ id="weakpoint_scanner"; tag="precision"; motif="target" },
	@{ id="med_pump"; tag="sustain"; motif="heart" },
	@{ id="orbit_gears"; tag="contact"; motif="gear" },
	@{ id="mine_dispenser"; tag="device"; motif="mine" },
	@{ id="drone_command"; tag="pet"; motif="drone" },
	@{ id="lucky_core"; tag="luck"; motif="star" }
)

$palette = @{
	mobility  = [System.Drawing.Color]::FromArgb(255, 54, 205, 255)
	weapon    = [System.Drawing.Color]::FromArgb(255, 255, 138, 38)
	power     = [System.Drawing.Color]::FromArgb(255, 255, 70, 84)
	sustain   = [System.Drawing.Color]::FromArgb(255, 74, 226, 118)
	economy   = [System.Drawing.Color]::FromArgb(255, 115, 255, 175)
	area      = [System.Drawing.Color]::FromArgb(255, 255, 214, 56)
	clear     = [System.Drawing.Color]::FromArgb(255, 157, 117, 255)
	contact   = [System.Drawing.Color]::FromArgb(255, 226, 96, 190)
	defense   = [System.Drawing.Color]::FromArgb(255, 88, 150, 255)
	multishot = [System.Drawing.Color]::FromArgb(255, 255, 176, 78)
	precision = [System.Drawing.Color]::FromArgb(255, 255, 89, 161)
	control   = [System.Drawing.Color]::FromArgb(255, 116, 224, 224)
	tempo     = [System.Drawing.Color]::FromArgb(255, 134, 238, 255)
	aura      = [System.Drawing.Color]::FromArgb(255, 186, 120, 255)
	device    = [System.Drawing.Color]::FromArgb(255, 235, 172, 84)
	pet       = [System.Drawing.Color]::FromArgb(255, 118, 236, 116)
	luck      = [System.Drawing.Color]::FromArgb(255, 255, 236, 86)
}

function Brush([System.Drawing.Color]$Color) { New-Object System.Drawing.SolidBrush($Color) }
function Pen([System.Drawing.Color]$Color, [float]$Width) {
	$pen = New-Object System.Drawing.Pen($Color, $Width)
	$pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
	$pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round
	$pen.LineJoin = [System.Drawing.Drawing2D.LineJoin]::Round
	return $pen
}

function Add-PlusBadge($g) {
	$black = Pen ([System.Drawing.Color]::Black) 4
	$green = Pen ([System.Drawing.Color]::FromArgb(255, 77, 255, 104)) 3
	$g.DrawEllipse($black, 42, 42, 17, 17)
	$g.FillEllipse((Brush ([System.Drawing.Color]::FromArgb(255, 26, 130, 45))), 42, 42, 17, 17)
	$g.DrawLine($black, 50, 45, 50, 56)
	$g.DrawLine($black, 45, 50, 56, 50)
	$g.DrawLine($green, 50, 45, 50, 56)
	$g.DrawLine($green, 45, 50, 56, 50)
	$black.Dispose(); $green.Dispose()
}

function Draw-Motif($g, [string]$motif, [int]$seed) {
	$black = Pen ([System.Drawing.Color]::Black) 6
	$white = Pen ([System.Drawing.Color]::White) 3
	$fill = Brush ([System.Drawing.Color]::FromArgb(245, 255, 255, 255))
	switch ($motif) {
		"arrow" { $pts = @([System.Drawing.Point]::new(16,34),[System.Drawing.Point]::new(36,14),[System.Drawing.Point]::new(48,26),[System.Drawing.Point]::new(37,26),[System.Drawing.Point]::new(28,48)); $g.FillPolygon($fill,$pts); $g.DrawPolygon($black,$pts) }
		"burst" { for($i=0;$i -lt 6;$i++){ $a=($i*60+$seed%30)*[Math]::PI/180; $g.DrawLine($black,32,32,32+[Math]::Cos($a)*18,32+[Math]::Sin($a)*18); $g.DrawLine($white,32,32,32+[Math]::Cos($a)*18,32+[Math]::Sin($a)*18) } }
		"blast" { $g.FillEllipse($fill,18,18,28,28); $g.DrawEllipse($black,18,18,28,28); $g.DrawEllipse($white,22,22,20,20) }
		"heart" { $g.FillEllipse($fill,18,20,15,15); $g.FillEllipse($fill,31,20,15,15); $pts=@([System.Drawing.Point]::new(18,29),[System.Drawing.Point]::new(46,29),[System.Drawing.Point]::new(32,49)); $g.FillPolygon($fill,$pts); $g.DrawEllipse($black,18,20,15,15); $g.DrawEllipse($black,31,20,15,15); $g.DrawPolygon($black,$pts) }
		"crystal" { $pts=@([System.Drawing.Point]::new(32,12),[System.Drawing.Point]::new(47,29),[System.Drawing.Point]::new(39,51),[System.Drawing.Point]::new(25,51),[System.Drawing.Point]::new(17,29)); $g.FillPolygon($fill,$pts); $g.DrawPolygon($black,$pts); $g.DrawLine($white,32,15,25,48); $g.DrawLine($white,32,15,39,48) }
		"rings" { $g.DrawEllipse($black,15,15,34,34); $g.DrawEllipse($white,19,19,26,26); $g.DrawEllipse($black,26,26,12,12) }
		"pierce" { $g.DrawLine($black,16,48,48,16); $g.DrawLine($white,19,45,45,19); $g.DrawLine($black,35,16,48,16); $g.DrawLine($black,48,16,48,29) }
		"wire" { for($i=0;$i -lt 3;$i++){ $x=18+$i*12; $g.DrawLine($black,$x,16,$x+10,48); $g.DrawLine($white,$x,16,$x+10,48) } }
		"shield" { $pts=@([System.Drawing.Point]::new(32,12),[System.Drawing.Point]::new(48,20),[System.Drawing.Point]::new(44,42),[System.Drawing.Point]::new(32,52),[System.Drawing.Point]::new(20,42),[System.Drawing.Point]::new(16,20)); $g.FillPolygon($fill,$pts); $g.DrawPolygon($black,$pts) }
		"magnet" { $g.DrawArc($black,17,14,30,34,20,320); $g.DrawArc($white,20,17,24,28,20,320); $g.DrawLine($black,16,36,24,36); $g.DrawLine($black,40,36,48,36) }
		"cannon" { $g.DrawLine($black,18,40,44,24); $g.DrawLine($white,20,39,42,25); $g.FillEllipse($fill,14,36,14,14); $g.DrawEllipse($black,14,36,14,14) }
		"target" { $g.DrawEllipse($black,15,15,34,34); $g.DrawLine($black,32,10,32,54); $g.DrawLine($black,10,32,54,32); $g.DrawEllipse($white,24,24,16,16) }
		"cycle" { $g.DrawArc($black,16,16,32,32,35,245); $g.DrawArc($white,19,19,26,26,35,245); $g.DrawLine($black,42,16,49,20); $g.DrawLine($black,42,16,40,25) }
		"crate" { $g.FillRectangle($fill,18,20,28,28); $g.DrawRectangle($black,18,20,28,28); $g.DrawLine($black,18,32,46,32); $g.DrawLine($white,23,25,41,43) }
		"gyro" { $g.DrawEllipse($black,14,23,36,18); $g.DrawEllipse($black,23,14,18,36); $g.FillEllipse($fill,26,26,12,12); $g.DrawEllipse($black,26,26,12,12) }
		"cross" { $g.FillRectangle($fill,27,14,10,36); $g.FillRectangle($fill,14,27,36,10); $g.DrawRectangle($black,27,14,10,36); $g.DrawRectangle($black,14,27,36,10) }
		"tread" { $g.DrawRectangle($black,16,22,32,20); $g.DrawLine($white,20,32,44,32); for($i=0;$i -lt 4;$i++){ $g.DrawLine($black,20+$i*8,24,16+$i*8,40) } }
		"bullets" { for($i=0;$i -lt 3;$i++){ $x=19+$i*10; $g.FillEllipse($fill,$x,15,8,10); $g.FillRectangle($fill,$x,20,8,26); $g.DrawEllipse($black,$x,15,8,10); $g.DrawRectangle($black,$x,20,8,26) } }
		"shatter" { $pts=@([System.Drawing.Point]::new(32,12),[System.Drawing.Point]::new(41,30),[System.Drawing.Point]::new(34,50),[System.Drawing.Point]::new(21,36)); $g.FillPolygon($fill,$pts); $g.DrawPolygon($black,$pts); $g.DrawLine($black,31,14,34,48); $g.DrawLine($white,24,35,39,30) }
		"diamond" { $pts=@([System.Drawing.Point]::new(32,12),[System.Drawing.Point]::new(50,32),[System.Drawing.Point]::new(32,52),[System.Drawing.Point]::new(14,32)); $g.FillPolygon($fill,$pts); $g.DrawPolygon($black,$pts) }
		"bolt" { $pts=@([System.Drawing.Point]::new(36,10),[System.Drawing.Point]::new(20,35),[System.Drawing.Point]::new(32,35),[System.Drawing.Point]::new(27,54),[System.Drawing.Point]::new(46,27),[System.Drawing.Point]::new(34,27)); $g.FillPolygon($fill,$pts); $g.DrawPolygon($black,$pts) }
		"flame" { $pts=@([System.Drawing.Point]::new(33,11),[System.Drawing.Point]::new(47,36),[System.Drawing.Point]::new(32,52),[System.Drawing.Point]::new(18,38),[System.Drawing.Point]::new(27,28)); $g.FillPolygon($fill,$pts); $g.DrawPolygon($black,$pts) }
		"cool" { $g.DrawLine($black,32,14,32,50); $g.DrawLine($black,17,23,47,41); $g.DrawLine($black,47,23,17,41); $g.DrawLine($white,32,16,32,48) }
		"rail" { $g.DrawLine($black,16,24,48,24); $g.DrawLine($black,16,40,48,40); $g.DrawLine($white,20,24,44,40); $g.DrawLine($white,20,40,44,24) }
		"missile" { $pts=@([System.Drawing.Point]::new(32,12),[System.Drawing.Point]::new(44,34),[System.Drawing.Point]::new(36,50),[System.Drawing.Point]::new(28,50),[System.Drawing.Point]::new(20,34)); $g.FillPolygon($fill,$pts); $g.DrawPolygon($black,$pts) }
		"anchor" { $g.DrawLine($black,32,14,32,46); $g.DrawEllipse($black,27,12,10,10); $g.DrawArc($black,18,30,28,22,0,180); $g.DrawLine($white,32,23,32,43) }
		"drone" { $g.FillEllipse($fill,25,25,14,14); $g.DrawEllipse($black,25,25,14,14); $g.DrawEllipse($black,13,13,14,14); $g.DrawEllipse($black,37,13,14,14); $g.DrawEllipse($black,13,37,14,14); $g.DrawEllipse($black,37,37,14,14) }
		"gear" { for($i=0;$i -lt 8;$i++){ $a=$i*45*[Math]::PI/180; $g.DrawLine($black,32+[Math]::Cos($a)*12,32+[Math]::Sin($a)*12,32+[Math]::Cos($a)*20,32+[Math]::Sin($a)*20) }; $g.DrawEllipse($black,18,18,28,28); $g.DrawEllipse($white,25,25,14,14) }
		"mine" { $g.FillEllipse($fill,18,22,28,24); $g.DrawEllipse($black,18,22,28,24); for($i=0;$i -lt 6;$i++){ $a=$i*60*[Math]::PI/180; $g.DrawLine($black,32+[Math]::Cos($a)*11,34+[Math]::Sin($a)*10,32+[Math]::Cos($a)*20,34+[Math]::Sin($a)*18) } }
		"star" { $pts=@(); for($i=0;$i -lt 10;$i++){ $a=(-90+$i*36)*[Math]::PI/180; $r= if($i%2 -eq 0){21}else{9}; $pts += [System.Drawing.Point]::new([int](32+[Math]::Cos($a)*$r),[int](32+[Math]::Sin($a)*$r)) }; $g.FillPolygon($fill,$pts); $g.DrawPolygon($black,$pts) }
	}
	$black.Dispose(); $white.Dispose(); $fill.Dispose()
}

foreach ($upgrade in $upgrades) {
	$bitmap = New-Object System.Drawing.Bitmap(64, 64)
	$g = [System.Drawing.Graphics]::FromImage($bitmap)
	$g.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
	$g.Clear([System.Drawing.Color]::Transparent)
	$base = $palette[$upgrade.tag]
	$shadow = [System.Drawing.Color]::FromArgb(255, [Math]::Max(0, $base.R - 65), [Math]::Max(0, $base.G - 65), [Math]::Max(0, $base.B - 65))
	$g.FillEllipse((Brush ([System.Drawing.Color]::Black)), 5, 5, 54, 54)
	$g.FillEllipse((Brush $shadow), 8, 8, 48, 48)
	$g.FillEllipse((Brush $base), 8, 6, 48, 48)
	$seed = [Math]::Abs($upgrade.id.GetHashCode())
	Draw-Motif $g $upgrade.motif $seed
	$pipBrush = Brush ([System.Drawing.Color]::FromArgb(255, 20, 20, 20))
	for ($i = 0; $i -lt 3; $i++) {
		if (($seed -band (1 -shl $i)) -ne 0) {
			$g.FillEllipse($pipBrush, 12 + ($i * 7), 50, 4, 4)
		}
	}
	$pipBrush.Dispose()
	Add-PlusBadge $g
	$out = Join-Path $target ("icon_upgrade_{0}.png" -f $upgrade.id)
	$bitmap.Save($out, [System.Drawing.Imaging.ImageFormat]::Png)
	$g.Dispose()
	$bitmap.Dispose()
}

Write-Host "Generated $($upgrades.Count) standardized upgrade icons in $target"

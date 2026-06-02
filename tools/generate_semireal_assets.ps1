$ErrorActionPreference = "Stop"

$source = @"
using System;
using System.IO;
using System.Linq;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;
using System.Collections.Generic;

public static class SemiRealAssetGenerator {
    static readonly Random Rng = new Random(42);

    public static void Generate(string root) {
        Directory.SetCurrentDirectory(root);
        EnsureIcons("assets/ui/icons/upgrades", "icon_upgrade_", new string[] {
            "thermal_jacket", "shrapnel_matrix", "hollow_point_feed", "engine_supercharger", "field_siphon",
            "orbital_prism", "nano_plating", "kinetic_scoop", "capacitor_mesh", "drone_uplink",
            "blast_retainer", "mender_tracks", "lucky_shrapnel", "gravity_fins", "reinforced_ammo_belt",
            "crystal_reservoir", "storm_insulator", "target_predictor", "emergency_battery", "singularity_lens"
        });
        EnsureIcons("assets/ui/icons/abilities", "icon_ability_", new string[] {
            "phase_magnet", "munition_swarm", "fortress_protocol", "storm_catalyst", "golden_reactor"
        });
        foreach (var path in Directory.GetFiles("assets/ui/icons/upgrades", "*.png")) DrawIcon(path, false);
        foreach (var path in Directory.GetFiles("assets/ui/icons/abilities", "*.png")) DrawIcon(path, true);

        DrawGameplayAbility("assets/abilities/circular_saw.png", "saw");
        DrawGameplayAbility("assets/abilities/footsoldier.png", "soldier");
        DrawGameplayAbility("assets/abilities/landmine.png", "mine");

        DrawPickup("assets/pickups/wrench.png", "wrench");
        DrawPickup("assets/pickups/magnet_pickup_sprite.png", "magnet");
        DrawPickup("assets/pickups/dynamite_pickup_sprite.png", "dynamite");
        DrawSupply("assets/pickups/supply_box_green.png", Color.FromArgb(80, 210, 115));
        DrawSupply("assets/pickups/supply_box_blue.png", Color.FromArgb(75, 155, 235));

        DrawCrystal("assets/exp/exp_crystal_green.png", Color.FromArgb(80, 240, 135));
        DrawCrystal("assets/exp/exp_crystal_blue.png", Color.FromArgb(75, 170, 255));
        DrawCrystal("assets/exp/exp_crystal_red.png", Color.FromArgb(255, 90, 80));
        DrawCrystal("assets/exp/exp_crystal_purple.png", Color.FromArgb(195, 95, 255));

        DrawProjectile("assets/projectiles/tank_projectile.png", Color.FromArgb(255, 205, 70), true);
        DrawProjectile("assets/projectiles/soldier_projectile.png", Color.FromArgb(110, 230, 255), false);

        DrawTankBase("assets/visual/player/tank_base_cartoon.png");
        DrawTankCannon("assets/visual/player/tank_cannon_cartoon.png");
        DrawTankSheet("assets/player/tank_sheet.png");

        DrawEnemy("assets/visual/enemies/enemy_scout_cartoon.png", "scout");
        DrawEnemy("assets/visual/enemies/enemy_bruiser_cartoon.png", "bruiser");
        DrawEnemy("assets/visual/enemies/enemy_shield_cartoon.png", "shield");
        DrawEnemy("assets/visual/enemies/boss_core_cartoon.png", "boss");
        foreach (var path in Directory.GetFiles("assets/visual/enemies/variants", "*.png")) {
            DrawEnemy(path, Path.GetFileNameWithoutExtension(path).Replace("enemy_", "").Replace("_cartoon", ""));
        }

        DrawEffect("assets/visual/effects/impact_starburst.png");
        DrawRadialLight("assets/visual/effects/radial_player_light.png");
        DrawPanel("assets/visual/ui/chunky_panel.png", 96, 96);
        DrawPanel("assets/ui/panels/menu_panel_nine_patch.png", 512, 512);
        DrawBackground("assets/backgrounds/wasteland_arena_generated.png", false);
        DrawBackground("assets/backgrounds/menu_backdrop_generated.png", true);
        DrawCloud("assets/backgrounds/cloud_shadow_large.png", 640, 320, 8);
        DrawCloud("assets/backgrounds/cloud_shadow_small.png", 420, 220, 5);
    }

    static Bitmap NewBmp(int w, int h, bool transparent=true) {
        var bmp = new Bitmap(w, h, PixelFormat.Format32bppArgb);
        using (var g = Graphics.FromImage(bmp)) {
            g.Clear(transparent ? Color.Transparent : Color.FromArgb(18, 22, 24));
        }
        return bmp;
    }

    static void EnsureIcons(string directory, string prefix, string[] ids) {
        Directory.CreateDirectory(directory);
        foreach (var id in ids) {
            var path = Path.Combine(directory, prefix + id + ".png");
            if (File.Exists(path)) continue;
            Save(NewBmp(128, 128), path);
        }
    }

    static Size GetSize(string path) {
        using (var img = Image.FromFile(path)) return new Size(img.Width, img.Height);
    }

    static Graphics G(Bitmap bmp) {
        var g = Graphics.FromImage(bmp);
        g.SmoothingMode = SmoothingMode.AntiAlias;
        g.InterpolationMode = InterpolationMode.HighQualityBicubic;
        g.PixelOffsetMode = PixelOffsetMode.HighQuality;
        return g;
    }

    static void Save(Bitmap bmp, string path) {
        var tmp = path + ".tmp";
        bmp.Save(tmp, ImageFormat.Png);
        bmp.Dispose();
        if (File.Exists(path)) File.Delete(path);
        File.Move(tmp, path);
    }

    static Color Mix(Color a, Color b, float t) {
        return Color.FromArgb(
            (int)(a.A + (b.A - a.A) * t),
            (int)(a.R + (b.R - a.R) * t),
            (int)(a.G + (b.G - a.G) * t),
            (int)(a.B + (b.B - a.B) * t));
    }

    static Color HueColor(int hash, int sat=170, int val=220) {
        float h = Math.Abs(hash % 360) / 60f;
        int i = (int)Math.Floor(h);
        float f = h - i;
        float p = val * (1f - sat / 255f);
        float q = val * (1f - f * sat / 255f);
        float t = val * (1f - (1f - f) * sat / 255f);
        float r=0,g=0,b=0;
        switch (i % 6) {
            case 0: r=val; g=t; b=p; break;
            case 1: r=q; g=val; b=p; break;
            case 2: r=p; g=val; b=t; break;
            case 3: r=p; g=q; b=val; break;
            case 4: r=t; g=p; b=val; break;
            case 5: r=val; g=p; b=q; break;
        }
        return Color.FromArgb((int)r,(int)g,(int)b);
    }

    static GraphicsPath RoundRect(float x, float y, float w, float h, float r) {
        var p = new GraphicsPath();
        float d = r * 2f;
        p.AddArc(x, y, d, d, 180, 90);
        p.AddArc(x + w - d, y, d, d, 270, 90);
        p.AddArc(x + w - d, y + h - d, d, d, 0, 90);
        p.AddArc(x, y + h - d, d, d, 90, 90);
        p.CloseFigure();
        return p;
    }

    static void FillBevel(Graphics g, RectangleF r, Color baseColor, float radius) {
        using (var shadow = RoundRect(r.X+4, r.Y+6, r.Width, r.Height, radius))
        using (var sb = new SolidBrush(Color.FromArgb(85, 0, 0, 0))) g.FillPath(sb, shadow);
        using (var path = RoundRect(r.X, r.Y, r.Width, r.Height, radius))
        using (var brush = new LinearGradientBrush(r, Mix(baseColor, Color.White, 0.34f), Mix(baseColor, Color.Black, 0.46f), 55f))
        using (var pen = new Pen(Color.FromArgb(235, 18, 20, 24), Math.Max(3f, r.Width * 0.025f))) {
            g.FillPath(brush, path);
            g.DrawPath(pen, path);
        }
        using (var path = RoundRect(r.X+7, r.Y+7, r.Width-14, r.Height-14, radius*0.65f))
        using (var pen = new Pen(Color.FromArgb(95, 255, 255, 255), Math.Max(1f, r.Width * 0.01f))) g.DrawPath(pen, path);
    }

    static void DrawIcon(string path, bool ability) {
        var size = GetSize(path);
        var id = Path.GetFileNameWithoutExtension(path).Replace("icon_upgrade_", "").Replace("icon_ability_", "");
        var bmp = NewBmp(size.Width, size.Height);
        using (var g = G(bmp)) {
            var accent = ability ? HueColor(id.GetHashCode()+120, 150, 235) : HueColor(id.GetHashCode(), 135, 220);
            var baseColor = ability ? Color.FromArgb(32, 48, 74) : Color.FromArgb(64, 70, 74);
            var r = new RectangleF(7, 7, size.Width-14, size.Height-14);
            FillBevel(g, r, baseColor, 22);
            using (var glow = new SolidBrush(Color.FromArgb(55, accent))) g.FillEllipse(glow, size.Width*.18f, size.Height*.18f, size.Width*.64f, size.Height*.64f);
            using (var pen = new Pen(accent, 6f)) g.DrawEllipse(pen, size.Width*.18f, size.Height*.18f, size.Width*.64f, size.Height*.64f);
            DrawMotif(g, id, accent, size.Width, size.Height, ability);
        }
        Save(bmp, path);
    }

    static void DrawMotif(Graphics g, string id, Color accent, int w, int h, bool ability) {
        float cx=w/2f, cy=h/2f;
        using (var dark = new SolidBrush(Color.FromArgb(235, 23, 24, 27)))
        using (var metal = new LinearGradientBrush(new RectangleF(w*.23f,h*.22f,w*.54f,h*.58f), Mix(accent, Color.White, .34f), Mix(accent, Color.Black, .28f), 30f))
        using (var outline = new Pen(Color.FromArgb(240, 10, 10, 12), 7f))
        using (var hi = new Pen(Color.FromArgb(160, 255, 255, 255), 2.5f)) {
            if (id.Contains("speed") || id.Contains("track") || id.Contains("tread") || id.Contains("thruster") || id.Contains("loader") || id.Contains("rate")) {
                var pts = new[]{new PointF(w*.25f,h*.58f),new PointF(w*.56f,h*.58f),new PointF(w*.56f,h*.76f),new PointF(w*.82f,h*.5f),new PointF(w*.56f,h*.24f),new PointF(w*.56f,h*.42f),new PointF(w*.25f,h*.42f)};
                g.DrawPolygon(outline, pts); g.FillPolygon(metal, pts); g.DrawLine(hi,w*.3f,h*.47f,w*.55f,h*.47f);
            } else if (id.Contains("armor") || id.Contains("shield") || id.Contains("plating") || id.Contains("gasket") || id.Contains("brace") || id.Contains("absorb")) {
                var pts = new[]{new PointF(cx,h*.20f),new PointF(w*.76f,h*.32f),new PointF(w*.69f,h*.68f),new PointF(cx,h*.83f),new PointF(w*.31f,h*.68f),new PointF(w*.24f,h*.32f)};
                g.DrawPolygon(outline, pts); g.FillPolygon(metal, pts); g.DrawLine(hi,cx,h*.28f,cx,h*.72f);
            } else if (id.Contains("repair") || id.Contains("heal") || id.Contains("nano") || id.Contains("med") || id.Contains("wrench") || id.Contains("vampire")) {
                using (var p = new Pen(Color.FromArgb(245, 236, 246, 238), 14f)) { p.StartCap=LineCap.Round; p.EndCap=LineCap.Round; g.DrawLine(p,cx,h*.28f,cx,h*.72f); g.DrawLine(p,w*.28f,cy,w*.72f,cy); }
                using (var p = new Pen(accent, 7f)) { p.StartCap=LineCap.Round; p.EndCap=LineCap.Round; g.DrawLine(p,cx,h*.28f,cx,h*.72f); g.DrawLine(p,w*.28f,cy,w*.72f,cy); }
            } else if (id.Contains("magnet") || id.Contains("pickup") || id.Contains("salvage") || id.Contains("crystal") || id.Contains("exp") || id.Contains("supply")) {
                using (var p = new Pen(Color.FromArgb(245, 16, 18, 20), 18f)) { p.StartCap=LineCap.Round; p.EndCap=LineCap.Round; g.DrawArc(p,w*.24f,h*.24f,w*.52f,h*.58f,35,290); }
                using (var p = new Pen(accent, 11f)) { p.StartCap=LineCap.Round; p.EndCap=LineCap.Round; g.DrawArc(p,w*.24f,h*.24f,w*.52f,h*.58f,35,290); }
                DrawCrystalShape(g, new RectangleF(w*.44f,h*.40f,w*.18f,h*.24f), Mix(accent, Color.White, .2f));
            } else if (id.Contains("fire") || id.Contains("flame") || id.Contains("ember") || id.Contains("combust") || id.Contains("flare") || id.Contains("meteor")) {
                var pts = new[]{new PointF(cx,h*.18f),new PointF(w*.69f,h*.47f),new PointF(w*.60f,h*.80f),new PointF(cx,h*.88f),new PointF(w*.35f,h*.78f),new PointF(w*.27f,h*.51f)};
                g.DrawPolygon(outline, pts); g.FillPolygon(metal, pts);
                using (var b = new SolidBrush(Color.FromArgb(220,255,245,120))) g.FillEllipse(b,w*.41f,h*.52f,w*.18f,h*.22f);
            } else if (id.Contains("shock") || id.Contains("volt") || id.Contains("tesla") || id.Contains("ion") || id.Contains("lightning") || id.Contains("capacitor")) {
                var pts = new[]{new PointF(w*.58f,h*.16f),new PointF(w*.31f,h*.54f),new PointF(w*.50f,h*.54f),new PointF(w*.39f,h*.84f),new PointF(w*.73f,h*.42f),new PointF(w*.53f,h*.42f)};
                g.DrawPolygon(outline, pts); g.FillPolygon(metal, pts);
            } else if (id.Contains("orbit") || id.Contains("gravity") || id.Contains("black_hole") || id.Contains("satellite") || id.Contains("drone") || id.Contains("storm")) {
                using (var p = new Pen(Color.FromArgb(235, 15, 16, 20), 6f)) g.DrawEllipse(p,w*.22f,h*.36f,w*.56f,h*.28f);
                using (var p = new Pen(accent, 3f)) g.DrawEllipse(p,w*.22f,h*.36f,w*.56f,h*.28f);
                using (var b = new SolidBrush(Mix(accent, Color.White, .2f))) g.FillEllipse(b,w*.39f,h*.34f,w*.22f,h*.22f);
                using (var b = new SolidBrush(Color.FromArgb(240,20,21,26))) g.FillEllipse(b,w*.47f,h*.42f,w*.06f,h*.06f);
            } else if (id.Contains("mine") || id.Contains("blast") || id.Contains("splash") || id.Contains("payload") || id.Contains("ordnance") || id.Contains("artillery")) {
                using (var b = metal) g.FillEllipse(b,w*.30f,h*.30f,w*.40f,h*.40f);
                g.DrawEllipse(outline,w*.30f,h*.30f,w*.40f,h*.40f);
                using (var p = new Pen(Color.FromArgb(240,255,240,160),4f)) g.DrawLine(p,w*.61f,h*.31f,w*.75f,h*.18f);
            } else if (id.Contains("target") || id.Contains("weak") || id.Contains("boss") || id.Contains("elite") || id.Contains("crit") || id.Contains("focus") || id.Contains("lens")) {
                using (var p = new Pen(accent, 5f)) { g.DrawEllipse(p,w*.28f,h*.28f,w*.44f,h*.44f); g.DrawLine(p,cx,h*.18f,cx,h*.35f); g.DrawLine(p,cx,h*.65f,cx,h*.82f); g.DrawLine(p,w*.18f,cy,w*.35f,cy); g.DrawLine(p,w*.65f,cy,w*.82f,cy); }
                using (var b = new SolidBrush(Color.FromArgb(245,255,235,100))) g.FillEllipse(b,cx-6,cy-6,12,12);
            } else {
                var pts = new[]{new PointF(cx,h*.20f),new PointF(w*.59f,h*.42f),new PointF(w*.82f,h*.42f),new PointF(w*.64f,h*.57f),new PointF(w*.70f,h*.80f),new PointF(cx,h*.66f),new PointF(w*.30f,h*.80f),new PointF(w*.36f,h*.57f),new PointF(w*.18f,h*.42f),new PointF(w*.41f,h*.42f)};
                g.DrawPolygon(outline, pts); g.FillPolygon(metal, pts);
            }
        }
    }

    static void DrawCrystalShape(Graphics g, RectangleF r, Color c) {
        var pts = new[]{new PointF(r.X+r.Width*.5f,r.Y),new PointF(r.Right,r.Y+r.Height*.36f),new PointF(r.X+r.Width*.68f,r.Bottom),new PointF(r.X+r.Width*.32f,r.Bottom),new PointF(r.X,r.Y+r.Height*.36f)};
        using (var p = new Pen(Color.FromArgb(210,8,12,14),3f))
        using (var b = new LinearGradientBrush(r, Mix(c,Color.White,.55f), Mix(c,Color.Black,.22f), 55f)) { g.FillPolygon(b, pts); g.DrawPolygon(p, pts); }
    }

    static void DrawGameplayAbility(string path, string kind) {
        var s=GetSize(path); var bmp=NewBmp(s.Width,s.Height);
        using (var g=G(bmp)) {
            var accent = kind=="saw" ? Color.Silver : kind=="soldier" ? Color.FromArgb(75,180,235) : Color.FromArgb(245,90,65);
            using (var glow=new SolidBrush(Color.FromArgb(80,accent))) g.FillEllipse(glow,8,8,s.Width-16,s.Height-16);
            if (kind=="saw") {
                for(int i=0;i<18;i++){ double a=i*Math.PI*2/18; DrawBlade(g, s.Width/2f,s.Height/2f, 22, 42, a, accent); }
                using(var b=new SolidBrush(Color.FromArgb(235,80,86,90))) g.FillEllipse(b,24,24,48,48);
                using(var p=new Pen(Color.FromArgb(230,16,18,20),5)) g.DrawEllipse(p,24,24,48,48);
            } else if (kind=="soldier") {
                FillBevel(g,new RectangleF(27,22,42,48),Color.FromArgb(75,110,125),9);
                using(var p=new Pen(Color.FromArgb(240,20,22,25),8)){p.StartCap=LineCap.Round;p.EndCap=LineCap.Round;g.DrawLine(p,50,42,76,35);}
                using(var p=new Pen(Color.FromArgb(255,120,210,255),4)){p.StartCap=LineCap.Round;p.EndCap=LineCap.Round;g.DrawLine(p,50,42,76,35);}
            } else {
                FillBevel(g,new RectangleF(25,28,46,40),Color.FromArgb(110,90,70),10);
                using(var p=new Pen(Color.FromArgb(245,255,170,75),4)){g.DrawLine(p,48,28,48,14);g.DrawLine(p,48,14,63,8);}
            }
        }
        Save(bmp,path);
    }

    static void DrawBlade(Graphics g,float cx,float cy,float inner,float outer,double a,Color c){
        var pts=new[]{Pt(cx,cy,inner,a-.08),Pt(cx,cy,outer,a),Pt(cx,cy,inner,a+.08)};
        using(var b=new SolidBrush(Mix(c,Color.White,.2f))) g.FillPolygon(b,pts);
    }

    static PointF Pt(float cx,float cy,float r,double a){return new PointF(cx+(float)Math.Cos(a)*r,cy+(float)Math.Sin(a)*r);}

    static void DrawPickup(string path,string kind){
        var s=GetSize(path); var bmp=NewBmp(s.Width,s.Height);
        using(var g=G(bmp)){
            using(var glow=new SolidBrush(Color.FromArgb(70,255,255,180))) g.FillEllipse(glow,10,10,s.Width-20,s.Height-20);
            if(kind=="wrench"){
                using(var p=new Pen(Color.FromArgb(240,15,17,19),15)){p.StartCap=LineCap.Round;p.EndCap=LineCap.Round;g.DrawLine(p,30,68,68,30);}
                using(var p=new Pen(Color.FromArgb(255,205,215,220),9)){p.StartCap=LineCap.Round;p.EndCap=LineCap.Round;g.DrawLine(p,30,68,68,30);}
                using(var p=new Pen(Color.FromArgb(240,15,17,19),7)) g.DrawArc(p,55,16,28,28,110,250);
            } else if(kind=="magnet"){
                using(var p=new Pen(Color.FromArgb(245,20,22,26),18)){p.StartCap=LineCap.Round;p.EndCap=LineCap.Round;g.DrawArc(p,22,18,52,62,35,290);}
                using(var p=new Pen(Color.FromArgb(255,230,70,70),11)){p.StartCap=LineCap.Round;p.EndCap=LineCap.Round;g.DrawArc(p,22,18,52,62,35,290);}
            } else {
                FillBevel(g,new RectangleF(28,25,40,46),Color.FromArgb(155,65,52),8);
                using(var p=new Pen(Color.FromArgb(255,255,210,80),4)) g.DrawLine(p,48,25,68,12);
            }
        }
        Save(bmp,path);
    }

    static void DrawSupply(string path, Color c){
        var s=GetSize(path); var bmp=NewBmp(s.Width,s.Height);
        using(var g=G(bmp)){
            FillBevel(g,new RectangleF(16,22,64,52),c,9);
            using(var p=new Pen(Color.FromArgb(235,32,34,38),5)) { g.DrawLine(p,48,22,48,74); g.DrawLine(p,16,48,80,48); }
            using(var p=new Pen(Color.FromArgb(210,255,255,255),3)) g.DrawLine(p,24,31,70,31);
        }
        Save(bmp,path);
    }

    static void DrawCrystal(string path, Color c){
        var s=GetSize(path); var bmp=NewBmp(s.Width,s.Height);
        using(var g=G(bmp)){
            using(var glow=new SolidBrush(Color.FromArgb(90,c))) g.FillEllipse(glow,5,5,s.Width-10,s.Height-10);
            DrawCrystalShape(g,new RectangleF(17,8,30,48),c);
            using(var p=new Pen(Color.FromArgb(150,255,255,255),2)) g.DrawLine(p,31,12,25,44);
        }
        Save(bmp,path);
    }

    static void DrawProjectile(string path, Color c, bool large){
        var s=GetSize(path); var bmp=NewBmp(s.Width,s.Height);
        using(var g=G(bmp)){
            using(var glow=new SolidBrush(Color.FromArgb(75,c))) g.FillEllipse(glow,4,4,s.Width-8,s.Height-8);
            var r=new RectangleF(s.Width*.28f,s.Height*.18f,s.Width*.44f,s.Height*.64f);
            using(var b=new LinearGradientBrush(r,Mix(c,Color.White,.45f),Mix(c,Color.Black,.28f),90f))
            using(var p=new Pen(Color.FromArgb(235,20,20,22),3)){
                g.FillEllipse(b,r); g.DrawEllipse(p,r);
            }
            using(var b=new SolidBrush(Color.FromArgb(185,255,255,255))) g.FillEllipse(b,s.Width*.40f,s.Height*.24f,s.Width*.15f,s.Height*.18f);
        }
        Save(bmp,path);
    }

    static void DrawTankBase(string path){
        var s=GetSize(path); var bmp=NewBmp(s.Width,s.Height);
        using(var g=G(bmp)) DrawTank(g,new RectangleF(14,18,s.Width-28,s.Height-32),Color.FromArgb(75,125,108));
        Save(bmp,path);
    }

    static void DrawTankCannon(string path){
        var s=GetSize(path); var bmp=NewBmp(s.Width,s.Height);
        using(var g=G(bmp)){
            using(var p=new Pen(Color.FromArgb(245,20,22,24),25)){p.StartCap=LineCap.Round;p.EndCap=LineCap.Round;g.DrawLine(p,s.Width/2f,s.Height*.70f,s.Width/2f,s.Height*.10f);}
            using(var p=new Pen(Color.FromArgb(255,92,104,112),16)){p.StartCap=LineCap.Round;p.EndCap=LineCap.Round;g.DrawLine(p,s.Width/2f,s.Height*.70f,s.Width/2f,s.Height*.10f);}
            FillBevel(g,new RectangleF(34,84,60,54),Color.FromArgb(72,104,92),18);
        }
        Save(bmp,path);
    }

    static void DrawTank(Graphics g, RectangleF r, Color c){
        FillBevel(g,new RectangleF(r.X,r.Y+r.Height*.20f,r.Width,r.Height*.60f),Color.FromArgb(42,47,48),20);
        FillBevel(g,new RectangleF(r.X+r.Width*.18f,r.Y+r.Height*.10f,r.Width*.64f,r.Height*.70f),c,18);
        using(var p=new Pen(Color.FromArgb(230,17,18,19),8)){p.StartCap=LineCap.Round;p.EndCap=LineCap.Round;g.DrawLine(p,r.X+r.Width*.50f,r.Y+r.Height*.42f,r.X+r.Width*.50f,r.Y-r.Height*.08f);}
        using(var p=new Pen(Color.FromArgb(255,105,118,124),5)){p.StartCap=LineCap.Round;p.EndCap=LineCap.Round;g.DrawLine(p,r.X+r.Width*.50f,r.Y+r.Height*.42f,r.X+r.Width*.50f,r.Y-r.Height*.08f);}
        using(var b=new SolidBrush(Color.FromArgb(170,255,255,255))) g.FillEllipse(b,r.X+r.Width*.34f,r.Y+r.Height*.20f,r.Width*.16f,r.Height*.12f);
    }

    static void DrawTankSheet(string path){
        var s=GetSize(path); var bmp=NewBmp(s.Width,s.Height);
        using(var g=G(bmp)){
            var colors=new[]{Color.FromArgb(75,125,108),Color.FromArgb(135,105,75),Color.FromArgb(75,100,150),Color.FromArgb(150,82,62),Color.FromArgb(95,90,135),Color.FromArgb(70,135,145),Color.FromArgb(150,145,75),Color.FromArgb(95,120,80)};
            int cols=5, rows=3; float cw=s.Width/(float)cols, ch=s.Height/(float)rows;
            int i=0; for(int y=0;y<rows;y++) for(int x=0;x<cols;x++){ DrawTank(g,new RectangleF(x*cw+cw*.18f,y*ch+ch*.22f,cw*.64f,ch*.58f),colors[i%colors.Length]); i++; }
        }
        Save(bmp,path);
    }

    static void DrawEnemy(string path,string kind){
        var s=GetSize(path); var bmp=NewBmp(s.Width,s.Height);
        using(var g=G(bmp)){
            var accent = kind.Contains("boss") ? Color.FromArgb(210,70,215) : HueColor(kind.GetHashCode(),150,220);
            using(var glow=new SolidBrush(Color.FromArgb(kind.Contains("boss")?95:55, accent))) g.FillEllipse(glow,s.Width*.10f,s.Height*.10f,s.Width*.80f,s.Height*.80f);
            if(kind.Contains("tank")||kind.Contains("phalanx")||kind.Contains("bulldozer")||kind=="shield"||kind=="bruiser"||kind.Contains("boss")){
                FillBevel(g,new RectangleF(s.Width*.18f,s.Height*.24f,s.Width*.64f,s.Height*.52f),accent,18);
                using(var p=new Pen(Color.FromArgb(235,18,20,22),5)) g.DrawLine(p,s.Width*.25f,s.Height*.35f,s.Width*.75f,s.Height*.35f);
                using(var b=new SolidBrush(Color.FromArgb(230,255,245,130))) g.FillEllipse(b,s.Width*.42f,s.Height*.42f,s.Width*.16f,s.Height*.16f);
            } else if(kind.Contains("runner")||kind.Contains("viper")||kind.Contains("lancer")){
                var pts=new[]{new PointF(s.Width*.50f,s.Height*.12f),new PointF(s.Width*.82f,s.Height*.78f),new PointF(s.Width*.50f,s.Height*.62f),new PointF(s.Width*.18f,s.Height*.78f)};
                using(var p=new Pen(Color.FromArgb(235,18,20,22),7)) g.DrawPolygon(p,pts);
                using(var b=new LinearGradientBrush(new RectangleF(0,0,s.Width,s.Height),Mix(accent,Color.White,.25f),Mix(accent,Color.Black,.25f),55)) g.FillPolygon(b,pts);
            } else if(kind.Contains("reaper")||kind.Contains("stalker")||kind.Contains("sapper")){
                var pts=new[]{new PointF(s.Width*.50f,s.Height*.10f),new PointF(s.Width*.76f,s.Height*.38f),new PointF(s.Width*.64f,s.Height*.86f),new PointF(s.Width*.50f,s.Height*.68f),new PointF(s.Width*.36f,s.Height*.86f),new PointF(s.Width*.24f,s.Height*.38f)};
                using(var p=new Pen(Color.FromArgb(235,18,20,22),7)) g.DrawPolygon(p,pts);
                using(var b=new LinearGradientBrush(new RectangleF(0,0,s.Width,s.Height),Mix(accent,Color.White,.25f),Mix(accent,Color.Black,.30f),35)) g.FillPolygon(b,pts);
                using(var p=new Pen(Color.FromArgb(230,255,255,255),2)) g.DrawLine(p,s.Width*.5f,s.Height*.18f,s.Width*.5f,s.Height*.64f);
            } else {
                for(int i=0;i<8;i++){ double a=i*Math.PI*2/8; using(var p=new Pen(Color.FromArgb(235,18,20,22),7)){p.StartCap=LineCap.Round;p.EndCap=LineCap.Round;g.DrawLine(p,s.Width/2f,s.Height/2f,Pt(s.Width/2f,s.Height/2f,s.Width*.36f,a).X,Pt(s.Width/2f,s.Height/2f,s.Width*.36f,a).Y);} }
                using(var b=new LinearGradientBrush(new RectangleF(s.Width*.22f,s.Height*.22f,s.Width*.56f,s.Height*.56f),Mix(accent,Color.White,.30f),Mix(accent,Color.Black,.30f),55)) g.FillEllipse(b,s.Width*.22f,s.Height*.22f,s.Width*.56f,s.Height*.56f);
                using(var p=new Pen(Color.FromArgb(235,18,20,22),6)) g.DrawEllipse(p,s.Width*.22f,s.Height*.22f,s.Width*.56f,s.Height*.56f);
            }
            using(var eye=new SolidBrush(Color.FromArgb(235,255,245,120))) g.FillEllipse(eye,s.Width*.44f,s.Height*.42f,s.Width*.12f,s.Height*.12f);
        }
        Save(bmp,path);
    }

    static void DrawEffect(string path){
        var s=GetSize(path); var bmp=NewBmp(s.Width,s.Height);
        using(var g=G(bmp)){
            for(int i=0;i<18;i++){ double a=i*Math.PI*2/18; var c=i%2==0?Color.FromArgb(255,255,205,70):Color.FromArgb(230,255,85,65); DrawBlade(g,s.Width/2f,s.Height/2f,10,s.Width*.48f,a,c); }
            using(var b=new SolidBrush(Color.FromArgb(240,255,248,180))) g.FillEllipse(b,s.Width*.36f,s.Height*.36f,s.Width*.28f,s.Height*.28f);
        }
        Save(bmp,path);
    }

    static void DrawRadialLight(string path){
        var s=GetSize(path); var bmp=NewBmp(s.Width,s.Height);
        using(var g=G(bmp)){
            for(int i=0;i<80;i++){
                int a=(int)(70*(1-i/80f)); float r=s.Width*(.48f-i*.004f);
                using(var b=new SolidBrush(Color.FromArgb(a,95,210,255))) g.FillEllipse(b,s.Width/2f-r,s.Height/2f-r,r*2,r*2);
            }
        }
        Save(bmp,path);
    }

    static void DrawPanel(string path,int w,int h){
        var bmp=NewBmp(w,h);
        using(var g=G(bmp)){
            FillBevel(g,new RectangleF(4,4,w-8,h-8),Color.FromArgb(42,54,62),Math.Min(w,h)*.12f);
            using(var p=new Pen(Color.FromArgb(180,105,160,185),Math.Max(2,w*.012f))) g.DrawRectangle(p,w*.08f,h*.08f,w*.84f,h*.84f);
        }
        Save(bmp,path);
    }

    static void DrawBackground(string path,bool menu){
        var s=GetSize(path); var bmp=NewBmp(s.Width,s.Height,false);
        using(var g=G(bmp)){
            using(var bg=new LinearGradientBrush(new RectangleF(0,0,s.Width,s.Height), menu?Color.FromArgb(26,38,48):Color.FromArgb(58,65,55), menu?Color.FromArgb(58,80,88):Color.FromArgb(86,82,62), 70f)) g.FillRectangle(bg,0,0,s.Width,s.Height);
            for(int i=0;i<(menu?80:95);i++){
                int x=Rng.Next(s.Width), y=Rng.Next(s.Height), rw=Rng.Next(24, menu?110:70), rh=Rng.Next(10, menu?45:35);
                var c=menu?Color.FromArgb(Rng.Next(16,45),95,140,155):Color.FromArgb(Rng.Next(22,58),118,112,78);
                using(var b=new SolidBrush(c)) g.FillEllipse(b,x,y,rw,rh);
            }
            if(menu){
                using(var glow=new SolidBrush(Color.FromArgb(90,70,155,190))) g.FillEllipse(glow,s.Width*.12f,s.Height*.12f,s.Width*.76f,s.Height*.70f);
            } else {
                using(var road=new SolidBrush(Color.FromArgb(42,95,90,68))) {
                    var pts = new[]{new PointF(-60,s.Height*.68f),new PointF(s.Width*.25f,s.Height*.55f),new PointF(s.Width*.62f,s.Height*.48f),new PointF(s.Width+80,s.Height*.42f),new PointF(s.Width+80,s.Height*.54f),new PointF(s.Width*.62f,s.Height*.61f),new PointF(s.Width*.25f,s.Height*.70f),new PointF(-60,s.Height*.84f)};
                    g.FillPolygon(road, pts);
                }
                using(var p=new Pen(Color.FromArgb(54,38,43,36),2)) for(int i=0;i<14;i++) g.DrawLine(p,Rng.Next(s.Width),Rng.Next(s.Height),Rng.Next(s.Width),Rng.Next(s.Height));
                for(int i=0;i<34;i++){
                    int x=Rng.Next(s.Width), y=Rng.Next(s.Height), rw=Rng.Next(18,48), rh=Rng.Next(10,30);
                    using(var b=new SolidBrush(Color.FromArgb(46,62,65,54))) g.FillEllipse(b,x+3,y+4,rw,rh);
                    using(var b=new LinearGradientBrush(new RectangleF(x,y,rw,rh),Color.FromArgb(82,112,112,92),Color.FromArgb(72,58,62,54),45f)) g.FillEllipse(b,x,y,rw,rh);
                }
            }
        }
        Save(bmp,path);
    }

    static void DrawCloud(string path,int w,int h,int blobs){
        var bmp=NewBmp(w,h);
        using(var g=G(bmp)){
            for(int i=0;i<blobs;i++){
                using(var b=new SolidBrush(Color.FromArgb(22+Rng.Next(18),20,28,32))) g.FillEllipse(b,Rng.Next(w),Rng.Next(h),Rng.Next(w/5,w/2),Rng.Next(h/5,h/2));
            }
        }
        Save(bmp,path);
    }
}
"@

Add-Type -ReferencedAssemblies "System.Drawing" -TypeDefinition $source -Language CSharp
[SemiRealAssetGenerator]::Generate((Get-Location).Path)

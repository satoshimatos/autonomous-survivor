$ErrorActionPreference = "Stop"

$source = @"
using System;
using System.IO;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;

public static class LateMapEnemyAssetGenerator {
    public static void Generate(string root) {
        Directory.SetCurrentDirectory(root);
        MakeDir("map3"); MakeDir("map4"); MakeDir("map5");

        DrawEnemy("map3/shardling.png", C(55, 220, 250), C(34, 92, 120), "shard");
        DrawEnemy("map3/prism_runner.png", C(245, 76, 210), C(72, 64, 118), "runner");
        DrawEnemy("map3/quartz_bulwark.png", C(180, 238, 255), C(72, 108, 128), "bulwark");
        DrawEnemy("map3/lens_wraith.png", C(142, 132, 255), C(46, 62, 120), "wraith");
        DrawEnemy("map3/crystal_juggernaut.png", C(44, 230, 255), C(66, 94, 112), "juggernaut");
        DrawBoss("map3/boss_prism_regent.png", C(70, 230, 255), C(48, 72, 132), "regent");
        DrawBoss("map3/boss_crystal_hydra.png", C(182, 84, 255), C(58, 78, 128), "hydra");

        DrawEnemy("map4/spore_tick.png", C(128, 245, 42), C(64, 98, 42), "spore");
        DrawEnemy("map4/acid_sprinter.png", C(190, 255, 42), C(82, 104, 44), "runner");
        DrawEnemy("map4/caustic_bloater.png", C(98, 206, 48), C(80, 92, 42), "bloater");
        DrawEnemy("map4/fume_stalker.png", C(92, 190, 58), C(44, 76, 44), "wraith");
        DrawEnemy("map4/slag_titan.png", C(186, 220, 52), C(88, 98, 46), "juggernaut");
        DrawBoss("map4/boss_toxlord.png", C(142, 255, 36), C(62, 96, 44), "tox");
        DrawBoss("map4/boss_furnace_queen.png", C(238, 202, 42), C(96, 76, 42), "queen");

        DrawEnemy("map5/null_mite.png", C(190, 70, 255), C(42, 28, 82), "spore");
        DrawEnemy("map5/rift_lancer.png", C(255, 58, 220), C(58, 34, 96), "runner");
        DrawEnemy("map5/gravity_knight.png", C(102, 58, 220), C(48, 42, 92), "bulwark");
        DrawEnemy("map5/event_horizon.png", C(92, 28, 160), C(22, 18, 48), "wraith");
        DrawEnemy("map5/cosmic_devourer.png", C(150, 55, 255), C(38, 28, 72), "juggernaut");
        DrawBoss("map5/boss_rift_seraph.png", C(196, 76, 255), C(38, 30, 92), "seraph");
        DrawBoss("map5/boss_void_emperor.png", C(104, 26, 198), C(18, 14, 48), "emperor");
    }

    static void MakeDir(string map) {
        Directory.CreateDirectory("assets/visual/enemies/" + map);
    }

    static string PathFor(string relative) {
        return "assets/visual/enemies/" + relative;
    }

    static Color C(int r, int g, int b) { return Color.FromArgb(r, g, b); }

    static Bitmap Bmp(int size) {
        var bmp = new Bitmap(size, size, PixelFormat.Format32bppArgb);
        using (var g = Graphics.FromImage(bmp)) g.Clear(Color.Transparent);
        return bmp;
    }

    static void DrawEnemy(string path, Color hot, Color body, string type) {
        using (var bmp = Bmp(160))
        using (var g = Graphics.FromImage(bmp)) {
            Prep(g);
            Shadow(g, 35, 116, 90, 22);
            var outline = Color.FromArgb(20, 16, 22);
            if (type == "runner") {
                Poly(g, outline, 8, P(80, 18), P(124, 80), P(80, 142), P(36, 80));
                Poly(g, body, 0, P(80, 22), P(118, 80), P(80, 136), P(42, 80));
            } else if (type == "bulwark" || type == "juggernaut") {
                Round(g, outline, 28, 34, 104, 92, 18);
                Round(g, body, 34, 40, 92, 80, 14);
            } else if (type == "wraith") {
                Ell(g, outline, 28, 26, 104, 104);
                Ell(g, body, 36, 34, 88, 90);
            } else {
                Gear(g, outline, P(80, 82), type == "shard" ? 58 : 46, 7);
                Gear(g, body, P(80, 82), type == "shard" ? 50 : 40, 7);
            }
            Core(g, hot, 56, 56, 48, 44);
            using (var pen = new Pen(outline, 5)) {
                g.DrawLine(pen, 42, 92, 18, 112);
                g.DrawLine(pen, 118, 92, 142, 112);
                if (type == "juggernaut" || type == "bloater") {
                    g.DrawLine(pen, 44, 42, 22, 22);
                    g.DrawLine(pen, 116, 42, 138, 22);
                }
            }
            using (var pen = new Pen(hot, 5)) {
                g.DrawArc(pen, 32, 32, 96, 96, 205, 130);
                if (type == "shard") g.DrawLine(pen, 80, 18, 80, 142);
            }
            bmp.Save(PathFor(path), ImageFormat.Png);
        }
    }

    static void DrawBoss(string path, Color hot, Color body, string type) {
        using (var bmp = Bmp(256))
        using (var g = Graphics.FromImage(bmp)) {
            Prep(g);
            Shadow(g, 40, 190, 176, 34);
            var outline = Color.FromArgb(16, 12, 18);
            Gear(g, outline, P(128, 122), 88, 12);
            Gear(g, body, P(128, 122), 76, 12);
            Round(g, Dark(body, 28), 64, 70, 128, 108, 22);
            Core(g, hot, 88, 88, 80, 72);
            using (var pen = new Pen(outline, 10)) {
                g.DrawLine(pen, 56, 104, 20, 76);
                g.DrawLine(pen, 200, 104, 236, 76);
                g.DrawLine(pen, 58, 164, 18, 198);
                g.DrawLine(pen, 198, 164, 238, 198);
            }
            using (var pen = new Pen(hot, 7)) {
                g.DrawArc(pen, 48, 42, 160, 160, 195, 150);
                if (type == "hydra" || type == "queen") {
                    g.DrawLine(pen, 70, 42, 128, 22);
                    g.DrawLine(pen, 186, 42, 128, 22);
                }
                if (type == "emperor") {
                    g.DrawEllipse(pen, 54, 48, 148, 148);
                    g.DrawLine(pen, 128, 26, 128, 224);
                }
            }
            bmp.Save(PathFor(path), ImageFormat.Png);
        }
    }

    static PointF P(float x, float y) { return new PointF(x, y); }

    static void Prep(Graphics g) {
        g.SmoothingMode = SmoothingMode.AntiAlias;
        g.InterpolationMode = InterpolationMode.HighQualityBicubic;
        g.PixelOffsetMode = PixelOffsetMode.HighQuality;
    }

    static void Shadow(Graphics g, float x, float y, float w, float h) {
        using (var b = new SolidBrush(Color.FromArgb(80, 0, 0, 0))) g.FillEllipse(b, x, y, w, h);
    }

    static void Core(Graphics g, Color hot, float x, float y, float w, float h) {
        using (var b = new SolidBrush(Color.FromArgb(236, hot))) g.FillEllipse(b, x, y, w, h);
        using (var b = new SolidBrush(Color.FromArgb(150, Light(hot, 78)))) g.FillEllipse(b, x + w * 0.22f, y + h * 0.18f, w * 0.34f, h * 0.26f);
    }

    static void Ell(Graphics g, Color c, float x, float y, float w, float h) {
        using (var b = new SolidBrush(c)) g.FillEllipse(b, x, y, w, h);
    }

    static void Round(Graphics g, Color c, float x, float y, float w, float h, float r) {
        using (var b = new SolidBrush(c))
        using (var p = new GraphicsPath()) {
            p.AddArc(x, y, r, r, 180, 90);
            p.AddArc(x + w - r, y, r, r, 270, 90);
            p.AddArc(x + w - r, y + h - r, r, r, 0, 90);
            p.AddArc(x, y + h - r, r, r, 90, 90);
            p.CloseFigure();
            g.FillPath(b, p);
        }
    }

    static void Poly(Graphics g, Color c, float expand, params PointF[] pts) {
        using (var b = new SolidBrush(c)) g.FillPolygon(b, pts);
    }

    static void Gear(Graphics g, Color c, PointF center, float radius, int teeth) {
        using (var b = new SolidBrush(c))
        using (var p = new GraphicsPath()) {
            var pts = new PointF[teeth * 2];
            for (int i = 0; i < pts.Length; i++) {
                double a = -Math.PI / 2.0 + i * Math.PI / teeth;
                float r = (i % 2 == 0) ? radius : radius * 0.72f;
                pts[i] = P(center.X + (float)Math.Cos(a) * r, center.Y + (float)Math.Sin(a) * r);
            }
            p.AddPolygon(pts);
            g.FillPath(b, p);
        }
    }

    static Color Light(Color c, int amount) {
        return Color.FromArgb(c.A, Math.Min(c.R + amount, 255), Math.Min(c.G + amount, 255), Math.Min(c.B + amount, 255));
    }

    static Color Dark(Color c, int amount) {
        return Color.FromArgb(c.A, Math.Max(c.R - amount, 0), Math.Max(c.G - amount, 0), Math.Max(c.B - amount, 0));
    }
}
"@

Add-Type -ReferencedAssemblies System.Drawing -TypeDefinition $source
[LateMapEnemyAssetGenerator]::Generate((Get-Location).Path)

$ErrorActionPreference = "Stop"

$source = @"
using System;
using System.IO;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.Drawing.Imaging;

public static class Map2EnemyAssetGenerator {
    public static void Generate(string root) {
        Directory.SetCurrentDirectory(root);
        Directory.CreateDirectory("assets/visual/enemies/map2");
        DrawEnemy("assets/visual/enemies/map2/scrap_scout.png", Color.FromArgb(235, 116, 48), Color.FromArgb(100, 82, 64), "blade");
        DrawEnemy("assets/visual/enemies/map2/gear_runner.png", Color.FromArgb(60, 196, 235), Color.FromArgb(70, 92, 106), "runner");
        DrawEnemy("assets/visual/enemies/map2/slag_brute.png", Color.FromArgb(230, 70, 36), Color.FromArgb(120, 86, 42), "brute");
        DrawEnemy("assets/visual/enemies/map2/magnet_wraith.png", Color.FromArgb(128, 72, 238), Color.FromArgb(48, 58, 98), "wraith");
        DrawEnemy("assets/visual/enemies/map2/crusher_drone.png", Color.FromArgb(142, 154, 158), Color.FromArgb(76, 83, 86), "crusher");
        DrawEnemy("assets/visual/enemies/map2/furnace_reaper.png", Color.FromArgb(248, 44, 20), Color.FromArgb(76, 32, 24), "reaper");
        DrawBoss("assets/visual/enemies/map2/boss_scrapyard_warden.png", Color.FromArgb(242, 116, 32), Color.FromArgb(84, 76, 66), "warden");
        DrawBoss("assets/visual/enemies/map2/boss_magnetar_colossus.png", Color.FromArgb(122, 64, 246), Color.FromArgb(42, 58, 106), "magnetar");
        DrawBoss("assets/visual/enemies/map2/boss_foundry_overlord.png", Color.FromArgb(252, 56, 24), Color.FromArgb(94, 38, 28), "foundry");
    }

    static Bitmap NewBmp(int w, int h) {
        var bmp = new Bitmap(w, h, PixelFormat.Format32bppArgb);
        using (var g = Graphics.FromImage(bmp)) g.Clear(Color.Transparent);
        return bmp;
    }

    static void DrawEnemy(string path, Color hot, Color metal, string type) {
        using (var bmp = NewBmp(160, 160))
        using (var g = Graphics.FromImage(bmp)) {
            Prep(g);
            var center = new PointF(80, 82);
            using (var shadow = new SolidBrush(Color.FromArgb(70, 0, 0, 0))) g.FillEllipse(shadow, 36, 114, 88, 24);
            using (var outline = new Pen(Color.FromArgb(18, 15, 14), 10)) {
                if (type == "runner") DrawDiamond(g, outline, center, 44, 62);
                else if (type == "wraith") g.DrawEllipse(outline, 34, 28, 92, 96);
                else if (type == "crusher") g.DrawRectangle(outline, 36, 38, 88, 78);
                else DrawGearBody(g, outline, center, 52, 8);
            }
            using (var body = new SolidBrush(metal))
            using (var rim = new Pen(Light(metal, 65), 5)) {
                if (type == "runner") FillDiamond(g, body, center, 44, 62);
                else if (type == "wraith") g.FillEllipse(body, 34, 28, 92, 96);
                else if (type == "crusher") RoundRect(g, body, 36, 38, 88, 78, 12);
                else FillGearBody(g, body, center, 52, 8);
                g.DrawEllipse(rim, 45, 46, 70, 58);
            }
            using (var glow = new SolidBrush(Color.FromArgb(235, hot)))
            using (var flare = new SolidBrush(Color.FromArgb(160, Light(hot, 80)))) {
                g.FillEllipse(glow, 55, 56, 50, 42);
                g.FillEllipse(flare, 64, 62, 18, 14);
            }
            using (var pen = new Pen(Color.FromArgb(20, 16, 12), 5)) {
                g.DrawLine(pen, 42, 88, 18, 108);
                g.DrawLine(pen, 118, 88, 142, 108);
                if (type == "brute" || type == "crusher") {
                    g.DrawLine(pen, 48, 40, 28, 18);
                    g.DrawLine(pen, 112, 40, 132, 18);
                }
            }
            using (var accent = new Pen(hot, 5)) {
                g.DrawArc(accent, 32, 32, 96, 96, 210, 120);
                if (type == "reaper") g.DrawLine(accent, 36, 118, 124, 32);
            }
            bmp.Save(path, ImageFormat.Png);
        }
    }

    static void DrawBoss(string path, Color hot, Color metal, string type) {
        using (var bmp = NewBmp(256, 256))
        using (var g = Graphics.FromImage(bmp)) {
            Prep(g);
            using (var shadow = new SolidBrush(Color.FromArgb(85, 0, 0, 0))) g.FillEllipse(shadow, 42, 188, 172, 34);
            using (var outline = new Pen(Color.FromArgb(14, 12, 10), 14)) DrawGearBody(g, outline, new PointF(128, 122), 82, 12);
            using (var body = new SolidBrush(metal)) FillGearBody(g, body, new PointF(128, 122), 82, 12);
            using (var plate = new SolidBrush(Dark(metal, 35))) RoundRect(g, plate, 66, 72, 124, 102, 24);
            using (var glow = new SolidBrush(Color.FromArgb(238, hot))) g.FillEllipse(glow, 90, 88, 76, 70);
            using (var flare = new SolidBrush(Color.FromArgb(160, Light(hot, 90)))) g.FillEllipse(flare, 108, 102, 24, 18);
            using (var outline = new Pen(Color.FromArgb(15, 12, 10), 10))
            using (var accent = new Pen(hot, 7)) {
                g.DrawLine(outline, 50, 104, 18, 76);
                g.DrawLine(outline, 206, 104, 238, 76);
                g.DrawLine(outline, 58, 158, 20, 190);
                g.DrawLine(outline, 198, 158, 236, 190);
                g.DrawArc(accent, 48, 42, 160, 160, 198, 144);
                if (type == "magnetar") {
                    g.DrawEllipse(accent, 58, 52, 140, 140);
                    g.DrawLine(accent, 128, 28, 128, 222);
                } else if (type == "foundry") {
                    g.DrawLine(accent, 56, 194, 200, 52);
                    g.DrawLine(accent, 74, 42, 186, 202);
                }
            }
            bmp.Save(path, ImageFormat.Png);
        }
    }

    static void Prep(Graphics g) {
        g.SmoothingMode = SmoothingMode.AntiAlias;
        g.InterpolationMode = InterpolationMode.HighQualityBicubic;
        g.PixelOffsetMode = PixelOffsetMode.HighQuality;
    }

    static void DrawGearBody(Graphics g, Pen pen, PointF c, float r, int teeth) {
        using (var path = GearPath(c, r, teeth)) g.DrawPath(pen, path);
    }

    static void FillGearBody(Graphics g, Brush brush, PointF c, float r, int teeth) {
        using (var path = GearPath(c, r, teeth)) g.FillPath(brush, path);
    }

    static GraphicsPath GearPath(PointF c, float r, int teeth) {
        var path = new GraphicsPath();
        var points = new PointF[teeth * 2];
        for (int i = 0; i < points.Length; i++) {
            double a = -Math.PI / 2.0 + i * Math.PI / teeth;
            float rr = (i % 2 == 0) ? r : r * 0.78f;
            points[i] = new PointF(c.X + (float)Math.Cos(a) * rr, c.Y + (float)Math.Sin(a) * rr);
        }
        path.AddPolygon(points);
        return path;
    }

    static void FillDiamond(Graphics g, Brush b, PointF c, float w, float h) {
        g.FillPolygon(b, new PointF[] { new PointF(c.X, c.Y - h), new PointF(c.X + w, c.Y), new PointF(c.X, c.Y + h), new PointF(c.X - w, c.Y) });
    }

    static void DrawDiamond(Graphics g, Pen p, PointF c, float w, float h) {
        g.DrawPolygon(p, new PointF[] { new PointF(c.X, c.Y - h), new PointF(c.X + w, c.Y), new PointF(c.X, c.Y + h), new PointF(c.X - w, c.Y) });
    }

    static void RoundRect(Graphics g, Brush b, float x, float y, float w, float h, float r) {
        using (var path = new GraphicsPath()) {
            path.AddArc(x, y, r, r, 180, 90);
            path.AddArc(x + w - r, y, r, r, 270, 90);
            path.AddArc(x + w - r, y + h - r, r, r, 0, 90);
            path.AddArc(x, y + h - r, r, r, 90, 90);
            path.CloseFigure();
            g.FillPath(b, path);
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
[Map2EnemyAssetGenerator]::Generate((Get-Location).Path)

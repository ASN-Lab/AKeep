<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>AKeep — Asset & Warranty Tracker</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@400;500;600;700&family=JetBrains+Mono:wght@400;500&display=swap" rel="stylesheet">
    <style>
        :root {
            --bg: #0F1115;
            --surface: #181B20;
            --surface-hover: #1F232B;
            --text: #F8F9FA;
            --muted: #6C757D;
            --amber: #FF9F0A;
            --lime: #D4FF00;
            --red: #FF453A;
            --border: #2A2E36;
        }
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            background: var(--bg);
            color: var(--text);
            font-family: 'Space Grotesk', sans-serif;
            line-height: 1.6;
            min-height: 100vh;
        }
        .container { max-width: 1200px; margin: 0 auto; padding: 0 24px; }
        header {
            border-bottom: 1px solid var(--border);
            padding: 20px 0;
            position: sticky;
            top: 0;
            background: rgba(15, 17, 21, 0.9);
            backdrop-filter: blur(12px);
            z-index: 100;
        }
        .nav { display: flex; justify-content: space-between; align-items: center; }
        .logo { font-size: 24px; font-weight: 700; letter-spacing: -0.5px; }
        .logo span { color: var(--lime); }
        .nav-right { display: flex; gap: 24px; align-items: center; }
        .status-badge {
            display: flex; align-items: center; gap: 8px;
            font-family: 'JetBrains Mono', monospace; font-size: 12px;
            color: var(--muted);
            padding: 6px 12px;
            border: 1px solid var(--border);
            border-radius: 999px;
        }
        .status-dot {
            width: 8px; height: 8px; border-radius: 50%;
            background: var(--lime);
            box-shadow: 0 0 8px var(--lime);
            animation: pulse 2s infinite;
        }
        @keyframes pulse { 0%, 100% { opacity: 1; } 50% { opacity: 0.4; } }
        .nav-link { color: var(--muted); text-decoration: none; font-size: 14px; transition: color 0.2s; }
        .nav-link:hover { color: var(--text); }
        .btn {
            display: inline-block; padding: 12px 24px; border-radius: 8px;
            font-size: 14px; font-weight: 600; text-decoration: none;
            transition: all 0.2s; border: none; cursor: pointer;
        }
        .btn-primary { background: var(--lime); color: #0F1115; }
        .btn-primary:hover { transform: translateY(-2px); box-shadow: 0 8px 24px rgba(212, 255, 0, 0.3); }
        .btn-ghost { border: 1px solid var(--border); color: var(--text); }
        .btn-ghost:hover { background: var(--surface-hover); border-color: var(--muted); }
        .btn-sm { padding: 8px 16px; font-size: 13px; }
        .hero { padding: 96px 0 64px; text-align: center; }
        .hero h1 {
            font-size: clamp(40px, 6vw, 72px); font-weight: 700;
            letter-spacing: -2px; line-height: 1.05; margin-bottom: 24px;
        }
        .hero h1 .accent { color: var(--amber); }
        .hero p { font-size: 18px; color: var(--muted); max-width: 560px; margin: 0 auto 40px; }
        .hero-cta { display: flex; gap: 16px; justify-content: center; flex-wrap: wrap; }
        .bento {
            display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 20px; padding: 32px 0 96px;
        }
        .card {
            background: var(--surface); border: 1px solid var(--border);
            border-radius: 16px; padding: 28px; transition: all 0.3s;
        }
        .card:hover { border-color: var(--muted); transform: translateY(-4px); }
        .card-label {
            font-family: 'JetBrains Mono', monospace; font-size: 11px;
            text-transform: uppercase; letter-spacing: 1.5px;
            color: var(--muted); margin-bottom: 16px;
        }
        .card-value {
            font-family: 'JetBrains Mono', monospace; font-size: 36px;
            font-weight: 500; letter-spacing: -1px;
        }
        .card-value.amber { color: var(--amber); }
        .card-value.lime { color: var(--lime); }
        .card-sub { font-size: 13px; color: var(--muted); margin-top: 12px; }
        .warranty-bar {
            height: 6px; background: var(--bg); border-radius: 999px;
            margin-top: 20px; overflow: hidden;
        }
        .warranty-fill {
            height: 100%; border-radius: 999px;
            background: linear-gradient(90deg, var(--lime), var(--amber), var(--red));
            width: 68%;
        }
        .queue-item {
            display: flex; align-items: center; gap: 12px;
            padding: 10px 0; border-bottom: 1px solid var(--border);
            font-family: 'JetBrains Mono', monospace; font-size: 12px;
        }
        .queue-item:last-child { border-bottom: none; }
        .queue-status {
            width: 8px; height: 8px; border-radius: 50%;
        }
        .download-banner {
            border-top: 1px solid var(--border);
            padding: 48px 0; text-align: center;
        }
        .download-banner h2 { font-size: 28px; font-weight: 600; margin-bottom: 12px; }
        .download-banner p { color: var(--muted); margin-bottom: 28px; font-size: 15px; }
        footer { border-top: 1px solid var(--border); padding: 32px 0; color: var(--muted); font-size: 13px; }
        .footer-inner { display: flex; justify-content: space-between; flex-wrap: wrap; gap: 16px; }
        @media (max-width: 640px) { .hero { padding: 48px 0; } .bento { grid-template-columns: 1fr; } }
    </style>
</head>
<body>
    <header>
        <div class="container nav">
            <div class="logo">A<span>Keep</span></div>
            <div class="nav-right">
                <div class="status-badge">
                    <div class="status-dot"></div>
                    API STATUS: OPERATIONAL
                </div>
                <a href="/admin/login" class="nav-link">Admin Panel</a>
                <a href="https://github.com/ASN-Lab/AKeep/releases/latest/download/app-release.apk" class="btn btn-ghost btn-sm">Download APK</a>
            </div>
        </div>
    </header>

    <section class="hero container">
        <h1>Lacak Aset &<br><span class="accent">Garansi</span> Tanpa Lupa.</h1>
        <p>Personal Asset, Warranty & Maintenance Tracker. Offline-first, ringan, dan bebas biaya server.</p>
        <div class="hero-cta">
            <a href="https://github.com/ASN-Lab/AKeep/releases/latest/download/app-release.apk" class="btn btn-primary">Download APK</a>
            <a href="/admin/login" class="btn btn-ghost">Buka Admin Panel</a>
        </div>
    </section>

    <section class="bento container">
        <div class="card">
            <div class="card-label">// Total Asset Value</div>
            <div class="card-value lime">Rp 48.250.000</div>
            <div class="card-sub">Akumulasi 12 aset aktif tercatat di sistem.</div>
        </div>
        <div class="card">
            <div class="card-label">// Warranty Countdown</div>
            <div class="card-value amber">17 hari</div>
            <div class="card-sub">Laptop Lenovo ThinkPad — garansi berakhir 27 Okt 2026.</div>
            <div class="warranty-bar"><div class="warranty-fill"></div></div>
        </div>
        <div class="card">
            <div class="card-label">// Offline Queue Visualizer</div>
            <div class="queue-item">
                <div class="queue-status" style="background: var(--lime);"></div>
                <span>ASSET-8842 · RECEIPT.JPG</span>
                <span style="margin-left: auto; color: var(--lime);">SYNCED</span>
            </div>
            <div class="queue-item">
                <div class="queue-status" style="background: var(--amber);"></div>
                <span>ASSET-8843 · INVOICE.PDF</span>
                <span style="margin-left: auto; color: var(--amber);">PENDING</span>
            </div>
            <div class="queue-item">
                <div class="queue-status" style="background: var(--lime);"></div>
                <span>MAINT-1201 · RECEIPT2.JPG</span>
                <span style="margin-left: auto; color: var(--lime);">SYNCED</span>
            </div>
            <div class="card-sub" style="margin-top: 16px;">Setiap foto nota dikompresi otomatis di bawah 200 KB sebelum upload.</div>
        </div>
    </section>

    <section class="download-banner container" id="download">
        <h2>Unduh AKeep untuk Android</h2>
        <p>Build terbaru tersedia via GitHub Releases. Android SDK 21+ (Lollipop ke atas).</p>
        <a href="https://github.com/anomalyco/akeep/releases" class="btn btn-primary">Download APK — v1.0.0</a>
    </section>

    <footer>
        <div class="container footer-inner">
            <span>AKeep · Personal Asset Tracker</span>
            <span style="font-family: 'JetBrains Mono', monospace;">v1.0.0 · OFFLINE-FIRST</span>
        </div>
    </footer>
</body>
</html>

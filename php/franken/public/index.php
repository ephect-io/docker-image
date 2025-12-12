<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>FrankenPHP Test</title>
    <style>
        * { margin: 0; padding: 0; box-sizing: border-box; }
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Oxygen, Ubuntu, Cantarell, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            min-height: 100vh;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 20px;
        }
        .container {
            background: white;
            border-radius: 20px;
            box-shadow: 0 20px 60px rgba(0,0,0,0.3);
            padding: 40px;
            max-width: 800px;
            width: 100%;
        }
        h1 {
            color: #333;
            margin-bottom: 20px;
            font-size: 2.5em;
        }
        .info {
            background: #f7fafc;
            border-left: 4px solid #667eea;
            padding: 20px;
            margin: 20px 0;
            border-radius: 8px;
        }
        .info h2 {
            color: #667eea;
            margin-bottom: 10px;
        }
        .info-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 15px;
            margin-top: 10px;
        }
        .info-item {
            background: white;
            padding: 15px;
            border-radius: 8px;
            box-shadow: 0 2px 4px rgba(0,0,0,0.1);
        }
        .info-item strong {
            color: #764ba2;
            display: block;
            margin-bottom: 5px;
        }
        .success {
            color: #48bb78;
            font-weight: bold;
        }
        code {
            background: #2d3748;
            color: #68d391;
            padding: 2px 6px;
            border-radius: 4px;
            font-size: 0.9em;
        }
    </style>
</head>
<body>
    <div class="container">
        <h1>🚀 FrankenPHP is Running!</h1>
        
        <div class="info">
            <h2>Server Information</h2>
            <div class="info-grid">
                <div class="info-item">
                    <strong>PHP Version</strong>
                    <?php echo PHP_VERSION; ?>
                </div>
                <div class="info-item">
                    <strong>Server Software</strong>
                    <?php echo $_SERVER['SERVER_SOFTWARE'] ?? 'N/A'; ?>
                </div>
                <div class="info-item">
                    <strong>Protocol</strong>
                    <?php echo $_SERVER['SERVER_PROTOCOL'] ?? 'N/A'; ?>
                </div>
                <div class="info-item">
                    <strong>Request Method</strong>
                    <?php echo $_SERVER['REQUEST_METHOD'] ?? 'N/A'; ?>
                </div>
            </div>
        </div>

        <div class="info">
            <h2>FrankenPHP Features</h2>
            <div class="info-grid">
                <div class="info-item">
                    <strong>HTTP/2</strong>
                    <span class="success">✓ Enabled</span>
                </div>
                <div class="info-item">
                    <strong>HTTP/3</strong>
                    <span class="success">✓ Enabled</span>
                </div>
                <div class="info-item">
                    <strong>Early Hints</strong>
                    <span class="success">✓ Supported</span>
                </div>
                <div class="info-item">
                    <strong>Workers</strong>
                    <span class="success">✓ Available</span>
                </div>
            </div>
        </div>

        <div class="info">
            <h2>Loaded Extensions</h2>
            <div class="info-grid">
                <?php
                $extensions = get_loaded_extensions();
                $important = ['xdebug', 'zip', 'pdo', 'pdo_mysql', 'pdo_pgsql', 'opcache', 'intl', 'gd'];
                foreach ($important as $ext) {
                    $loaded = extension_loaded($ext);
                    echo '<div class="info-item">';
                    echo '<strong>' . htmlspecialchars($ext) . '</strong>';
                    echo $loaded ? '<span class="success">✓ Loaded</span>' : '<span>✗ Not loaded</span>';
                    echo '</div>';
                }
                ?>
            </div>
        </div>

        <div class="info">
            <h2>Quick Links</h2>
            <ul style="list-style: none; padding: 0;">
                <li style="margin: 10px 0;">
                    📚 <a href="https://frankenphp.dev/docs/" target="_blank" style="color: #667eea;">FrankenPHP Documentation</a>
                </li>
                <li style="margin: 10px 0;">
                    🔧 <a href="/phpinfo.php" style="color: #667eea;">PHP Info</a> (if available)
                </li>
                <li style="margin: 10px 0;">
                    ⚡ <a href="/worker" style="color: #667eea;">Worker Demo</a> (if configured)
                </li>
            </ul>
        </div>
    </div>
</body>
</html>

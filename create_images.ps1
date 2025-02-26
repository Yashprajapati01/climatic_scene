# Add System.Drawing assembly
Add-Type -AssemblyName System.Drawing

# Create the assets/images directory if it doesn't exist
$imagesDir = "assets\images"
if (-not (Test-Path $imagesDir)) {
    New-Item -Path $imagesDir -ItemType Directory -Force | Out-Null
}

# Image dimensions
$width = 800
$height = 600

# Function to create a gradient image with text and visual elements
function Create-EnhancedWeatherImage {
    param(
        [string]$fileName,
        [System.Drawing.Color]$startColor,
        [System.Drawing.Color]$endColor,
        [string]$text,
        [string]$weatherType
    )
    
    $fullPath = Join-Path $imagesDir $fileName
    
    # Create bitmap and graphics object
    $bitmap = New-Object System.Drawing.Bitmap($width, $height)
    $graphics = [System.Drawing.Graphics]::FromImage($bitmap)
    
    # Enable anti-aliasing for smoother graphics
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $graphics.TextRenderingHint = [System.Drawing.Text.TextRenderingHint]::AntiAlias
    
    # Create gradient brush
    $rect = New-Object System.Drawing.Rectangle(0, 0, $width, $height)
    $brush = New-Object System.Drawing.Drawing2D.LinearGradientBrush(
        $rect, 
        $startColor, 
        $endColor, 
        [System.Drawing.Drawing2D.LinearGradientMode]::Vertical)
    
    # Fill with gradient
    $graphics.FillRectangle($brush, $rect)
    
    # Add weather-specific visual elements
    Add-WeatherElements -graphics $graphics -weatherType $weatherType
    
    # Add text with shadow for better readability
    $font = New-Object System.Drawing.Font("Arial", 42, [System.Drawing.FontStyle]::Bold)
    
    # Create shadow effect
    $shadowOffset = 3
    $shadowBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(100, 0, 0, 0))
    $shadowRect = New-Object System.Drawing.RectangleF($shadowOffset, $shadowOffset, $width, $height)
    $stringFormat = New-Object System.Drawing.StringFormat
    $stringFormat.Alignment = [System.Drawing.StringAlignment]::Center
    $stringFormat.LineAlignment = [System.Drawing.StringAlignment]::Center
    
    # Draw shadow text
    $graphics.DrawString($text, $font, $shadowBrush, $shadowRect, $stringFormat)
    
    # Draw main text
    $textBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::White)
    $graphics.DrawString($text, $font, $textBrush, $rect, $stringFormat)
    
    # Save image
    $bitmap.Save($fullPath, [System.Drawing.Imaging.ImageFormat]::Jpeg)
    
    # Dispose of resources
    $graphics.Dispose()
    $bitmap.Dispose()
    $brush.Dispose()
    $textBrush.Dispose()
    $shadowBrush.Dispose()
    
    Write-Host "Created $fileName"
}

# Function to add weather-specific elements
function Add-WeatherElements {
    param (
        [System.Drawing.Graphics]$graphics,
        [string]$weatherType
    )
    
    switch ($weatherType) {
        "clear" {
            # Draw sun
            $sunBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(255, 255, 220, 0))
            $sunPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(255, 255, 200, 0), 3)
            
            # Draw sun circle
            $sunX = $width * 0.75
            $sunY = $height * 0.25
            $sunRadius = 60
            $graphics.FillEllipse($sunBrush, $sunX - $sunRadius, $sunY - $sunRadius, $sunRadius * 2, $sunRadius * 2)
            
            # Draw sun rays
            $rayLength = 40
            for ($i = 0; $i -lt 8; $i++) {
                $angle = $i * [Math]::PI / 4
                $startX = $sunX + ($sunRadius + 5) * [Math]::Cos($angle)
                $startY = $sunY + ($sunRadius + 5) * [Math]::Sin($angle)
                $endX = $sunX + ($sunRadius + $rayLength) * [Math]::Cos($angle)
                $endY = $sunY + ($sunRadius + $rayLength) * [Math]::Sin($angle)
                $graphics.DrawLine($sunPen, $startX, $startY, $endX, $endY)
            }
            
            $sunBrush.Dispose()
            $sunPen.Dispose()
        }
        "cloudy" {
            # Draw clouds
            $cloudBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(240, 255, 255, 255))
            $cloudOutlinePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(100, 200, 200, 200), 2)
            
            # Draw multiple cloud puffs
            Draw-Cloud -graphics $graphics -x ($width * 0.3) -y ($height * 0.3) -scale 1.2 -brush $cloudBrush -pen $cloudOutlinePen
            Draw-Cloud -graphics $graphics -x ($width * 0.7) -y ($height * 0.4) -scale 1.0 -brush $cloudBrush -pen $cloudOutlinePen
            Draw-Cloud -graphics $graphics -x ($width * 0.5) -y ($height * 0.25) -scale 0.8 -brush $cloudBrush -pen $cloudOutlinePen
            
            $cloudBrush.Dispose()
            $cloudOutlinePen.Dispose()
        }
        "rainy" {
            # Draw clouds
            $cloudBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(200, 220, 220, 220))
            $cloudOutlinePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(100, 200, 200, 200), 2)
            
            Draw-Cloud -graphics $graphics -x ($width * 0.5) -y ($height * 0.25) -scale 1.5 -brush $cloudBrush -pen $cloudOutlinePen
            
            # Draw raindrops
            $rainPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(200, 70, 130, 180), 3)
            $random = New-Object System.Random
            
            for ($i = 0; $i -lt 50; $i++) {
                $rainX = $random.Next($width)
                $rainY = $random.Next(($height * 0.35), $height)
                $length = $random.Next(15, 30)
                $graphics.DrawLine($rainPen, $rainX, $rainY, $rainX - 2, $rainY + $length)
            }
            
            $cloudBrush.Dispose()
            $cloudOutlinePen.Dispose()
            $rainPen.Dispose()
        }
        "snow" {
            # Draw clouds
            $cloudBrush = New-Object System.Drawing.SolidBrush([System.Drawing.Color]::FromArgb(200, 230, 230, 230))
            $cloudOutlinePen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(100, 200, 200, 200), 2)
            
            Draw-Cloud -graphics $graphics -x ($width * 0.5) -y ($height * 0.25) -scale 1.5 -brush $cloudBrush -pen $cloudOutlinePen
            
            # Draw snowflakes
            $snowPen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(230, 255, 255, 255), 2)
            $random = New-Object System.Random
            
            for ($i = 0; $i -lt 


Add-Type -AssemblyName System.Drawing
$filePath = 'C:\Users\MONSTER\.gemini\antigravity-ide\brain\789404b1-969c-4ff4-9b86-9474ff660686\.tempmediaStorage\media_1791730324933.png'
$img = [System.Drawing.Image]::FromFile($filePath)
Write-Output "Size: $($img.Width) x $($img.Height)"
$hCrop = 120
$crop = New-Object System.Drawing.Bitmap($img.Width, $hCrop)
$g = [System.Drawing.Graphics]::FromImage($crop)
$srcRect = New-Object System.Drawing.Rectangle(0, ($img.Height - $hCrop), $img.Width, $hCrop)
$destRect = New-Object System.Drawing.Rectangle(0, 0, $img.Width, $hCrop)
$g.DrawImage($img, $destRect, $srcRect, [System.Drawing.GraphicsUnit]::Pixel)
$crop.Save('C:\Users\MONSTER\.gemini\antigravity-ide\brain\789404b1-969c-4ff4-9b86-9474ff660686\scratch\bottom_crop.png', [System.Drawing.Imaging.ImageFormat]::Png)
$g.Dispose()
$crop.Dispose()
$img.Dispose()

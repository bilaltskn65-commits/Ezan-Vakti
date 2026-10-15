$s1 = Get-Content -Raw -Encoding utf8 "c:\Users\MONSTER\OneDrive\Desktop\projects\EzanVakti\scratch\surah_1.json"
$s94 = Get-Content -Raw -Encoding utf8 "c:\Users\MONSTER\OneDrive\Desktop\projects\EzanVakti\scratch\surah_94.json"
$s112 = Get-Content -Raw -Encoding utf8 "c:\Users\MONSTER\OneDrive\Desktop\projects\EzanVakti\scratch\surah_112.json"
$s113 = Get-Content -Raw -Encoding utf8 "c:\Users\MONSTER\OneDrive\Desktop\projects\EzanVakti\scratch\surah_113.json"
$s114 = Get-Content -Raw -Encoding utf8 "c:\Users\MONSTER\OneDrive\Desktop\projects\EzanVakti\scratch\surah_114.json"

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("// Populer sureler icin cevrimdisi hazir ayet verileri")
[void]$sb.AppendLine("// Ilk acilista veya internetsiz ortamda bu sureler aninda acilir.")
[void]$sb.AppendLine("const Map<int, String> kBundledSurahsJson = {")

$writeSurah = {
    param($num, $json)
    $cleanJson = $json.Trim().Replace("\", "\\").Replace("'", "\'")
    [void]$sb.AppendLine("  ${num}: '$cleanJson',")
}

& $writeSurah 1 $s1
& $writeSurah 94 $s94
& $writeSurah 112 $s112
& $writeSurah 113 $s113
& $writeSurah 114 $s114

[void]$sb.AppendLine("};")

[System.IO.File]::WriteAllText("c:\Users\MONSTER\OneDrive\Desktop\projects\EzanVakti\lib\core\constants\bundled_ayahs_data.dart", $sb.ToString(), [System.Text.Encoding]::UTF8)
Write-Output "Generated bundled_ayahs_data.dart successfully."

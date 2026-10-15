$surahTurkishNames = @(
    "", # 0 index dummy
    "Fâtiha", "Bakara", "Âl-i İmrân", "Nisâ", "Mâide", "En'âm", "A'râf", "Enfâl", "Tevbe", "Yûnus",
    "Hûd", "Yûsuf", "Ra'd", "İbrâhîm", "Hicr", "Nahl", "İsrâ", "Kehf", "Meryem", "Tâhâ",
    "Enbiyâ", "Hac", "Mü'minûn", "Nûr", "Furkân", "Şuarâ", "Neml", "Kasas", "Ankebût", "Rûm",
    "Lokmân", "Secde", "Ahzâb", "Sebe'", "Fâtır", "Yâsîn", "Sâffât", "Sâd", "Zümer", "Mü'min (Gâfir)",
    "Fussilet", "Şûrâ", "Zuhruf", "Duhân", "Câsiye", "Ahkâf", "Muhammed", "Fetih", "Hucurât", "Kâf",
    "Zâriyât", "Tûr", "Necm", "Kamer", "Rahmân", "Vâkıa", "Hadîd", "Mücâdele", "Haşr", "Mümtehine",
    "Saf", "Cum'a", "Münâfikûn", "Tegâbün", "Talâk", "Tahrîm", "Mülk", "Kalem", "Hâkka", "Meâric",
    "Nûh", "Cin", "Müzzemmil", "Müddessir", "Kıyâme", "İnsân", "Mürselât", "Nebe'", "Nâziât", "Abese",
    "Tekvîr", "İnfitâr", "Mutaffifîn", "İnşikâk", "Bürûc", "Târık", "A'lâ", "Gâşiye", "Fecr", "Beled",
    "Şems", "Leyl", "Duhâ", "İnşirâh", "Tîn", "Alak", "Kadir", "Beyyine", "Zilzâl", "Âdiyât",
    "Kâria", "Tekâsür", "Asr", "Hümeze", "Fîl", "Kureyş", "Mâûn", "Kevser", "Kâfirûn", "Nasr",
    "Tebbet", "İhlâs", "Felak", "Nâs"
)

$jsonContent = Get-Content -Raw -Encoding utf8 "c:\Users\MONSTER\OneDrive\Desktop\projects\EzanVakti\scratch\surahs_raw.json"
$parsed = ConvertFrom-Json $jsonContent

$sb = New-Object System.Text.StringBuilder
[void]$sb.AppendLine("// 114 Kuran-ı Kerim Suresi Çevrimdışı Sabit Veritabanı")
[void]$sb.AppendLine("// Bu veri sayesinde internet olmasa dahi tüm sureler 0ms içinde anında listelenir.")
[void]$sb.AppendLine("import '../../models/surah_model.dart';")
[void]$sb.AppendLine("")
[void]$sb.AppendLine("const List<SurahModel> kAllSurahs = [")

foreach ($item in $parsed.data) {
    $num = $item.number
    $nameAr = $item.name
    $trName = $surahTurkishNames[$num]
    if (-not $trName) { $trName = $item.englishName }
    $enTranslation = $item.englishNameTranslation.Replace("'", "\'")
    $ayahs = $item.numberOfAyahs
    $rev = $item.revelationType
    
    [void]$sb.AppendLine("  SurahModel(")
    [void]$sb.AppendLine("    number: $num,")
    [void]$sb.AppendLine("    nameAr: '$nameAr',")
    [void]$sb.AppendLine("    nameTr: '$trName',")
    [void]$sb.AppendLine("    englishNameTranslation: '$enTranslation',")
    [void]$sb.AppendLine("    numberOfAyahs: $ayahs,")
    [void]$sb.AppendLine("    revelationType: '$rev',")
    [void]$sb.AppendLine("  ),")
}

[void]$sb.AppendLine("];")

[System.IO.File]::WriteAllText("c:\Users\MONSTER\OneDrive\Desktop\projects\EzanVakti\lib\core\constants\quran_surahs_data.dart", $sb.ToString(), [System.Text.Encoding]::UTF8)
Write-Output "Successfully generated quran_surahs_data.dart with $($parsed.data.Count) surahs."

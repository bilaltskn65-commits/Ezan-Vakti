const fs = require('fs');

const s1 = fs.readFileSync('assets/surahs/1.json', 'utf8');
const s94 = fs.readFileSync('assets/surahs/94.json', 'utf8');
const s112 = fs.readFileSync('assets/surahs/112.json', 'utf8');
const s113 = fs.readFileSync('assets/surahs/113.json', 'utf8');
const s114 = fs.readFileSync('assets/surahs/114.json', 'utf8');

function escapeDart(str) {
  return str.replace(/\\/g, '\\\\').replace(/'/g, "\\'").replace(/\$/g, '\\$');
}

const content = `// Populer sureler icin cevrimdisi hazir ayet verileri
// Ilk acilista veya internetsiz ortamda bu sureler aninda acilir.
const Map<int, String> kBundledSurahsJson = {
  1: '${escapeDart(s1)}',
  94: '${escapeDart(s94)}',
  112: '${escapeDart(s112)}',
  113: '${escapeDart(s113)}',
  114: '${escapeDart(s114)}',
};
`;

fs.writeFileSync('lib/core/constants/bundled_ayahs_data.dart', content, 'utf8');
console.log('bundled_ayahs_data.dart updated successfully.');

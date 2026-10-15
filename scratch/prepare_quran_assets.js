const https = require('https');
const fs = require('fs');
const path = require('path');

const outDir = path.join(__dirname, '..', 'assets', 'surahs');
if (!fs.existsSync(outDir)) {
  fs.mkdirSync(outDir, { recursive: true });
}

function fetchJson(url) {
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      let data = '';
      res.on('data', chunk => data += chunk);
      res.on('end', () => {
        try {
          resolve(JSON.parse(data));
        } catch (e) {
          reject(e);
        }
      });
    }).on('error', reject);
  });
}

async function run() {
  console.log('Downloading Arabic Quran...');
  const arData = await fetchJson('https://api.alquran.cloud/v1/quran/quran-uthmani');
  console.log('Downloading Turkish Quran...');
  const trData = await fetchJson('https://api.alquran.cloud/v1/quran/tr.diyanet');

  const arSurahs = arData.data.surahs;
  const trSurahs = trData.data.surahs;

  console.log(`Processing ${arSurahs.length} surahs...`);
  for (let i = 0; i < arSurahs.length; i++) {
    const arSurah = arSurahs[i];
    const trSurah = trSurahs[i];
    const surahNumber = arSurah.number;

    const combined = {
      code: 200,
      status: 'OK',
      data: [
        {
          number: arSurah.number,
          name: arSurah.name,
          englishName: arSurah.englishName,
          englishNameTranslation: arSurah.englishNameTranslation,
          revelationType: arSurah.revelationType,
          numberOfAyahs: arSurah.numberOfAyahs,
          ayahs: arSurah.ayahs,
          edition: arData.data.edition
        },
        {
          number: trSurah.number,
          name: trSurah.name,
          englishName: trSurah.englishName,
          englishNameTranslation: trSurah.englishNameTranslation,
          revelationType: trSurah.revelationType,
          numberOfAyahs: trSurah.numberOfAyahs,
          ayahs: trSurah.ayahs,
          edition: trData.data.edition
        }
      ]
    };

    const filePath = path.join(outDir, `${surahNumber}.json`);
    fs.writeFileSync(filePath, JSON.stringify(combined), 'utf8');
  }

  console.log('Successfully generated all 114 surah asset files in assets/surahs/');
}

run().catch(console.error);

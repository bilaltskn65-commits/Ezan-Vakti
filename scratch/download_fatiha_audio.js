const https = require('https');
const fs = require('fs');
const path = require('path');

const dir = path.join(__dirname, '..', 'assets', 'audio');
if (!fs.existsSync(dir)) fs.mkdirSync(dir, { recursive: true });

function download(surah, ayah) {
  const sStr = String(surah).padStart(3, '0');
  const aStr = String(ayah).padStart(3, '0');
  const file = path.join(dir, `${sStr}${aStr}.mp3`);
  const url = `https://www.everyayah.com/data/Alafasy_128kbps/${sStr}${aStr}.mp3`;
  return new Promise((resolve, reject) => {
    https.get(url, (res) => {
      if (res.statusCode !== 200) {
        console.error(`Error ${res.statusCode} for ${url}`);
        resolve();
        return;
      }
      const stream = fs.createWriteStream(file);
      res.pipe(stream);
      stream.on('finish', () => {
        stream.close();
        console.log(`Downloaded ${sStr}${aStr}.mp3 (${fs.statSync(file).size} bytes)`);
        resolve();
      });
    }).on('error', (err) => {
      console.error(err);
      resolve();
    });
  });
}

async function main() {
  console.log('Downloading Fatiha audio...');
  for (let i = 1; i <= 7; i++) {
    await download(1, i);
  }
  // Also download popular short surahs: Ihlas 112 (4 ayahs), Falaq 113 (5 ayahs), Nas 114 (6 ayahs)
  console.log('Downloading Ihlas audio...');
  for (let i = 1; i <= 4; i++) {
    await download(112, i);
  }
  console.log('Downloading Falaq audio...');
  for (let i = 1; i <= 5; i++) {
    await download(113, i);
  }
  console.log('Downloading Nas audio...');
  for (let i = 1; i <= 6; i++) {
    await download(114, i);
  }
  console.log('Done downloading offline audio files!');
}

main();

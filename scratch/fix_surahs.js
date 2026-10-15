const fs = require('fs');

let content = fs.readFileSync('lib/core/constants/quran_surahs_data.dart', 'utf8');

// Process lines one by one
const lines = content.split(/\r?\n/);
const processedLines = lines.map(line => {
  const trimmed = line.trim();
  // match: nameTr: 'something', or englishNameTranslation: 'something',
  const propMatch = line.match(/^(\s*)(nameTr|englishNameTranslation|nameAr|revelationType):\s*(.+),?$/);
  if (propMatch) {
    const indent = propMatch[1];
    const key = propMatch[2];
    let valPart = propMatch[3].trim();
    if (valPart.endsWith(',')) {
      valPart = valPart.slice(0, -1).trim();
    }
    
    // Strip existing outer single or double quotes
    if ((valPart.startsWith("'") && valPart.endsWith("'")) || (valPart.startsWith('"') && valPart.endsWith('"'))) {
      const inner = valPart.substring(1, valPart.length - 1);
      // Escape any unescaped double quotes inside inner
      const cleaned = inner.replace(/\\"/g, '"').replace(/"/g, '\\"');
      return `${indent}${key}: "${cleaned}",`;
    }
  }
  return line;
});

fs.writeFileSync('lib/core/constants/quran_surahs_data.dart', processedLines.join('\n'), 'utf8');
console.log('Successfully fixed quotes in quran_surahs_data.dart');

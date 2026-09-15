const fs = require('fs');
const path = require('path');

const targetDir = path.join(__dirname, '..', 'assets', 'images');
if (!fs.existsSync(targetDir)) {
  fs.mkdirSync(targetDir, { recursive: true });
}

const srcBanner = 'C:\\Users\\luiza\\.gemini\\antigravity-ide\\brain\\d8ea47f2-9650-4305-b6b5-350ab37dee43\\.user_uploaded\\media_1789430010600.jpg';
const srcLogo = 'C:\\Users\\luiza\\.gemini\\antigravity-ide\\brain\\d8ea47f2-9650-4305-b6b5-350ab37dee43\\.user_uploaded\\media_1789430010631.jpg';

fs.copyFileSync(srcBanner, path.join(targetDir, 'banner_semob.jpg'));
fs.copyFileSync(srcLogo, path.join(targetDir, 'logo_prefeitura.jpg'));

console.log('Assets copiados com sucesso para assets/images/');

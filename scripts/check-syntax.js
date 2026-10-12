const fs = require('node:fs');
const path = require('node:path');
const { spawnSync } = require('node:child_process');

const root = path.resolve(__dirname, '..');

function findJavaScriptFiles(directory) {
    return fs.readdirSync(directory, { withFileTypes: true }).flatMap(entry => {
        const filename = path.join(directory, entry.name);
        if (entry.isDirectory()) return findJavaScriptFiles(filename);
        return entry.name.endsWith('.js') ? [filename] : [];
    });
}

const files = [path.join(root, 'index.js')];
for (const folder of ['src', 'scripts', 'tests']) {
    files.push(...findJavaScriptFiles(path.join(root, folder)));
}

for (const filename of files) {
    const result = spawnSync(process.execPath, ['--check', filename], { stdio: 'inherit' });
    if (result.error) throw result.error;
    if (result.status !== 0) process.exit(result.status || 1);
}
console.log(`Cú pháp hợp lệ: ${files.length} file JavaScript.`);

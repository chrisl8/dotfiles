// https://ocrmypdf.readthedocs.io/en/latest/cookbook.html#ocr-images-not-pdfs

import fs from 'fs/promises';
import { spawn } from 'child_process';
import * as path from 'node:path';

const inputPath = `/mnt/d/OCR`;

// eslint-disable-next-line consistent-return
async function listFolderContents(folderPath) {
  try {
    return await fs.readdir(folderPath);
  } catch (err) {
    console.error('Error occurred while reading directory:', err);
  }
}

async function spawnChild({ command, argumentList = [] }) {
  const child = spawn(command, argumentList);

  child.on('error', (err) => {
    console.error(`Failed to start subprocess: ${err}`);
  });

  let data = '';
  for await (const chunk of child.stdout) {
    // console.log(`stdout chunk: ${chunk}`);
    data += chunk;
  }
  let error = '';
  for await (const chunk of child.stderr) {
    // console.error(`stderr chunk: ${chunk}`);
    error += chunk;
  }
  const exitCode = await new Promise((resolve) => {
    child.on('close', resolve);
  });

  return { data, exitCode, error };
}

const binaryCheckResult = await spawnChild({
  command: 'img2pdf',
  argumentList: ['--version'],
});
if (binaryCheckResult.data === '' || binaryCheckResult.exitCode !== 0) {
  console.error('img2pdf not found');
  process.exit(1);
}

const folderContents = await listFolderContents(inputPath);

if (!folderContents || folderContents.length < 1) {
  console.log('No files found in the directory');
  process.exit(1);
}

console.log(`Processing ${folderContents.length} files...`);

function cleanedResultOutput(result) {
  result.split('\n').forEach((line) => {
    if (line && line !== '') {
      console.log(`  ${line}`);
    }
  });
}

// Convert all Image files to PDF.
for await (const file of folderContents) {
  const extension = path.extname(file);
  if (['.png', '.jpg'].indexOf(extension) === -1) {
    console.error(`Skipping non-Image file: ${file}`);
    // eslint-disable-next-line no-continue
    continue;
  }

  // Get and save file timestamp
  const { mtime } = await fs.stat(`${inputPath}/${file}`);

  const { data, exitCode, error } = await spawnChild({
    command: 'img2pdf',
    argumentList: [
      '-o',
      `${inputPath}/${file.replace(extension, '.pdf')}`,
      `${inputPath}/${file}`,
    ],
  });
  if (data) {
    console.log(`Unexpected stdout received for ${file}:`);
    console.log(data);
  }

  if (exitCode === 0) {
    console.log(`${file} - SUCCESS`);
    cleanedResultOutput(error);
  } else {
    console.log(`${file} - Unknown Error`);
    if (exitCode) {
      console.error(`  Exit code for ${file}: ${exitCode}`);
    }
    cleanedResultOutput(error);
  }

  // Reset timestamp on new file to match old file
  await fs.utimes(
    `${inputPath}/${file.replace(extension, '.pdf')}`,
    mtime,
    mtime,
  );
}

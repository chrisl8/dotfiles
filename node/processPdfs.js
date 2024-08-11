/* eslint-disable no-await-in-loop */
// https://github.com/ocrmypdf/OCRmyPDF

import fs from 'fs/promises';
import { spawn } from 'child_process';
import path from 'node:path';
import esMain from 'es-main';
import consoleTextColors from './consoleTextColors.js';

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
  command: 'ocrmypdf',
  argumentList: ['--version'],
});
if (binaryCheckResult.data === '' || binaryCheckResult.exitCode !== 0) {
  console.error(
    'ocrmypdf not found, did you source the environment?\nsource ~/OCR/.venv/bin/activate',
  );
  process.exit(1);
}

async function processPdfs(inputPath) {
  const folderContents = await listFolderContents(inputPath);

  if (!folderContents || folderContents.length < 1) {
    console.log('No files found in the directory');
    process.exit(1);
  }

  console.log(`Processing ${folderContents.length} files...`);

  function cleanedResultOutput(result) {
    result.split('\n').forEach((line) => {
      if (
        line &&
        line !== '' &&
        !line.includes('Start processing ') &&
        line !== 'Postprocessing...' &&
        line !==
          'Image optimization did not improve the file - optimizations will not be used' &&
        !line.includes('Image optimization ratio:') &&
        !line.includes('Total file size ratio: ') &&
        !line.includes(
          'Some input metadata could not be copied because it is not permitted in PDF/A.',
        ) &&
        !line.includes('Output file is a PDF/A-2B (as expected)')
      ) {
        console.log(`  ${line}`);
      }
    });
  }

  // Perform OCR on all PDFs in the folder
  for await (const file of folderContents) {
    const extension = path.extname(file);
    if (['.pdf'].indexOf(extension.toLowerCase()) === -1) {
      console.error(`Skipping non-PDF file: ${file}`);
      // eslint-disable-next-line no-continue
      continue;
    }

    // Get and save file timestamp
    const { mtime } = await fs.stat(`${inputPath}/${file}`);

    const { data, exitCode, error } = await spawnChild({
      command: 'ocrmypdf',
      argumentList: [
        '--sidecar',
        // '--output-type',
        // 'pdf',
        '--tesseract-timeout',
        '3600', // ocrmypdf defaults to killing tesseract after 180 seconds, but why?
        '--clean', // I think this should help.
        `${inputPath}/${file}`,
        `${inputPath}/${file.replace(extension, '_ocr.pdf')}`,
      ],
    });
    if (data) {
      // ocrmypdf never puts anything in stdout, only stderr.
      // https://ocrmypdf.readthedocs.io/en/latest/advanced.html#return-code-policy
      // "OCRmyPDF writes all messages to stderr. stdout is reserved for piping output files. stdin is reserved for piping input files."
      // So this never happens.
      console.log(`Unexpected stdout received for ${file}:`);
      console.log(data);
    }
    const ocrFileName = `${file.replace(extension, '_ocr.pdf')}`;

    // Some of these "errors" still result in exit code 0, so I check for them first.
    if (
      error.includes('page already has text') ||
      error.includes('This PDF is marked as a Tagged PDF.')
    ) {
      console.log(
        `${consoleTextColors.FgCyan}${file} - Already Has Text${consoleTextColors.Reset}`,
      );
    } else if (error.includes('The generated PDF is INVALID')) {
      console.log(
        `${consoleTextColors.FgRed}${file} - Invalid PDF Output${consoleTextColors.Reset}`,
      );
      console.error(error);
    } else if (error.includes('possibly poor OCR')) {
      console.log(
        `${consoleTextColors.FgYellow}${file} - Possibly Poor OCR${consoleTextColors.Reset}`,
      );
    } else if (error.includes('Input PDF is encrypted.')) {
      console.log(
        `${consoleTextColors.FgRed}${file} - Encrypted PDF${consoleTextColors.Reset}`,
      );
      await spawnChild({
        command: 'qpdf',
        argumentList: [
          '--decrypt',
          `${inputPath}/${file}`,
          `${inputPath}/${file.replace(extension, '_decrypted.pdf')}`,
        ],
      });
    } else if (exitCode === 0) {
      console.log(
        `${consoleTextColors.FgGreen}${file} - SUCCESS${consoleTextColors.Reset}`,
      );
      cleanedResultOutput(error);
    } else {
      console.log(
        `${consoleTextColors.FgRed}${file} - Unknown Error${consoleTextColors.Reset}`,
      );
      if (exitCode) {
        console.error(`  Exit code for ${file}: ${exitCode}`);
      }
      cleanedResultOutput(error);
    }

    let decryptedFileExits;
    try {
      decryptedFileExits = await fs.stat(
        `${inputPath}/${file.replace(extension, '_decrypted.pdf')}`,
      );
    } catch {}
    if (decryptedFileExits) {
      await fs.mkdir(`${inputPath}/original`, { recursive: true });
      await fs.rename(`${inputPath}/${file}`, `${inputPath}/original/${file}`);
      // Reset timestamp on new file to match old file
      await fs.utimes(
        `${inputPath}/${file.replace(extension, '_decrypted.pdf')}`,
        mtime,
        mtime,
      );
    }

    let ocrFileExits;
    try {
      ocrFileExits = await fs.stat(`${inputPath}/${ocrFileName}`);
    } catch {}
    if (ocrFileExits) {
      await fs.mkdir(`${inputPath}/original`, { recursive: true });
      await fs.rename(`${inputPath}/${file}`, `${inputPath}/original/${file}`);
      // Reset timestamp on new file to match old file
      await fs.utimes(`${inputPath}/${ocrFileName}`, mtime, mtime);
    }

    let txtFileExits;
    try {
      txtFileExits = await fs.stat(`${inputPath}/${ocrFileName}.txt`);
    } catch {}
    if (txtFileExits) {
      // Reset timestamp on text file to match old PDF file
      await fs.utimes(`${inputPath}/${ocrFileName}.txt`, mtime, mtime);
    }
  }
}

if (esMain(import.meta)) {
  if (process.argv.length > 2) {
    console.log(`Processing PDFs in folder ${process.argv[2]}`);
    await processPdfs(process.argv[2]);
  } else {
    console.log(`You specify a path to the PDFs to process.`);
    console.log(`node processPdfs.js /mnt/d/Dropbox/ScanHere`);
    console.log(
      `You can use find and xargs to run on a folder and its subfolders:`,
    );
    console.log(
      `find /mnt/d/Dropbox/ScanHere -type d | xargs -n 1 -d '\\n' node processPdfs.js`,
    );
  }
}

const { exec } = require("child_process");
const fs = require("fs");
const path = require("path");

const archiver = require("archiver");

const DB_NAME = "test";
const BACKUP_PATH = path.join(__dirname, "backups"); 
const DATE = new Date().toISOString().slice(0, 10); 

if (!fs.existsSync(BACKUP_PATH)) {
  fs.mkdirSync(BACKUP_PATH);
}

// File name for the backup
const backupFileGz = path.join(BACKUP_PATH, `${DB_NAME}_backup_${DATE}.gz`);
const backupFileZip = path.join(BACKUP_PATH, `${DB_NAME}_backup_${DATE}.zip`);

// Command to run the backup
const command = `mongodump --db ${DB_NAME} --archive=${backupFileGz} --gzip`;


function compressToZip(inputFile, outputFile) {
   return new Promise((resolve, reject) => {
     const output = fs.createWriteStream(outputFile);
     const archive = archiver("zip", { zlib: { level: 9 } });
 
     output.on("close", () => {
       console.log(`Compressed ${inputFile} to ${outputFile}`);
       resolve();
     });
 
     archive.on("error", (err) => reject(err));
 
     archive.pipe(output);
     archive.file(inputFile, { name: path.basename(inputFile) });
     archive.finalize();
   });
 }

async function sendBackupToTelegram(backupFile) {
   const url = `https://api.telegram.org/bot<bot-token>/sendDocument`;
   const fileStream = fs.createReadStream(backupFile);
   const formData = new FormData();
   formData.append("chat_id", chat_id);
   formData.append("document", fileStream);
   
   try {
     const response = await fetch(url, { method: "POST", body: formData });
     const data = await response.json();
     if (data.ok) {
       console.log("Backup file sent successfully!");
     } else {
       console.error("Failed to send backup:", data.description);
     }
   } catch (error) {
     console.error("Error sending backup:", error.message);
   }
 }

exec(command, async (error, stdout, stderr) => {
  if (error) {
    console.error(`Error creating backup: ${error.message}`);
    return;
  }

  if (stderr) {
    if (stderr.toLowerCase().includes("error")) {
      console.error(`Backup process error: ${stderr}`);
    } else {
      console.log(`Backup process log:\n${stderr}`);
    }
  }
  
  
  try {
   await compressToZip(backupFileGz, backupFileZip);
   console.log(`Compressed backup to ${backupFileZip}`);

   await sendBackupToTelegram(backupFileZip);
   } catch (compressError) {
      console.error(`Error compressing to .zip: ${compressError.message}`);
   }

});

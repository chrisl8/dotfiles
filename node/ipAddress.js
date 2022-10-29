import os from "os";
import esMain from "es-main";
import { spawnSync } from "child_process";

const interfaces = os.networkInterfaces();

const ipAddress = () => {
  let ip = false;
  if (`${os.release()}`.includes("WSL")) {
    const { stdout } = spawnSync("/mnt/c/Windows/System32/ipconfig.exe");
    const ipconfigOutput = stdout.toString().split("\r\n");
    for (let i = 0; i < ipconfigOutput.length; i++) {
      if (ipconfigOutput[i].includes("IPv4")) {
        ip = ipconfigOutput[i].split(":")[1].trim();
        break;
      }
    }
  } else {
    let firstInterface;
    for (const networkInterface in interfaces) {
      if (
        interfaces.hasOwnProperty(networkInterface) &&
        networkInterface !== "lo" &&
        firstInterface === undefined
      ) {
        firstInterface = networkInterface;
      }
    }
    if (firstInterface) {
      ip = interfaces[firstInterface][0].address;
    }
  }
  return ip;
};

export default ipAddress;

if (esMain(import.meta)) {
  console.log(ipAddress());
}

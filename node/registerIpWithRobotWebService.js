import os from "os";
import ipAddress from "./ipAddress.js";
import { configData } from "./configData.js";

const url = `${configData.cloudServer.address}addHostname`;
const ip = ipAddress();
const hostname = os.hostname();
const body = { hostname, ip };
if (configData.webServerPort && configData.webServerPort !== 80) {
  // No point in adding port 80.
  body.port = configData.webServerPort;
}
const password = Buffer.from(
  `ignored:${configData.cloudServer.password}`
).toString("base64");
try {
  const result = await fetch(url, {
    method: "post",
    body: JSON.stringify(body),
    headers: {
      "Content-Type": "application/json",
      Authorization: `Basic ${password}`,
    },
  });

  if (result.ok) {
    console.log("Cloud Server updated, connect to local site via:");
    console.log(`${configData.cloudServer.address}redirect/${hostname}`);
  } else {
    console.error("Error connecting to Cloud Server:");
    console.error(result);
  }
} catch (e) {
  console.error("Error connecting to Cloud Server:");
  console.error(e);
}

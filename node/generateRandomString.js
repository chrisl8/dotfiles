/* eslint-disable no-param-reassign */
import crypto from 'crypto';
import esMain from "es-main";

function getRandomIntInclusive(min, max) {
    const randomBuffer = new Uint32Array(1);

    crypto.getRandomValues(randomBuffer);

    const randomNumber = randomBuffer[0] / (0xffffffff + 1);

    min = Math.ceil(min);
    max = Math.floor(max);
    return Math.floor(randomNumber * (max - min + 1)) + min;
}

function makeid(length) {
    let text = "";
    const possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890";

    for (let i = 0; i < length; i++) {
        text += possible.charAt(getRandomIntInclusive(0, possible.length - 1));
    }

    return text;
}

if (esMain(import.meta)) {
    if (process.argv.length > 2) {
        console.log(makeid(process.argv[2]));
    } else {
        console.log(`You must include a length.`)
    }
}

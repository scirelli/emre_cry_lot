#!/usr/bin/env node
let { formatsByName, formatsByCoinType } = require('@ensdomains/address-encoder');

const str = 'bc1q4at0j6q56c2jytse278939dpv3q7tz63uw4de4';
const data = formatsByName['BTC'].decoder(str);

console.log(str);
console.log(data);
console.log(data.toString('hex'));

const addr = formatsByCoinType[0].encoder(data);
console.log(addr);

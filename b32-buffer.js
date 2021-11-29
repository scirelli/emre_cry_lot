#!/usr/bin/env node
const { BitcoinAddress } = require('bech32-buffer');
const address = BitcoinAddress.decode('bc1q5pucatprjrqltdp58f92mhqkfuvwpa43vhsjwpxlryude0plzyhqjkqazp');

address.hex = Buffer.from(address.data).toString('hex');
console.log(address);

#!/usr/bin/env node
var fs      = require('fs');
var service = require('blad');

var config  = JSON.parse(fs.readFileSync('./config.json'));

service.db.import(config, __dirname, process.exit);
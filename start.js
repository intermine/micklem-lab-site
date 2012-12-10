#!/usr/bin/env node
var fs      = require('fs');
var service = require('../blad/bin/blad.js');

var config  = JSON.parse(fs.readFileSync('./config.json'))

service.start(config, __dirname);
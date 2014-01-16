#!/usr/bin/env node
var fs      = require('fs');
var service = require('blad');

var config  = require('./config.json');

config.mongodb = process.env.MONGO_URL || process.env.DATABASE_URL || config.mongodb;

service.db.export(config, __dirname, process.exit);
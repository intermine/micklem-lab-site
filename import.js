#!/usr/bin/env node
var fs      = require('fs');
var service = require('blad');

var config  = require('./config.json');

config.mongodb = process.env.MONGO_URL || process.env.DATABASE_URL || config.mongodb;

service.db.import(config, __dirname, process.exit);
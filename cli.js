#!/usr/bin/env node
/*jshint node:true*/
var fs = require('fs'),
    generate = require('./index.js'),
    minimist = require('minimist'),
    schema,
    instance;

var args = minimist(process.argv.slice(2), {
    default: {
        method: 'all'
    }
});

schema = JSON.parse(fs.readFileSync(args._[0], 'utf8'));
instance = generate(schema, args);
console.log(JSON.stringify(instance, null, 4));

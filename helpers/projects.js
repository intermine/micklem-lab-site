"use strict";

let _ = require('lodash');

// Split projects into current and archived ones.
module.exports = function(data, cb) {
  let projects = { 'current': [], 'archived': [] };
  _.each(this.rel.children('/projects', 1), (p) => {
    projects[ p.archived ? 'archived' : 'current' ].push(p);
  });

  cb(null, projects);
};

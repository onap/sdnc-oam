var express = require('express');
var router = express.Router();
var dgeusers = require('../dgeusers.json');
var path = require('path');
var _ = require('lodash');

/* GET home page. */
router.get('/', function(req, res, next) {
	console.log("In route and dgeusers is: " + JSON.stringify(dgeusers));
  res.render('index', { title: 'DGE Flow Browser', dgeusers: dgeusers });
});

// GET a flow file
router.get('/listFlows/:dgeuser/:lib/:flows/:fileName', function(req, res, next) {
	console.log("Getting a file...");
	console.dir(req.params);
        // make sure we like this user
        if ( !(_.includes(dgeusers, req.params.dgeuser)) ) {
          console.log("We don't like this user!");
          res.send("No!");
          return;
        }
	filePath=path.join(__dirname, '../..', req.params.dgeuser, 'lib', 'flows', req.params.fileName);
	console.log("Getting this file: " + filePath);
	res.sendFile(filePath);
});

module.exports = router;

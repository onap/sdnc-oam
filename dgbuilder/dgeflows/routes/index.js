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
router.get('/listFlows/:dgeuser/flows/shared/:fileName', function(req, res, next) {
	var fileName =req.params.fileName;
	console.log(req.url);	
	console.log("Getting a file...");
	console.dir(req.params);
        // make sure we like this user
        if ( !(_.includes(dgeusers, req.params.dgeuser)) ) {
          console.log("Error:User " + req.params.dgeuser +  " does not exist in the dgeusers.json file.");
          res.send("No Authorized!");
          return;
        }
	//filePath=path.join(__dirname, '../../users', req.params.dgeuser,'flows/shared', req.params.fileName);
	filePath=path.join(__dirname, '../../users', req.params.dgeuser,'flows/shared', fileName );
	console.log("Getting this file: " + filePath);
	res.sendFile(filePath);
});

// GET a flow file
router.get('/listFlows/:dgeuser/flows/shared/backups/:fileName', function(req, res, next) {
	var fileName =req.params.fileName;
	console.log(req.url);	
	console.log("Getting a file...");
	console.dir(req.params);
        // make sure we like this user
        if ( !(_.includes(dgeusers, req.params.dgeuser)) ) {
          console.log("Error:User " + req.params.dgeuser +  " does not exist in the dgeusers.json file.");
          res.send("No Authorized!");
          return;
        }
	//filePath=path.join(__dirname, '../../users', req.params.dgeuser,'flows/shared', req.params.fileName);
	filePath=path.join(__dirname, '../../users', req.params.dgeuser,'flows/shared/backups', fileName );
	console.log("Getting this file: " + filePath);
	res.sendFile(filePath);
});

module.exports = router;

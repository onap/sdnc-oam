var express = require('express');
var router = express.Router();

var spawn = require('child_process').spawn;

//var util = require('util');
var fs = require('fs');
var dbRoutes = require('./dbRoutes');
var csp = require('./csp');
var multer = require('multer');
var cookieParser = require('cookie-parser');
var csrf = require('csurf');
var bodyParser = require('body-parser');
//var sax = require('sax'),strict=true,parser = sax.parser(strict);
var async = require('async');


// SVC_LOGIC table columns
var _module=''; // cannot use module its a reserved word
var version='';
var rpc='';
var mode='';
var xmlfile='';


// used for file upload button, retain original file name
//router.use(bodyParser());
var csrfProtection = csrf({cookie: true});
router.use(bodyParser.urlencoded({ extended: true }));
//var upload = multer({ dest: process.cwd() + '/uploads/', rename: function(fieldname,filename){ return filename; } });

// multer 1.1
var storage = multer.diskStorage({
  destination: function (req, file, cb) {
    cb(null, process.cwd() + '/uploads/')
  },
  filename: function (req, file, cb) {
    cb(null, file.originalname )
  }
});

var upload = multer({
    storage: storage
});


/*
router.use(multer({
	dest: process.cwd() + '/uploads/',
	rename: function(fieldname,filename){
		return filename;
	}
}));
*/


//router.use(express.json());
//router.use(express.urlencoded());
//router.use(multer({ dest: './uploads/' }));


// GET
router.get('/listSLA', csp.checkAuth, csrfProtection, function(req,res) {
	dbRoutes.listSLA(req,res,{code:'', msg:''} );
});

router.get('/activate', csp.checkAuth, csrfProtection, function(req,res){

	var _module = req.sanitize(req.query.module);
	var rpc = req.sanitize(req.query.rpc);
	var version = req.sanitize(req.query.version);
	var mode = req.sanitize(req.query.mode);

	var tasks = [];
  tasks.push( function(callback) { dbRoutes.global_deactivate(req,res,_module,rpc,mode,callback); } );
  tasks.push( function(callback) { dbRoutes.activate(req,res,_module,rpc,version,mode,callback); } );
	async.series(tasks,  function(err,result){

		if (  err ) {
			dbRoutes.listSLA(req,res,{code:'failure', msg:err });
		}
		else {
			dbRoutes.listSLA(req,res,{ code:'success', msg:'Successfully activated directed graph.'});
		}
	});
});

router.get('/deactivate', csp.checkAuth, csrfProtection, function(req,res){

	var _module = req.sanitize(req.query.module);
	var rpc = req.sanitize(req.query.rpc);
	var version = req.sanitize(req.query.version);
	var mode = req.sanitize(req.query.mode);

	var tasks = [];
  tasks.push( function(callback) { dbRoutes.deactivate(req,res,_module,rpc,version,mode,callback); } );
  async.series(tasks,  function(err,result){

		if (  err ) {
			dbRoutes.listSLA(req,res,{code:'failure', msg:err });
		}
		else {
			dbRoutes.listSLA(req,res,{code:'success', msg:'Successfully deactivated directed graph.'});
		}
	});
});

router.get('/deleteDG', csp.checkAuth, csrfProtection, function(req,res){

	var _module = req.sanitize(req.query.module);
	var rpc = req.sanitize(req.query.rpc);
	var version = req.sanitize(req.query.version);
	var mode = req.sanitize(req.query.mode);

	var tasks = [];
  tasks.push( function(callback) { dbRoutes.deleteDG(req,res,_module,rpc,version,mode,callback); } );
  async.series(tasks,  function(err,result){

		if (  err ) {
			dbRoutes.listSLA(req,res,{code:'failure', msg:'There was an deleting the directed graph. '+ err });
		}
		else {
			dbRoutes.listSLA(req,res,{code:'success', msg:'Successfully deleted directed graph.'});
		}
	});
});

// POST
router.post('/upload', csp.checkAuth, upload.single('filename'), csrfProtection, function(req, res, next){

	var _lstdout = "";
	var _lstderr = "";
	console.log('file:'+ JSON.stringify(req.file));

	if(req.file.originalname)
	{
		if (req.file.originalname.size == 0)
		{
			dbRoutes.listSLA(req,res, {code:'danger', msg:'There was an error uploading the file, please try again.'});
		}
		fs.exists(req.file.path, function(exists)
		{
			if(exists)
			{
				// parse xml
				try 
				{
					var currentDB = dbRoutes.getCurrentDB();
					var file_buf = fs.readFileSync(req.file.path, "utf8");

					// call svclogic shell script from here
					var commandToExec = process.cwd() + "/shell/svclogic.sh";

					console.log('filepath: ' + req.file.path);
          console.log('prop: ' + process.env.SDNC_CONFIG_DIR + "/svclogic.properties." + currentDB);
					console.log("commandToExec:" + commandToExec);

					child = spawn(commandToExec, ['load', req.file.path, process.env.SDNC_CONFIG_DIR + "/svclogic.properties." + currentDB]);
					child.on('error', function(error){
						console.log('error: '+error);
						dbRoutes.listSLA(req,res,{code:'failure', msg:error});
						return;
					});
					child.stdout.on('data', function(data) {
						console.log('stdout: ' + data);
						_lstdout = _lstdout.concat(data);
					});
					child.stderr.on('data', function(data) {
						console.log("stderr:" + data);
						_lstderr = _lstderr.concat(data);
					});
					child.on('exit', function(code,signal){
						console.log('code: ' + code);
						console.log('stdout: [[' + _lstdout + ']]');
						console.log('stderr: [[' + _lstderr + ']]');
						if ( _lstderr.indexOf("Saving") > -1 )
						{
							dbRoutes.listSLA(req,res,{code:'success', msg:'File sucessfully uploaded.'});
						}
						else
						{
							dbRoutes.listSLA(req,res,{code:'failure', msg:_lstderr} );
						}
						return;
					});
				} catch(ex) {
					console.log("error: " + ex);
					dbRoutes.listSLA(req,res,{code:'failure',msg:ex} );
					return;
				}
			}
			else {
				dbRoutes.listSLA(req,res,{code:'danger', msg:'There was an error uploading the file, please try again.'});
				return;
			}
		});
	}
	else {
		dbRoutes.listSLA(req,res,{code:'danger', msg:'There was an error uploading the file, please try again.'});
		return;
	}
});

router.get('/printAsXml', csp.checkAuth, csrfProtection, function(req,res){

	try {
		var _lstdout = "";
		var _lstderr = "";
		var _module = req.query.module;
    var rpc = req.query.rpc;
    var version = req.query.version;
    var mode = req.query.mode;
		var currentDB = dbRoutes.getCurrentDB();

    // call Dan's svclogic shell script from here
    var commandToExec = process.cwd() + "/shell/svclogic.sh";
		console.log("commandToExec:" + commandToExec);
		console.log("_mode: " + _module);
		console.log("rpc: " + rpc);
		console.log("version: " + version);
		console.log("currentDB: " +  process.env.SDNC_CONFIG_DIR + "/svclogic.properties." + currentDB);

    child = spawn(commandToExec, ['get-source', _module, rpc, mode, version, process.env.SDNC_CONFIG_DIR + "/svclogic.properties." + currentDB], {maxBuffer: 1024*5000});
		child.on('error', function(error){
			console.log("error: " + error);
			dbRoutes.listSLA(req,res,{code:'failure',msg:error} );
			return;
		});
		child.stderr.on('data', function(data){
			console.log('stderr: ' + data);
			_lstderr = _lstderr.concat(data);
		});
		child.stdout.on('data', function(data){
			console.log("OUTPUT:" + data);
			_lstdout = _lstdout.concat(data);
		});
		child.on('exit', function(code,signal){

			console.log('code: ' + code);
			console.log('close:stdout: ' + _lstdout);
			console.log('close:stderr: ' + _lstderr);

			if ( code != 0 ){
				dbRoutes.listSLA(req,res,{code:'failure',msg:_lstderr} );
			}
			else {
				res.render('sla/printasxml', {result:{code:'success', 
					msg:'Module : ' + _module + '\n' + 
					'RPC    : ' + rpc + '\n' + 
					'Mode   : ' + mode + '\n' +
					'Version: ' + version + '\n\n' + _lstdout}, header:process.env.MAIN_MENU});
			}
			return;
		});
 	} catch(ex) {
		console.error("error:" + ex);
		dbRoutes.listSLA(req,res,{code:'failure',msg:ex} );
		return;
 }
});

module.exports = router;

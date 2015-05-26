var express = require('express');
var http = require('http');
var app = express();
var irb = require('./irb');
var crms = require('./crms');
var iacuc = require('./iacuc');
var dlar = require('./dlar');
var test = require('./irb/test.js');
var winston = require('winston');
var bodyParser = require('body-parser');
var logger = require("./utils/logger.js");
var handlebars = require('handlebars');
var fs = require('fs');

//DLAR Pre-Compile Template
var rawDlarTemplate = fs.readFileSync('./dlar/templates/create.tpl', {encoding:'utf8'});
var dlarCompliedTemplate = handlebars.compile(rawDlarTemplate);

//IACUC Pre-Compile Template
var rawIacucTemplate = fs.readFileSync('./iacuc/templates/create.tpl', {encoding:'utf8'});
var iacucCompliedTemplate = handlebars.compile(rawIacucTemplate);

//IRB Pre-Compile Template
var rawIrbTemplate = fs.readFileSync('./irb/templates/create.tpl', {encoding:'utf8'});
var irbCompliedTemplate = handlebars.compile(rawIrbTemplate);

//CRMS Pre-Compile Template
var rawCrmsTemplate = fs.readFileSync('./crms/templates/create.tpl', {encoding:'utf8'});
var crmsCompliedTemplate = handlebars.compile(rawCrmsTemplate);

logger.debug("Overriding 'Express' logger");
app.use(require('express')({ "stream": logger.stream }));
app.use(bodyParser.urlencoded({extended:true}));
app.use(bodyParser.json());

var port = process.env.Port || 4441; //set port
var env = process.env.NODE_ENV || 'development';
var router = express.Router();


//middleware that will happen on every requests
router.use(function(req,res,next){
  //logging requests
  logger.log('info', req.method +' '+req.url );
  next();
});

/*
router.get('/', function(req,res){
  res.send('Syndication Service. Port:'+port);
});

router.get('/:store/:action', function (req, res, next) {
  var store = req.params.store;
  var action = req.params.action;
  if(store == "irb"){
    var i = irb.compiledHandleBars();
    res.send(i);
    //irb.compiledHandleBars();

  }
  if(store == "crms"){
    console.log(store);
    console.log(action);
  }
  next();
});
*/


router.post('/', function(req,res){
  console.log(req.body);
  var j = 'test, received';
  res.send(j);
});

/*
* Use a specific template depending on store: /store/templates/create.tpl
* Return compiled template using Handlebars
*/
router.post('/:store', [
    function (req, res, next) {
    var store = req.params.store;
    if(store == 'irb'){
      req.preTemp = irbCompliedTemplate;
    }
    if(store == 'crms'){
      req.preTemp = crmsCompliedTemplate;
    }
    if(store == 'iacuc'){
      req.preTemp = iacucCompliedTemplate;
    } 
    if(store == 'dlar'){
      req.preTemp = dlarCompliedTemplate;
    }
    next();
  },
  function (req, res, next) {
  var store = req.params.store;
  //var action = req.params.action;
  store = store.toLowerCase();
  logger.info("Store: "+store);
  logger.info(req.body);
  if(store == 'irb'){
    var i = irb.compiledHandleBars(req.body, req.preTemp);
    var buf = new Buffer(i);
    var compiledScript = buf.toString('base64');
    //logger.info(compiledScript);
    i = '{"script":"'+compiledScript+'"}'
    //res.writeHead(200, {"Content-Type":"application/json"});
    //res.write(JSON.stringify(i));
    //res.end();
    res.send(i);
  }
  if(store == 'crms'){
    var i = crms.compiledHandleBars(req.body, req.preTemp);
    var buf = new Buffer(i);
    var compiledScript = buf.toString('base64');
    //logger.info(compiledScript);
    i = '{"script":"'+compiledScript+'"}'
    //res.writeHead(200, {"Content-Type":"application/json"});
    //res.write(JSON.stringify(i));
    //res.end();
    res.send(i);
  }
  if(store == 'iacuc'){
      var i = iacuc.compiledHandleBars(req.body, req.preTemp);
      var buf = new Buffer(i);
      var compiledScript = buf.toString('base64');
      //logger.info(compiledScript);
      i = '{"script":"'+compiledScript+'"}'
      //res.writeHead(200, {"Content-Type":"application/json"});
      //res.write(JSON.stringify(i));
      //res.end();
      res.send(i);
  }
  if(store == 'dlar'){
      var i = dlar.compiledHandleBars(req.body, req.preTemp);
      var buf = new Buffer(i);
      var compiledScript = buf.toString('base64');
      //logger.info(compiledScript);
      i = '{"script":"'+compiledScript+'"}'
      //res.writeHead(200, {"Content-Type":"application/json"});
      //res.write(JSON.stringify(i));
      //res.end();
      res.send(i);

  }
  next();
}]);

app.use('/', router);

var server = app.listen(port, function () {
  var host = server.address().address;
  console.log('Example app listening at http://%s:%s', host, port, env);
});


var express = require('express');
var http = require('http');
var app = express();
var irb = require('./irb');//IRB
var crms = require('./crms');//CRMS
var iacuc = require('./iacuc');//IACUC
var dlar = require('./dlar'); //DLAR
var locations = require('./locations'); //locations to iacuc
var dlaraoi = require('./dlar-aolineitem');//dlar animal order line item(datamigration)
var dlaraot = require('./dlar-aotransfer');//dlar animal order transfer(datamigration)
var dlarcage = require('./dlar-cagecard');//dlar cage card(datamigration)
var dlarbillings = require('./dlar-billing');//dlar billing period(data migration)
var dlarinvoices = require('./dlar-invoice');//dlar invoice(data migration)
var rnumber = require('./rnumber');//My Studies
var test = require('./irb/test.js');
var winston = require('winston');
var bodyParser = require('body-parser');
var logger = require("./utils/logger.js");
//var logger = winston.loggers.get('')
var handlebars = require('handlebars');
var fs = require('fs');
var config = require('./config');

/******************************
* Pre-Compile Create Templates
*******************************/
//DLAR Pre-Compile Create Template
var rawCreateDlarTemplate = fs.readFileSync(__dirname+'/dlar/templates/create.tpl', {encoding:'utf8'});
var dlarCompliedCreateTemplate = handlebars.compile(rawCreateDlarTemplate);

//IACUC Pre-Compile Create Template
var rawCreateIacucTemplate = fs.readFileSync(__dirname+'/iacuc/templates/create.tpl', {encoding:'utf8'});
var iacucCompliedCreateTemplate = handlebars.compile(rawCreateIacucTemplate);

//IRB Pre-Compile Create Template
var rawCreateIrbTemplate = fs.readFileSync(__dirname+'/irb/templates/create.tpl', {encoding:'utf8'});
var irbCompliedCreateTemplate = handlebars.compile(rawCreateIrbTemplate);

//CRMS Pre-Compile Create Template - Research Navigator creation
var rawCreateCrmsTemplate = fs.readFileSync(__dirname+'/crms/templates/createRnumber.tpl', {encoding:'utf8'});
var crmsCompliedCreateTemplate = handlebars.compile(rawCreateCrmsTemplate);

//CRMS Pre-Compile Create Template - IRB Updates
var rawCreateCrmsTemplateIRB = fs.readFileSync(__dirname+'/crms/templates/createIRB.tpl', {encoding:'utf8'});
var crmsCompliedCreateTemplateIRB = handlebars.compile(rawCreateCrmsTemplateIRB);

//RNUMBER Pre-Compile Template - IACUC Updates
var rawCreateResearchNavigatorTemplate = fs.readFileSync(__dirname+'/rnumber/templates/createIACUC.tpl', {encoding:'utf8'});
var rnumberCompliedCreateTemplate = handlebars.compile(rawCreateResearchNavigatorTemplate);

//RNUMBER Pre-Compile Template - IRB Updates
var rawCreateResearchNavigatorTemplateIRB = fs.readFileSync(__dirname+'/rnumber/templates/createIRB.tpl', {encoding:'utf8'});
var rnumberCompliedCreateTemplateIRB = handlebars.compile(rawCreateResearchNavigatorTemplateIRB);

//Locations Pre-Compile Template
var rawCreateIacucLocationTemplate = fs.readFileSync(__dirname+'/locations/templates/create.tpl', {encoding:'utf8'});
var iacucLocationCompliedCreateTemplate = handlebars.compile(rawCreateIacucLocationTemplate);


/*****************
  DATA MIGRATION
******************/

//DLAR(Animal Order Line Item) Pre-Compile Create Template
var rawCreateDlarAoiTemplate = fs.readFileSync(__dirname+'/dlar-aolineitem/templates/create.tpl', {encoding:'utf8'});
var dlarAoiCompliedCreateTemplate = handlebars.compile(rawCreateDlarAoiTemplate);

//DLAR(Animal Order Transfer) Pre-Compile Create Template
var rawCreateDlarAotTemplate = fs.readFileSync(__dirname+'/dlar-aotransfer/templates/create.tpl', {encoding:'utf8'});
var dlarAotCompliedCreateTemplate = handlebars.compile(rawCreateDlarAotTemplate);

//DLAR(Cage Card) Pre-Compile Create Template
var rawCreateDlarCageTemplate = fs.readFileSync(__dirname+'/dlar-cagecard/templates/create.tpl', {encoding:'utf8'});
var dlarCageCompliedCreateTemplate = handlebars.compile(rawCreateDlarCageTemplate);

//DLAR(Invoice) Pre-Compile Create Template
var rawCreateDlarInvoice = fs.readFileSync(__dirname+'/dlar-invoice/templates/create.tpl', {encoding:'utf8'});
var dlarInvoiceCompliedCreateTemplate = handlebars.compile(rawCreateDlarInvoice);

//DLAR(Billing) Pre-Compile Create Template
var rawCreateDlarBilling = fs.readFileSync(__dirname+'/dlar-billing/templates/create.tpl', {encoding:'utf8'});
var dlarBillingCompliedCreateTemplate = handlebars.compile(rawCreateDlarBilling);


/*****************************
* Pre-Compile Update Templates
******************************/
//RNUMBER Pre-Compile Update Template
var rawUpdateResearchNavigatorTemplate = fs.readFileSync(__dirname+'/rnumber/templates/update.tpl', {encoding:'utf8'});
var rnUpdateTemplate = handlebars.compile(rawUpdateResearchNavigatorTemplate);

//CRMS Pre-Compile Update Template
var rawUpdateCrmsTemplate = fs.readFileSync(__dirname+'/crms/templates/update.tpl', {encoding:'utf8'});
var crmsUpdateTemplate = handlebars.compile(rawUpdateCrmsTemplate);

//DLAR Pre-Compile Update Template
var rawUpdateDlarTemplate = fs.readFileSync(__dirname+'/dlar/templates/update.tpl', {encoding:'utf8'});
var dlarCompliedUpdateTemplate = handlebars.compile(rawUpdateDlarTemplate);

/*
  HandleBars partials
*/
var rawPartialCreateIacucOrigAmendTemplate = fs.readFileSync(__dirname+'/iacuc/templates/iacuc-orig-amend-datamigration-create.tpl', {encoding:'utf8'});
var rawPartialCreateIacucPreCompileOrigAmendTemplate = handlebars.compile(rawPartialCreateIacucOrigAmendTemplate);
handlebars.registerPartial("dataMigrationIacucOrigAmendCreate", rawPartialCreateIacucPreCompileOrigAmendTemplate);

var rawPartialUpdateIacucOrigAmendTemplate = fs.readFileSync(__dirname+'/iacuc/templates/iacuc-orig-amend-datamigration-update.tpl', {encoding:'utf8'});
var rawPartialUpdateIacucPreCompileOrigAmendTemplate = handlebars.compile(rawPartialUpdateIacucOrigAmendTemplate);
handlebars.registerPartial("dataMigrationIacucOrigAmendUpdate", rawPartialUpdateIacucPreCompileOrigAmendTemplate);

var rawPartialCreateIacucOrigTemplate = fs.readFileSync(__dirname+'/iacuc/templates/iacuc-orig-datamigration-create.tpl', {encoding:'utf8'});
var rawPartialCreateIacucPreCompileOrigTemplate = handlebars.compile(rawPartialCreateIacucOrigTemplate);
handlebars.registerPartial("dataMigrationIacucOrigCreate", rawPartialCreateIacucPreCompileOrigTemplate);

var rawPartialUpdateIacucOrigTemplate = fs.readFileSync(__dirname+'/iacuc/templates/iacuc-orig-datamigration-update.tpl', {encoding:'utf8'});
var rawPartialUpdateIacucPreCompileOrigTemplate = handlebars.compile(rawPartialUpdateIacucOrigTemplate);
handlebars.registerPartial("dataMigrationIacucOrigUpdate", rawPartialUpdateIacucPreCompileOrigTemplate);

var rawPartialIacucOrigTemplate = fs.readFileSync(__dirname+'/iacuc/templates/iacuc-orig-integration-create.tpl', {encoding:'utf8'});
var rawPartialIacucPreCompileOrigTemplate = handlebars.compile(rawPartialIacucOrigTemplate);
handlebars.registerPartial("integrationIacucOrigCreate", rawPartialIacucPreCompileOrigTemplate);

var rawPartialIacucOrigCopyTemplate = fs.readFileSync(__dirname+'/iacuc/templates/iacuc-orig-integration-create-existing.tpl', {encoding:'utf8'});
var rawPartialIacucPreCompileOrigCopyTemplate = handlebars.compile(rawPartialIacucOrigCopyTemplate);
handlebars.registerPartial("integrationIacucOrigCreateExisting", rawPartialIacucPreCompileOrigCopyTemplate);

var rawPartialIacucOrigDCMTemplate = fs.readFileSync(__dirname+'/iacuc/templates/iacuc-orig-dcm-intergration.tpl', {encoding:'utf8'});
var rawPartialIacucPreCompileOrigDCMTemplate = handlebars.compile(rawPartialIacucOrigDCMTemplate);
handlebars.registerPartial("integrationIacucOrigDCMUpdate", rawPartialIacucPreCompileOrigDCMTemplate);

var rawPartialDlarOrigCreateTemplate = fs.readFileSync(__dirname+'/dlar/templates/dlar-orig-integration-create.tpl', {encoding:'utf8'});
var rawDlarPartialPreCompileCreateTemplate = handlebars.compile(rawPartialDlarOrigCreateTemplate);
handlebars.registerPartial("integrationDlarOrigCreate", rawDlarPartialPreCompileCreateTemplate);

var rawPartialDlarOrigUpdateTemplate = fs.readFileSync(__dirname+'/dlar/templates/dlar-orig-integration-update.tpl', {encoding:'utf8'});
var rawDlarPartialPreCompileUpdateTemplate = handlebars.compile(rawPartialDlarOrigUpdateTemplate);
handlebars.registerPartial("integrationDlarOrigUpdate", rawDlarPartialPreCompileUpdateTemplate);

var rawPartialIacucRoomCreateTemplate = fs.readFileSync(__dirname+'/locations/templates/facilityRoom.tpl', {encoding:'utf8'});
var rawDlarPartialPreCompileIacucRoomTemplate = handlebars.compile(rawPartialIacucRoomCreateTemplate);
handlebars.registerPartial("integrationIacucRoomCreate", rawDlarPartialPreCompileIacucRoomTemplate);

var rawPartialIacucBuildingCreateTemplate = fs.readFileSync(__dirname+'/locations/templates/facilityBuilding.tpl', {encoding:'utf8'});
var rawDlarPartialPreCompileIacucBuildingTemplate = handlebars.compile(rawPartialIacucBuildingCreateTemplate);
handlebars.registerPartial("integrationIacucBuildingCreate", rawDlarPartialPreCompileIacucBuildingTemplate);

var rawPartialIacucCampusCreateTemplate = fs.readFileSync(__dirname+'/locations/templates/campus.tpl', {encoding:'utf8'});
var rawDlarPartialPreCompileIacucCampusTemplate = handlebars.compile(rawPartialIacucCampusCreateTemplate);
handlebars.registerPartial("integrationIacucCampusCreate", rawDlarPartialPreCompileIacucCampusTemplate);

/*
  HandleBars register helper
*/

handlebars.registerHelper('breaklines', function(text) {
    text = handlebars.Utils.escapeExpression(text);
    text = text.replace(/(\r\n|\n|\r)/gm, ' ');
    return new handlebars.SafeString(text);
});

/*
  https://www.npmjs.com/package/body-parser --> Added limit because of Error: request entity too large
*/
logger.debug("Overriding 'Express' logger");
app.use(require('express')({ "stream": logger.stream }));
app.use(bodyParser.json({limit: '5mb'}));
app.use(bodyParser.urlencoded({limit:'5mb', extended:true}));

var port = process.env.Port || 4441; //set port
var env = process.env.NODE_ENV || 'development';
var router = express.Router();

//middleware that will happen on every requests
router.use(function(req,res,next){
  //logging requests
  logger.log('info', req.method +' '+req.url );
  next();
});

router.post('/', function(req,res){
  //console.log(req.body);
  var j = 'test, received';
  res.send(j);
});

/*
* stepCreateOne => used for createTemplates
*               => based on store -> example: irb/crms/iacuc/dlar 
*/
var stepCreateOne = function (req, res, next) {
    var store = req.params.store;
    var type = req.body.modelName;
    var action = req.body.action;
    if(store == 'irb'){
      req.preTemp = irbCompliedCreateTemplate;
    }
    if(store == 'crms'){
      req.preTemp = crmsCompliedCreateTemplate;
    }
    if(store == 'iacuc'){
      if(type == '_Research Project' && action == 'researchproject:animal:status'){
        req.preTemp = iacucCompliedCreateTemplate;
      }
      else if(type == '_Facility' && (action == 'facility:resource:datemodified' || action == 'facility:project:status')){
        req.preTemp = iacucLocationCompliedCreateTemplate;
      }
    } 
    if(store == 'dlar'){
      if(type == '_ClickIACUCSubmission' && (action == 'iacucsubmission:orginal:status' || action == 'iacucsubmission:amendment:status')){
        req.preTemp = dlarCompliedCreateTemplate;
      }
    }
    if(store == 'dlaraolineitem'){
      req.preTemp = dlarAoiCompliedCreateTemplate;
    }
    if(store == 'dlaraotransfer'){
      req.preTemp = dlarAotCompliedCreateTemplate;
    }
    if(store == 'dlarcagecard'){
      req.preTemp = dlarCageCompliedCreateTemplate;
    }
    if(store == 'dlarbilling'){
      req.preTemp = dlarBillingCompliedCreateTemplate;
    }
    if(store == 'dlarinvoice'){
      req.preTemp = dlarInvoiceCompliedCreateTemplate;
    }
    if(store == 'rnumber'){
      if(type == '_ClickIACUCSubmission' && (action == 'iacucsubmission:orginal:status' || action == 'iacucsubmission:amendment:status')){
        req.preTemp = rnumberCompliedCreateTemplate;
      }
    }
    next();
  };

/*
* stepCreateTwo => create scripts(create) for debug console
*               => action -> create, send json with correct template to compile based on store
*/
var stepCreateTwo = function (req, res, next) {
  var store = req.params.store;
  store = store.toLowerCase();
  var type = req.body.modelName;
  var action = req.body.action;
  logger.info("Store: "+store +" Action: Create");
  logger.info("ID => "+req.body.id+' => type => '+type+' => '+action);
  var jsonDocument = req.body.document;
  if(store == 'irb'){
      if(type == '_Research Project' && action == 'researchproject:human:status'){
        var i = irb.compiledHandleBars(jsonDocument, req.preTemp);
        var buf = new Buffer(i);
        var compiledScript = buf.toString('base64');
        i = '{"script":"'+compiledScript+'"}'
        res.send(i);
      }
  }
  if(store == 'crms'){
    var i = crms.compiledHandleBars(jsonDocument, req.preTemp);
    var buf = new Buffer(i);
    var compiledScript = buf.toString('base64');
    i = '{"script":"'+compiledScript+'"}'
    res.send(i);
  }
  if(store == 'iacuc'){
      if(type == '_Research Project' && action == 'researchproject:animal:status'){
          var i = iacuc.compiledHandleBars(jsonDocument, req.preTemp);
          var buf = new Buffer(i);
          var compiledScript = buf.toString('base64');
          i = '{"script":"'+compiledScript+'"}'
          res.send(i);
      }
      else if(type == '_Facility' && (action == 'facility:resource:datemodified' || action == 'facility:project:status')){
          var i = locations.compiledHandleBars(jsonDocument, req.preTemp);
          var buf = new Buffer(i);
          var compiledScript = buf.toString('base64');
          i = '{"script":"'+compiledScript+'"}'
          res.send(i);
      }
  }
  if(store == 'dlar'){
      if(type == '_ClickIACUCSubmission' && (action == 'iacucsubmission:orginal:status' || action == 'iacucsubmission:amendment:status')){
        var i = dlar.compiledHandleBars(jsonDocument, req.preTemp);
        var buf = new Buffer(i);
        var compiledScript = buf.toString('base64');
        i = '{"script":"'+compiledScript+'"}'
        res.send(i);
      }

  }
  if(store == 'dlaraolineitem'){
      var i = dlaraoi.compiledHandleBars(jsonDocument, req.preTemp);
      var buf = new Buffer(i);
      var compiledScript = buf.toString('base64');
      i = '{"script":"'+compiledScript+'"}'
      res.send(i);

  }
  if(store == 'dlaraotransfer'){
      var i = dlaraot.compiledHandleBars(jsonDocument, req.preTemp);
      var buf = new Buffer(i);
      var compiledScript = buf.toString('base64');
      i = '{"script":"'+compiledScript+'"}'
      res.send(i);

  }
  if(store == 'dlarcagecard'){
      var i = dlarcage.compiledHandleBars(jsonDocument, req.preTemp);
      var buf = new Buffer(i);
      var compiledScript = buf.toString('base64');
      i = '{"script":"'+compiledScript+'"}'
      res.send(i);

  }
  if(store == 'dlarbilling'){
      var i = dlarbillings.compiledHandleBars(jsonDocument, req.preTemp);
      var buf = new Buffer(i);
      var compiledScript = buf.toString('base64');
      i = '{"script":"'+compiledScript+'"}'
      res.send(i);

  }
  if(store == 'dlarinvoice'){
      var i = dlarinvoices.compiledHandleBars(jsonDocument, req.preTemp);
      var buf = new Buffer(i);
      var compiledScript = buf.toString('base64');
      i = '{"script":"'+compiledScript+'"}'
      res.send(i);

  }
  if(store == 'rnumber'){
      if(type == '_ClickIACUCSubmission' && (action == 'iacucsubmission:orginal:status' || action == 'iacucsubmission:amendment:status')){
        var i = rnumber.compiledHandleBars(jsonDocument, req.preTemp);
        var buf = new Buffer(i);
        var compiledScript = buf.toString('base64');
        i = '{"script":"'+compiledScript+'"}'
        res.send(i);
      }

  }
  next();
};

/*
* stepUpdateOne => used for updateTemplates
*               => based on store -> example: irb/crms/iacuc/dlar 
*/
var stepUpdateOne = function (req, res, next) {
  var store = req.params.store;
  if(store == 'rnumber'){
    req.preTemp = rnUpdateTemplate;
  }
  if(store == 'crms'){
    req.preTemp = crmsUpdateTemplate;
  }
  if(store == 'dlar'){
    req.preTemp = dlarCompliedUpdateTemplate;
  }
  next();
};

/*
* stepCreateTwo => create scripts(update) for debug console
*               => action -> update, send json with correct template to compile based on store
*/
var stepUpdateTwo = function (req, res, next) {
  var store = req.params.store;
  store = store.toLowerCase();
  logger.info("Store: "+store +" Action: Update");
  logger.info(req.body);
  if(store == 'rnumber'){
      var i = rnumber.compiledHandleBars(req.body, req.preTemp);
      var buf = new Buffer(i);
      var compiledScript = buf.toString('base64');
      i = '{"script":"'+compiledScript+'"}'
      res.send(i);
  }
  if(store == 'crms'){
    var i = crms.compiledHandleBars(req.body, req.preTemp);
    var buf = new Buffer(i);
    var compiledScript = buf.toString('base64');
    i = '{"script":"'+compiledScript+'"}'
    res.send(i);
  }
  if(store == 'dlar'){
      var i = dlar.compiledHandleBars(req.body, req.preTemp);
      var buf = new Buffer(i);
      var compiledScript = buf.toString('base64');
      i = '{"script":"'+compiledScript+'"}'
      res.send(i);
  }
  next();
};

/*
* Use a specific template depending on store: /:store/templates/create.tpl => example: /irb/templates/create.tpl
* Return compiled template using Handlebars
*/
router.post('/:store', [
    stepCreateOne,
    stepCreateTwo
]);

/*
* Use a specific template depending on store: /:store/templates/create/create.tpl => example: /irb/templates/create.tpl
* Return compiled template using Handlebars
*/
router.post('/:store/create', [
    stepCreateOne,
    stepCreateTwo
]);

/*
* Use a specific template depending on store: /:store/templates/update/update.tpl => example: /rnumber/templates/update.tpl
* Return compiled template using Handlebars
*/
router.post('/:store/update', [
  stepUpdateOne,
  stepUpdateTwo
]);

app.use('/', router);

var server = app.listen(port, function () {
  var host = server.address().address;
  logger.info('app listening at http://%s:%s', host, port, env);
});

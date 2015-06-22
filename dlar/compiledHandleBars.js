var handlebars = require('handlebars');
var fs = require('fs');

module.exports = function(testData, preTemp) {
  var compiledScript;
  if(!testData.protocolNumber){
  	//var data = fs.readFileSync('./data/15-00306.json', {encoding:'utf8'});
  	//testData = JSON.parse(data);
  	compiledScript = '?Error: JSON missing protocolNumber';
  }
  else{
    /*
    var data = fs.readFileSync('./data/15-00143_sql_populatedDLAR.json', {encoding:'utf8'});
    //var data = fs.readFileSync('./data/15-00093_sql_populatedDLAR', {encoding:'utf8'});
    testData = JSON.parse(data);
  	/*
    //var rawTemplate = fs.readFileSync('./dlar/templates/create.tpl', {encoding:'utf8'});

  	//var compiledTemplate = handlebars.compile(rawTemplate);
    
  	//compiledScript = compiledTemplate(testData);
    //console.log(compiledScript);
    */
    var compiledScript = preTemp(testData);
  }
  //fs.writeFileSync('./output/test-outDLAR', compiledScript, {encoding:'utf8'});
  return compiledScript;
};
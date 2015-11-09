var handlebars = require('handlebars');
var fs = require('fs');

module.exports = function(testData, preTemp) {
  var compiledScript;
  if(!testData.id){
  	//var data = fs.readFileSync('./data/15-00306.json', {encoding:'utf8'});
  	//testData = JSON.parse(data);
  	compiledScript = "?'Error: JSON missing id'";
  }
  else{
    
    //var data = fs.readFileSync('./data/15-00306.json', {encoding:'utf8'});
    //testData = JSON.parse(data);
  	//var rawTemplate = fs.readFileSync('./rnumber/templates/create.tpl', {encoding:'utf8'});
    //var data = fs.readFileSync('./data/15-00143_sql_populatedDLAR.json', {encoding:'utf8'});
    //testData = JSON.parse(data);
  	//var compiledTemplate = handlebars.compile(rawTemplate);
  	//compiledScript = compiledTemplate(testData);
    
    compiledScript = preTemp(testData);
  }
  fs.writeFileSync('./output/test-outRNUMBER', compiledScript, {encoding:'utf8'});
  return compiledScript;
};
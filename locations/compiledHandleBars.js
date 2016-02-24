var handlebars = require('handlebars');
var fs = require('fs');

module.exports = function(testData, preTemp) {
  var compiledScript;
  if(!testData.id){
  	//var data = fs.readFileSync('./data/15-00306.json', {encoding:'utf8'});
  	//testData = JSON.parse(data);
    //console.log(testData.id);
  	compiledScript = "?'Error: JSON missing id'";
  }
  else{
    //console.log('testData => '+testData.id)
    //var data = fs.readFileSync('./data/locations/lo0000264_sql_populated.json', {encoding:'utf8'});
    var data = fs.readFileSync('./data/locations/lo0000782_sql_populated.json', {encoding:'utf8'});
    testData = JSON.parse(data);
    /*
  	var rawTemplate = fs.readFileSync('./locations/templates/create.tpl', {encoding:'utf8'});

  	var compiledTemplate = handlebars.compile(rawTemplate);
  	compiledScript = compiledTemplate(data);
    */
    compiledScript = preTemp(testData);
  }
  fs.writeFileSync('./output/test-outLocation', compiledScript, {encoding:'utf8'});
  return compiledScript;
};
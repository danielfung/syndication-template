var handlebars = require('handlebars');
var fs = require('fs');

module.exports = function(testData, preTemp) {
  var compiledScript;
  if(!testData.id){
  	//var data = fs.readFileSync('./data/15-00306.json', {encoding:'utf8'});
  	//testData = JSON.parse(data);
  	compiledScript = 'Error: JSON missing id';
  }
  else{
    /*
    //var data = fs.readFileSync('./data/15-00306.json', {encoding:'utf8'});
    //testData = JSON.parse(data);
  	var rawTemplate = fs.readFileSync('./crms/templates/create.tpl', {encoding:'utf8'});

  	var compiledTemplate = handlebars.compile(rawTemplate);
  	compiledScript = compiledTemplate(testData);
    */
    compiledScript = preTemp(testData);
  }
  //fs.writeFileSync('./test-outCRMS', compiledScript, {encoding:'utf8'});
  return compiledScript;
};
var handlebars = require('handlebars');
var fs = require('fs');

module.exports = function(testData, preTemp) {
  var compiledScript;
  if(!testData._uid){
  	//var data = fs.readFileSync('./data/15-00306_sql_populatedNewIRB.json', {encoding:'utf8'});
  	//testData = JSON.parse(data);
  	compiledScript = "?'Error: JSON missing id'";
  }
  else{
    /*
  	var data = fs.readFileSync('./data/15-00306_sql_populatedNewIRB.json', {encoding:'utf8'});
  	testData = JSON.parse(data);
  	var rawTemplate = fs.readFileSync('./irb/templates/create.tpl', {encoding:'utf8'});
    console.log(' in here');
  	var compiledTemplate = handlebars.compile(rawTemplate);
  	compiledScript = compiledTemplate(testData);
    */
    compiledScript = preTemp(testData);
  }
  //fs.writeFileSync('./output/test-out-IRB', compiledScript, {encoding:'utf8'});
  return compiledScript;

};
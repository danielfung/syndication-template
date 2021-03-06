var handlebars = require('handlebars');
var fs = require('fs');

module.exports = function(testData, preTemp) {
  var compiledScript;
  if(!testData._uid && !testData.id){
  	//var data = fs.readFileSync('./data/15-00306.json', {encoding:'utf8'});
  	//testData = JSON.parse(data);
    //console.log(testData.id);
  	compiledScript = "?'Error: JSON missing id'";
  }
  else{
    //console.log('testData => '+testData.id)
    //var data = fs.readFileSync('./data/15-00066_sql_populatedApproved.json', {encoding:'utf8'});
    //var data = fs.readFileSync('./data/15-00066_sql_populated.json', {encoding:'utf8'});
    //var data = fs.readFileSync('./data/15-00069_sql_populatedNoIACUCProtocol.json', {encoding:'utf8'});
    //var data = fs.readFileSync('./data/15-00070_sql_populated.json', {encoding:'utf8'});
    //var data = fs.readFileSync('./data/initial-orig-1.json', {encoding:'utf8'});
    //testData = JSON.parse(data);
  	/*var rawTemplate = fs.readFileSync('./iacuc/templates/create.tpl', {encoding:'utf8'});

  	var compiledTemplate = handlebars.compile(rawTemplate);
  	compiledScript = compiledTemplate(testData);
    */
    compiledScript = preTemp(testData);
  }
  //fs.writeFileSync('./output/test-outIACUC', compiledScript, {encoding:'utf8'});
  return compiledScript;
};
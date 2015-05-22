var handlebars = require('handlebars');
var fs = require('fs');

exports.compileTemplate = function(req, res){
	var action = req.params.action;
	if(action == "create"){
		var rawTemplate = fs.readFileSync('./irb/templates/create.tpl', {encoding:'utf8'});
		var data = fs.readFileSync('./data/15-00306_sql_populated.json', {encoding:'utf8'});
		var json = JSON.parse(data);

		var compiledTemplate = handlebars.compile(rawTemplate);
		var compiledScript = compiledTemplate(json);

		fs.writeFileSync('./test-out', compiledScript, {encoding:'utf8'});
		res.send(compiledScript);
	}
}
var site = ApplicationEntity.getResultSet('_ClickCampus').query("ID='{{name}}'").elements();
if(site.count() == 1){
	?'campus found => '+site.item(1)+'\n';
}
else if(site.count() > 1){
	?'more than one campus found by id => {{id}}\n';
}
else{
	var createCampus = _ClickCampus.createEntity();
	createCampus.id = '{{id}}';
	?'_ClickCampus created => '+createCampus+' => ID: '+createCampus.id+'\n';
	var dateNow = new Date();
	createCampus.dateCreated = dateNow;
	createCampus.dateModified = dateNow;
}
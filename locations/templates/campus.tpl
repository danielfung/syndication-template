var site = ApplicationEntity.getResultSet('_ClickCampus').query("ID='{{id}}'").elements();
if(campusFound.count() == 1){
	?'campus found => '+site.item(1)+'\n';
}
else if(campusFound.count() > 1){
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
{{#if _uid}}
	var cageCard_id = _CageCard.getID();
{{else}}
	var cageCard_id ="{{this.id}}";
{{/if}}

?'CAGE CARD ID =>'+cageCard_id+'\n';
var cageCard = ApplicationEntity.getResultSet('_CageCard').query("ID='"+cageCard_id+"'");
?'cageCard.count() =>'+cageCard.count()+'\n';

/*
	1. Create cage card if it doesn't exist.
*/
if(cageCard.count() == 0){

	cageCard = _CageCard.createEntity();
	?'DLAR.cageCard =>'+cageCard+'\n';

	/*
		1a. update ID of cage card
	*/

		cageCard.ID = cageCard_id;
		?'cageCard.ID =>'+cageCard.ID+'\n';

	/*
		1b. set required fields (company, createdby, owner)
		if createdBy not found --> default to Sys Admin
	*/
		//createdby
		{{#if createdBy.userId}}
			var create = cageCard.createdBy;
			if(create == null){
				var person = ApplicationEntity.getResultSet("Person").query("userID = '{{createdBy.userId}}'");
				if(person.count() > 0){
					person = person.elements().item(1);
					cageCard.createdBy = person;
					?'cageCard.createdBy =>'+cageCard.createdBy+'\n';
					var company = person.employer;
					cageCard.company = company;
					?'setting company =>'+cageCard.company+'\n';
					cageCard.owner = person;
					?'setting cageCard.owner =>'+person+'\n';
				}
				else{
					?'Person Not Found =>{{createdBy.userId}}\n';
					var person = ApplicationEntity.getResultSet("Person").query("userID = 'administrator'").elements().item(1);
					cageCard.createdBy = person;
					?'defaulting cageCard.createdBy => administrator: '+cageCard.createdBy+'\n';
					var company = person.employer;
					cageCard.company = company;
					?'setting company =>'+cageCard.company+'\n';
					cageCard.owner = person;
					?'setting cageCard.owner =>'+person+'\n';

				}
			}
		{{else}}
			var person = ApplicationEntity.getResultSet("Person").query("userID = 'administrator'").elements().item(1);
			cageCard.createdBy = person;
			?'defaulting cageCard.createdBy => administrator: '+cageCard.createdBy+'\n';
			var company = person.employer;
			cageCard.company = company;
			?'setting company =>'+cageCard.company+'\n';
			cageCard.owner = person;
			?'setting cageCard.owner =>'+person+'\n';

		{{/if}}


	/*
		1c. set dates(created/modified)
	*/
		var currentDate = new Date();
		cageCard.dateCreated=currentDate;
		?'dateCreated =>'+cageCard.dateCreated+'\n';
		cageCard.dateModified=currentDate;
		?'dateModified =>'+cageCard.dateModified+'\n';


}
else{
	cageCard = cageCard.elements().item(1);
	?'DLAR.cageCard protocol found =>'+cageCard.ID+'\n';
	//update fields below total animal #.
}
{{#if topaz.id}}
	var cageCard_id ="{{topaz.id}}";
	?'cage card ID for data migration => '+cageCard_id+'\n';
{{else}}
	ar cageCard_id = _CageCard.getID();
{{/if}}

?'CAGE CARD ID =>'+cageCard_id+'\n';
var cageCard = ApplicationEntity.getResultSet('_CageCard').query("ID='"+cageCard_id+"'");
?'cageCard.count() =>'+cageCard.count()+'\n';

var parentProtocol = ApplicationEntity.getResultSet('_IACUC Study').query("ID='{{topaz.parentProject.id}}'");

if(parentProtocol.count() > 0){
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
					var company = person.customAttributes.academicDepartment;
					if(company == null){
						company = ApplicationEntity.getResultSet("Company").query("name = 'MCIT'").elements().item(1);
						?'defaulting to MCIT, person's academicDepartment is null\n';
					}
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
					var company = person.customAttributes.academicDepartment;
					if(company == null){
						company = ApplicationEntity.getResultSet("Company").query("name = 'MCIT'").elements().item(1);
						?'defaulting to MCIT, person's academicDepartment is null\n';
					}
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
			var company = person.customAttributes.academicDepartment;
			if(company == null){
				company = ApplicationEntity.getResultSet("Company").query("name = 'MCIT'").elements().item(1);
				?'defaulting to MCIT, person's academicDepartment is null\n';
			}
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

	/*
		1d. set parent Protocol;
	*/
		{{#if topaz.parentProtocol.id}}
			var parentProtocol_1 = ApplicationEntity.getResultSet('_IACUC Study').query("ID='{{topaz.parentProject.id}}'");
			if(parentProtocol_1.count() > 0){
				parentProtocol_1 = parentProtocol_1.elements().item(1);
				cageCard.setQualifiedAttribute('customAttributes.IACUCProtocol', parentProtocol_1);
				?'setting cageCard.parentProtocol =>'+cageCard.customAttributes.IACUCProtocol+'\n';
			}
		{{/if}}

}
else{
	cageCard = cageCard.elements().item(1);
	?'DLAR.cageCard protocol found =>'+cageCard.ID+'\n';
	//update fields below total animal #.
}
}
else{
	?'Error: Parent Protocol Not Found, ID=>{{topaz.parentProject.id}}\n';
}
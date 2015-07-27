{{#if id}}
	var cageCard_id ="{{id}}";
	?'cage card ID for data migration => '+cageCard_id+'\n';
	var parentProtocolID = animalOrder_id.substr(0, animalOrder_id.lastIndexOf(":"));
	?'parentProtocolID => '+parentProtocolID+'\n';
{{else}}
	var cageCard_id = _CageCard.getID();
{{/if}}

?'CAGE CARD ID =>'+cageCard_id+'\n';
var cageCard = ApplicationEntity.getResultSet('_CageCard').query("ID='"+cageCard_id+"'");
?'cageCard.count() =>'+cageCard.count()+'\n';

var parentProtocol = ApplicationEntity.getResultSet('_IACUC Study').query("ID='"+parentProtocolID+"'");

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
						?'defaulting to MCIT, persons academicDepartment is null\n';
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
						?'defaulting to MCIT, persons academicDepartment is null\n';
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
				?'defaulting to MCIT, persons academicDepartment is null\n';
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

		var parentProtocol_1 = ApplicationEntity.getResultSet('_IACUC Study').query("ID='"+parentProtocolID+"'");
		if(parentProtocol_1.count() > 0){
			parentProtocol_1 = parentProtocol_1.elements().item(1);
			cageCard.setQualifiedAttribute('customAttributes.IACUCProtocol', parentProtocol_1);
			?'setting cageCard.parentProtocol =>'+cageCard.customAttributes.IACUCProtocol+'\n';
		}

	/*
		1e. set status
	*/
		{{#if status.oid}}
			var status = entityUtils.getObjectFromString('{{status.oid}}');
			cageCard.status = status;
			?'setting cageCard status => '+cageCard.status+'\n';
		{{/if}}

	/*
		2a. setting cage card legacy info
	*/

		var cageLegacyInfo = cageCard.customAttributes.legacyCageCardInfo;
		if(cageLegacyInfo == null){
			cageCard.customAttributes.legacyCageCardInfo = _CageCardLegacyInfo.createEntity();
			cageLegacyInfo = cageCard.customAttributes.legacyCageCardInfo;
			?'created cagecard entity => '+cageLegacyInfo+'\n';
		}

		{{#if legacyCageCardInfo.accountNumber}}
			/*
				3a. set legacyCageCardInfo.accountNumber
			*/
			var legacyAccountNumber = "{{legacyCageCardInfo.accountNumber}}";
			cageCard.customAttributes.legacyCageCardInfo.setQualifiedAttribute("customAttributes.accountNumber", legacyAccountNumber);
			?'setting legacyCageCardInfo => '+cageCard.customAttributes.legacyCageCardInfo.customAttributes.accountNumber+'\n';
		{{/if}}

		{{#if legacyCageCardInfo.cageCardID}}
			/*
				3b. set legacyCageCardInfo.cageCardID
			*/
			var legacyCageCardID = "{{legacyCageCardInfo.cageCardID}}";
			cageCard.customAttributes.legacyCageCardInfo.setQualifiedAttribute("customAttributes.cageCardID", legacyCageCardID);
			?'setting legacyCageCardID => '+cageCard.customAttributes.legacyCageCardInfo.customAttributes.cageCardID+'\n';
		{{/if}}

		{{#if legacyCageCardInfo.cageCardNumberOfAnimal}}
			/*
				3c. set legacyCageCardInfo.cageCardNumberOfAnimal
			*/
			var legacyCageCardNumAnimal = "{{legacyCageCardInfo.cageCardNumberOfAnimal}}";
			cageCard.customAttributes.legacyCageCardInfo.setQualifiedAttribute("customAttributes.cageCardNumberOfAnimal", legacyCageCardNumAnimal);
			?'setting legacyCageCardNumAnimal => '+cageCard.customAttributes.legacyCageCardInfo.customAttributes.cageCardNumberOfAnimal+'\n';
		{{/if}}

		{{#if legacyCageCardInfo.censusActiveDate}}
			/*
				3d. set legacyCageCardInfo.censusActiveDate
			*/
			var legacyCensusActiveDate = "{{legacyCageCardInfo.censusActiveDate}}";
			cageCard.customAttributes.legacyCageCardInfo.setQualifiedAttribute("customAttributes.censusActiveDate", legacyCensusActiveDate);
			?'setting legacyCensusActiveDate => '+cageCard.customAttributes.legacyCageCardInfo.customAttributes.censusActiveDate+'\n';
		{{/if}}

		{{#if legacyCageCardInfo.clickAnimalOrderLineItem}}
			/*
				3e. set legacyCageCardInfo.clickAnimalOrderLineItem
			*/
			var legacyAnimalOrderLineItem = "{{legacyCageCardInfo.clickAnimalOrderLineItem}}";
			cageCard.customAttributes.legacyCageCardInfo.setQualifiedAttribute("customAttributes.clickAnimalOrderLineItem", legacyAnimalOrderLineItem);
			?'setting legacyCensusActiveDate => '+cageCard.customAttributes.legacyCageCardInfo.customAttributes.clickAnimalOrderLineItem+'\n';
		{{/if}}

}
else{
	cageCard = cageCard.elements().item(1);
	?'DLAR.cageCard protocol found =>'+cageCard.ID+'\n';
	//update fields below total animal #.
}
}
else{
	?'Error: Parent Protocol Not Found, ID=>'+parentProtocolID+'\n';
}
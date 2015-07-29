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
			cageLegacyInfo.ID = cageCard_id;
			?'setting cageCard legacyInfo.ID => '+cageLegacyInfo.ID+'\n';
		}

		{{#if legacyCageCardInfo.accountNumber}}
			/*
				3a. set legacyCageCardInfo.accountNumber
			*/
			var legacyAccountNumber = "{{legacyCageCardInfo.accountNumber}}";
			cageCard.customAttributes.legacyCageCardInfo.setQualifiedAttribute("customAttributes.accountNumber", legacyAccountNumber);
			?'setting legacyAccountNumber => '+cageCard.customAttributes.legacyCageCardInfo.customAttributes.accountNumber+'\n';
		{{/if}}

		{{#if legacyCageCardInfo.cageCardID}}
			/*
				3b. set legacyCageCardInfo.cageCardID
			*/
			var legacyCageCardID = "{{legacyCageCardInfo.cageCardID}}";
			cageCard.customAttributes.legacyCageCardInfo.setQualifiedAttribute("customAttributes.cageCardID", legacyCageCardID);
			?'setting legacyCageCardID => '+cageCard.customAttributes.legacyCageCardInfo.customAttributes.cageCardID+'\n';
		{{/if}}

		{{#if legacyCageCardInfo.cageCardLegacyID}}
			/*
				3c. set legacyCageCardInfo.cageCardLegacyID
			*/
			var legacyCageCardID_1 = {{legacyCageCardInfo.cageCardLegacyID}};
			cageCard.customAttributes.legacyCageCardInfo.setQualifiedAttribute("customAttributes.cageCardLegacyID", legacyCageCardID_1);
			?'setting legacyCageCardID_1 => '+cageCard.customAttributes.legacyCageCardInfo.customAttributes.cageCardLegacyID+'\n';
		{{/if}}

		{{#if legacyCageCardInfo.cageCardNumberOfAnimal}}
			/*
				3d. set legacyCageCardInfo.cageCardNumberOfAnimal
			*/
			var legacyCageCardNumAnimal = {{legacyCageCardInfo.cageCardNumberOfAnimal}};
			cageCard.customAttributes.legacyCageCardInfo.setQualifiedAttribute("customAttributes.cageCardNumberOfAnimal", legacyCageCardNumAnimal);
			?'setting legacyCageCardNumAnimal => '+cageCard.customAttributes.legacyCageCardInfo.customAttributes.cageCardNumberOfAnimal+'\n';
		{{/if}}

		{{#if legacyCageCardInfo.censusActiveDate}}
			/*
				3e. set legacyCageCardInfo.censusActiveDate
			*/
			var date = "{{legacyCageCardInfo.censusActiveDate}}";
			var dateArray = date.split('-');
			var day = dateArray[2].substring(0,2);
			var month = dateArray[1] - 1;
			var year = dateArray[0];
			var a = new Date(year, month, day);
			cageCard.customAttributes.legacyCageCardInfo.setQualifiedAttribute("customAttributes.censusActiveDate", a);
			?'setting legacyCensusActiveDate => '+cageCard.customAttributes.legacyCageCardInfo.customAttributes.censusActiveDate+'\n';
		{{/if}}

		{{#if legacyCageCardInfo.clickAnimalOrderLineItem}}
			/*
				3f. set legacyCageCardInfo.clickAnimalOrderLineItem
			*/
			var legacyAnimalOrderLineItem = "{{legacyCageCardInfo.clickAnimalOrderLineItem}}";
			cageCard.customAttributes.legacyCageCardInfo.setQualifiedAttribute("customAttributes.clickAnimalOrderLineItem", legacyAnimalOrderLineItem);
			?'setting legacyAnimalOrderLineItem => '+cageCard.customAttributes.legacyCageCardInfo.customAttributes.clickAnimalOrderLineItem+'\n';
		{{/if}}

		{{#if legacyCageCardInfo.costCenter}}
			/*
				3g. set legacyCageCardInfo.costCenter
			*/
			var legacyCostCenter = "{{legacyCageCardInfo.costCenter}}";
			cageCard.customAttributes.legacyCageCardInfo.setQualifiedAttribute("customAttributes.costCenter", legacyCostCenter);
			?'setting legacyCostCenter => '+cageCard.customAttributes.legacyCageCardInfo.customAttributes.costCenter+'\n';
		{{/if}}

		{{#if legacyCageCardInfo.deliveryID}}
			/*
				3h. set legacyCageCardInfo.deliveryID
			*/
			var legacyDeliverID = {{legacyCageCardInfo.deliveryID}};
			cageCard.customAttributes.legacyCageCardInfo.setQualifiedAttribute("customAttributes.deliveryID", legacyDeliverID);
			?'setting legacyDeliverID => '+cageCard.customAttributes.legacyCageCardInfo.customAttributes.deliveryID+'\n';
		{{/if}}

		{{#if legacyCageCardInfo.deliveryNumber}}
			/*
				3i. set legacyCageCardInfo.deliveryNumber
			*/
			var legacyDeliverNumber = {{legacyCageCardInfo.deliveryNumber}};
			cageCard.customAttributes.legacyCageCardInfo.setQualifiedAttribute("customAttributes.deliveryNumber", legacyDeliverNumber);
			?'setting legacyDeliverNumber => '+cageCard.customAttributes.legacyCageCardInfo.customAttributes.deliveryNumber+'\n';
		{{/if}}

		{{#if legacyCageCardInfo.legacyOrderNumber}}
			/*
				3j. set legacyCageCardInfo.legacyOrderNumber
			*/
			var legacyOrderNumber = {{legacyCageCardInfo.legacyOrderNumber}};
			cageCard.customAttributes.legacyCageCardInfo.setQualifiedAttribute("customAttributes.legacyOrderNumber", legacyOrderNumber);
			?'setting legacyOrderNumber => '+cageCard.customAttributes.legacyCageCardInfo.customAttributes.legacyOrderNumber+'\n';
		{{/if}}

		{{#if legacyCageCardInfo.location}}
			/*
				3k. set legacyCageCardInfo.location
			*/
			var legacyLocation = "{{legacyCageCardInfo.location}}";
			cageCard.customAttributes.legacyCageCardInfo.setQualifiedAttribute("customAttributes.location", legacyLocation);
			?'setting legacyLocation => '+cageCard.customAttributes.legacyCageCardInfo.customAttributes.location+'\n';
		{{/if}}

		{{#if legacyCageCardInfo.order}}
			/*
				3l. set legacyCageCardInfo.order
			*/
			var legacyOrder = "{{legacyCageCardInfo.order}}";
			cageCard.customAttributes.legacyCageCardInfo.setQualifiedAttribute("customAttributes.order", legacyOrder);
			?'setting legacyOrder => '+cageCard.customAttributes.legacyCageCardInfo.customAttributes.order+'\n';
		{{/if}}

		{{#if legacyCageCardInfo.protocol}}
			/*
				3m. set legacyCageCardInfo.protocol
			*/
			var legacyProtocol = "{{legacyCageCardInfo.protocol}}";
			cageCard.customAttributes.legacyCageCardInfo.setQualifiedAttribute("customAttributes.protocol", legacyProtocol);
			?'setting legacyProtocol => '+cageCard.customAttributes.legacyCageCardInfo.customAttributes.protocol+'\n';
		{{/if}}

		{{#if legacyCageCardInfo.protocolSegment}}
			/*
				3n. set legacyCageCardInfo.protocolSegment
			*/
			var legacyProtocolSegment = "{{legacyCageCardInfo.protocolSegment}}";
			cageCard.customAttributes.legacyCageCardInfo.setQualifiedAttribute("customAttributes.protocolSegment", legacyProtocolSegment);
			?'setting legacyProtocolSegment => '+cageCard.customAttributes.legacyCageCardInfo.customAttributes.protocolSegment+'\n';
		{{/if}}

		{{#if legacyCageCardInfo.requisitionNumber}}
			/*
				3o. set legacyCageCardInfo.requisitionNumber
			*/
			var legacyRequisitionNumber = "{{legacyCageCardInfo.requisitionNumber}}";
			cageCard.customAttributes.legacyCageCardInfo.setQualifiedAttribute("customAttributes.requisitionNumber", legacyRequisitionNumber);
			?'setting legacyRequisitionNumber => '+cageCard.customAttributes.legacyCageCardInfo.customAttributes.requisitionNumber+'\n';
		{{/if}}

		{{#if legacyCageCardInfo.segmentSequence}}
			/*
				3p. set legacyCageCardInfo.segmentSequence
			*/
			var legacySegmentSequence = {{legacyCageCardInfo.segmentSequence}};
			cageCard.customAttributes.legacyCageCardInfo.setQualifiedAttribute("customAttributes.segmentSequence", legacySegmentSequence);
			?'setting legacySegmentSequence => '+cageCard.customAttributes.legacyCageCardInfo.customAttributes.segmentSequence+'\n';
		{{/if}}

		{{#if legacyCageCardInfo.species}}
			/*
				3q. set legacyCageCardInfo.species
			*/
			var legacySpecies = "{{legacyCageCardInfo.species}}";
			cageCard.customAttributes.legacyCageCardInfo.setQualifiedAttribute("customAttributes.species", legacySpecies);
			?'setting legacySpecies => '+cageCard.customAttributes.legacyCageCardInfo.customAttributes.species+'\n';
		{{/if}}

		{{#if legacyCageCardInfo.staff}}
			/*
				3q. set legacyCageCardInfo.staff
			*/
			var legacyStaff = "{{legacyCageCardInfo.staff}}";
			cageCard.customAttributes.legacyCageCardInfo.setQualifiedAttribute("customAttributes.staff", legacyStaff);
			?'setting legacyStaff => '+cageCard.customAttributes.legacyCageCardInfo.customAttributes.staff+'\n';
		{{/if}}

		{{#if legacyCageCardInfo.status}}
			/*
				3r. set legacyCageCardInfo.status
			*/
			var legacyStatus = "{{legacyCageCardInfo.status}}";
			cageCard.customAttributes.legacyCageCardInfo.setQualifiedAttribute("customAttributes.status", legacyStatus);
			?'setting legacyStatus => '+cageCard.customAttributes.legacyCageCardInfo.customAttributes.status+'\n';
		{{/if}}

		{{#if legacyCageCardInfo.userID}}
			/*
				3s. set legacyCageCardInfo.userID
			*/
			var legacyUserID = "{{legacyCageCardInfo.userID}}";
			cageCard.customAttributes.legacyCageCardInfo.setQualifiedAttribute("customAttributes.legacyUserID", legacyUserID);
			?'setting legacyUserID => '+cageCard.customAttributes.legacyCageCardInfo.customAttributes.userID+'\n';
		{{/if}}

		{{#if legacyCageCardInfo.userReferenceNumber}}
			/*
				3t. set legacyCageCardInfo.userReferenceNumber
			*/
			var legacyUserReferenceNumber = "{{legacyCageCardInfo.userReferenceNumber}}";
			cageCard.customAttributes.legacyCageCardInfo.setQualifiedAttribute("customAttributes.legacyUserID", legacyUserReferenceNumber);
			?'setting legacyUserReferenceNumber => '+cageCard.customAttributes.legacyCageCardInfo.customAttributes.userReferenceNumber+'\n';
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
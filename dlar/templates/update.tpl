{{#if protocolNumber}}
	var iacuc_id = "{{protocolNumber}}";
	iacuc_id = iacuc_id.split('-')[0];
{{else}}
	var iacuc_id ="{{this.id}}";
{{/if}}

?'DLAR ID =>'+iacuc_id+'\n';

var iacucQ = ApplicationEntity.getResultSet('_IACUC Study').query("ID='"+iacuc_id+"'");
?'iacucQ.count => '+iacucQ.count()+'\n';
if(iacucQ.count() > 0){
	iacucQ = iacucQ.elements().item(1);
	?'DLAR(IACUC Study) => '+iacucQ+'\n';

	/*
		1a. protocol team members => first clear the set, then re-add each study team member
	*/

	var protocolTeamMembers = iacucQ.customAttributes.protocolTeamMembers;
	if(protocolTeamMembers == null){
		var studyTeamMemberInfo = _StudyTeamMemberINfo.createEntitySet();
		iacucQ.setQualifiedAttribute('customAttributes.protocolTeamMembers', studyTeamMemberInfo);
		protocolTeamMembers = iacucQ.customAttributes.protocolTeamMembers;
		?'created iacucQ.customAttributes.protocolTeamMembers eset=>'+protocolTeamMembers+'\n';
	}
	else{
		?'DLAR(IACUC) protocolTeamMembers => '+protocolTeamMembers+'\n';
		protocolTeamMembers.removeAll();
		?'removing all protocolTeamMembers and readding from eset => '+protocolTeamMembers+'\n';;
	}


	{{#each studyTeamMembers}}
		{{#if studyTeamMember.userId}}

			var person = ApplicationEntity.getResultSet("Person").query("userID = '{{studyTeamMember.userId}}'");
			if(person.count() > 0){
				person = person.elements().item(1);
				contactSet.addElement(person);
				?'added person to contact set =>'+person+'\n';

				var studyTeam = _StudyTeamMemberINfo.createEntity();
				?'create entity studyTeamMemberInfo => '+studyTeam+'\n';

				studyTeam.setQualifiedAttribute('customAttributes.studyTeamMember', person);
				?'set person to studyTeamMember => '+person+'\n';

				var iacucAuthorizedToOrderAnimals = "{{isAuthorizedToOrderAnimals}}";
				var iacucInvolvedInAnimalHandling = "{{isInvolvedInAnimalHandling}}";
				var dlarAuthorizedToOrderAnimals;
				var dlarInvolvedInAnimalHandling;

				if(iacucAuthorizedToOrderAnimals == "1"){
					dlarAuthorizedToOrderAnimals = true;
				}
				else{
					dlarAuthorizedToOrderAnimals = false;
				}

				if(iacucInvolvedInAnimalHandling == "1"){
					dlarInvolvedInAnimalHandling = true;
				}
				else{
					dlarInvolvedInAnimalHandling = false;
				}

				studyTeam.customAttributes.isAuthorizedToOrderAnimals = dlarAuthorizedToOrderAnimals;
				?'set isAuhtorizedToOrderAnimals => '+dlarAuthorizedToOrderAnimals+'\n';
				studyTeam.customAttributes.isInvolvedInAnimalHandling = dlarInvolvedInAnimalHandling;
				?'set isInvolvedInAnimalHandling => '+dlarInvolvedInAnimalHandling+'\n';

				protocolTeamMembers.addElement(studyTeam);
				?'added studyTeam to IACUC Study Team =>'+studyTeam+'\n';

			}

		{{/if}}
	{{/each}}

	{{#if investigator.studyTeamMember.userId}}
		var person = ApplicationEntity.getResultSet("Person").query("userID = '{{investigator.studyTeamMember.userId}}'").elements();
				
		var iacucInvolvedInAnimalHandling = '{{investigator.isInvolvedInAnimalHandling}}';
		var iacucAuthorizedToOrderAnimals = '{{investigator.isAuthorizedToOrderAnimals}}';
		var dlarAuthorizedToOrderAnimals;
		var dlarInvolvedInAnimalHandling;

		if(iacucAuthorizedToOrderAnimals == "1"){
			dlarAuthorizedToOrderAnimals = true;
		}
		else{
			dlarAuthorizedToOrderAnimals = false;
		}

		if(iacucInvolvedInAnimalHandling == "1"){
			dlarInvolvedInAnimalHandling = true;
		}
		else{
			dlarInvolvedInAnimalHandling = false;
		}

		if(person.count() > 0){
			person = person.item(1);
			contactSet.addElement(person);
			?'added person to contact set =>'+person+'\n';

			var studyTeam = _StudyTeamMemberINfo.createEntity();
			?'create entity studyTeamMemberInfo => '+studyTeam+'\n';
			studyTeam.setQualifiedAttribute('customAttributes.studyTeamMember', person);
			?'set person to studyTeamMember => '+person+'\n';
			studyTeam.customAttributes.isAuthorizedToOrderAnimals = dlarAuthorizedToOrderAnimals;
			?'set isAuhtorizedToOrderAnimals => '+dlarAuthorizedToOrderAnimals+'\n';
			studyTeam.customAttributes.isInvolvedInAnimalHandling = dlarInvolvedInAnimalHandling;
			?'set isInvolvedInAnimalHandling => '+dlarInvolvedInAnimalHandling+'\n';

			protocolTeamMembers.addElement(studyTeam);
			?'added studyTeam to IACUC Study Team =>'+studyTeam+'\n';
		}
	{{/if}}

	/*
		1b. check for isUSDA(0 => if no animals isUSDA, else 1(a animal is usda))
	*/

	/*
		1c. check husbandary exceptions => first clear the set, then re-add each husbandary exceptions
	*/

	/*
		1d. update number of animal(approved) counts
	*/

	var animalCount = 0;

	{{#each animalGroups}}
		animalCount += {{numberOfAnimals}};
	{{/each}}

	iacucQ.customAttributes._attribute71 = animalCount;
	?'setting total Number of animals for iacucQ=>'+animalCount+'\n';


	{{#each animalCounts}}

		var aCount = {{actualNumberOfAnimals}};

		if(aCount > 0){
			var animalGroupSet = iacucQ.customAttributes.SF_AnimalGroup;
			if(animalGroupSet == null){
				iacucQ.setQualifiedAttribute('customAttributes.SF_AnimalGroup',animalGroup)
				?'create eset iacucQ.customAttributes.SF_AnimalGroup=>'+animalGroup+'\n';
			}
		}

		var a = "{{speciesPainCat}}";
		var partsArray = a.split('-');
		var species = partsArray[0];
		species = species.replace(" ", "");
		var painCategory = partsArray[1];
		var painCategory_1;
		var usda = partsArray[2];
		usda = usda.replace(/^.+:/,'');
		usda = usda.replace(/\s/g,"");

		if(painCategory == painCategoryB){
			painCategory_1 = "B";
		}
		else if(painCategory == painCategoryC){
			painCategory_1 = "C";
		}
		else if(painCategory == painCategoryD){
			painCategory_1 = "D";
		}
		else if(painCategory == painCategoryE){
			painCategory_1 = "E";
		}
		else{
			?'painCategoryNotFound=>'+painCategory+'\n';
		}

		if(painCategory_1 != null){

		}
		var protoGroupName = species + ' {{painCategory.category}}';
		var exists = iacucQ.customAttributes.SF_AnimalGroup.query("customAttributes._ProtocolGroup.customAttributes._Species.customAttributes._attribute0='"+species+"'");
		if(usda == "yes" || usda == "Yes"){
			exists = exists.query("customAttributes._ProtocolGroup.customAttributes._Species.customAttributes.usdaCovered=true");
		}
		else{
			exists = exists.query("customAttributes._ProtocolGroup.customAttributes._Species.customAttributes.usdaCovered=false");
		}

		exists = exists.query("customAttributes._ProtocolGroup.customAttributes._ProtocolGroup='"+protoGroupName+"'");

		if(exists.count() > 0){
			for(var i = 1; i<=exists.count(); i++){
				var newAnimalCount = {{actualNumberOfAnimals}};
				var item = exists.elements().item(i);
				var currentAnimalCount = item.customAttributes._ProtocolGroup.customAttributes.approved;
				if(currentANimalCount != animalCount){
					?'Protocol Group => '+item+' count is different\n';
					item.customAttributes._ProtocolGroup.customAttributes.approved = newAnimalCount;
					?'setting new animal count => '+newAnimalCount+'\n';
				}
			}
		}
	{{/each}}
}
else{
	?'DLAR(IACUC Study) Not Found => '+iacuc_id+'\n';
}
{{#if protocolNumber}}
	var iacuc_id = "{{protocolNumber}}";
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
		1b. check for isUsda(0 => if no animals isUSDA, else 1(a animal is usda))
	*/

	//check husbandary exceptions => first clear the set, then re-add each husbandary exceptions


}
else{
	?'DLAR(IACUC Study) Not Found => '+iacuc_id+'\n';
}
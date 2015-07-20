{{#if protocolNumber}}
	var iacuc_id = "{{protocolNumber}}";
	var find = iacuc_id.split('-')[0];
{{else}}
	var iacuc_id ="{{this.id}}";
{{/if}}

?'DLAR ID =>'+iacuc_id+'\n';

//var iacucQ = ApplicationEntity.getResultSet('_IACUC Study').query("ID='"+find+"%'");
var iacucQ = ApplicationEntity.getResultSet('_IACUC Study').query("ID like '"+find+"%'");
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
		1b. update approval/expiration date
	*/

	{{#if approvalDate}}
		var date = "{{approvalDate}}";
		var dateArray = date.split('-');
		var day = dateArray[2].substring(0,2);
		var month = dateArray[1] - 1;
		var year = dateArray[0];
		var a = new Date(year, month, day);
		iacucQ.setQualifiedAttribute("customAttributes._attribute6", a);
		?'iacucQ.customAttributes._attribute6(Date Approved) =>'+a+'\n';
	{{/if}}

	{{#if finalExpirationDate}}
		var date = "{{finalExpirationDate}}";
		var dateArray = date.split('-');
		var day = dateArray[2].substring(0,2);
		var month = dateArray[1] - 1;
		var year = dateArray[0];
		var a = new Date(year, month, day);
		iacucQ.customAttributes._attribute10 = a;
		?'iacucQ.customAttributes._attribute10(Date Expiration) =>'+a+'\n';
	{{/if}}

	/*
		1c. check husbandary exceptions => first clear the set, then re-add each husbandary exceptions
	*/

	/*
		1d. update number of animal(approved) counts
	*/

	var animalCount = 0;

	{{#each animalCounts}}
		animalCount += {{actualNumberOfAnimals}};
	{{/each}}

	iacucQ.customAttributes._attribute71 = animalCount;
	?'setting total Number of animals for iacucQ=>'+animalCount+'\n';

	var painCategoryB = 'Pain Category B';
	var painCategoryC = 'Pain Category C';
	var painCategoryD = 'Pain Category D';
	var painCategoryE = 'Pain Category E';
	var animalGroupSet = iacucQ.customAttributes.SF_AnimalGroup;

	{{#each animalCounts}}
		var aCount = {{actualNumberOfAnimals}};

		if(aCount > 0){
			var animalGroupSet = iacucQ.customAttributes.SF_AnimalGroup;
			if(animalGroupSet == null){
				iacucQ.setQualifiedAttribute('customAttributes.SF_AnimalGroup',animalGroup)
				?'create eset iacucQ.customAttributes.SF_AnimalGroup=>'+animalGroup+'\n';
			}
		}

		var species = "{{species.commonName}}";
		species = species.replace(" ", "");
		var painCategory = "{{painCategory.category}}";
		var usda = "{{species.isUSDASpecies}}";
		var painCategory_1;

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
			var protoGroupName = species + ' {{painCategory.category}}';
			var exists = iacucQ.customAttributes.SF_AnimalGroup.query("customAttributes._ProtocolGroup.customAttributes._Species.customAttributes._attribute0='"+species+"'");
			if(usda == "yes" || usda == "Yes"){
				exists = exists.query("customAttributes._ProtocolGroup.customAttributes._Species.customAttributes.usdaCovered=true");
			}
			else{
				exists = exists.query("customAttributes._ProtocolGroup.customAttributes._Species.customAttributes.usdaCovered=false");
			}

			exists = exists.query("customAttributes._ProtocolGroup.customAttributes._ProtocolGroup='"+protoGroupName+"'");
			exists = exists.query("customAttributes._ProtocolGroup.customAttributes.usdaPainCategory.customAttributes.Category='"+painCategory_1+"'");
			?'Does Animal Exist in Set => '+exists.count()+'\n';

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
			else{
				?'Can't find animal in animal group =>'+species+'\n';
					var animalGroup = _IS_AnimalGroup.createEntity();
					var selAnimalGroup = _IS_SEL_AnimalGroup.createEntity();
					var clickPainCategory = ApplicationEntity.getResultSet('_ClickPainCategory').query("customAttributes.Category = '"+painCategory_1+"'");
					if(clickPainCategory.count() > 0){
						clickPainCategory = clickPainCategory.elements().item(1);
						selAnimalGroup.setQualifiedAttribute('customAttributes.usdaPainCategory', clickPainCategory);
						?'setting selAnimalGroup.customAttributes.usdaPainCategory =>'+clickPainCategory+'\n';
					}

					var clickSpecies = ApplicationEntity.getResultSet('_IACUC-Species').query("customAttributes._attribute0='"+species+"'");
					if(usda == "yes" || usda == "Yes"){
						clickSpecies = clickSpecies.query("customAttributes.usdaCovered=true");
					}
					else{
						clickSpecies = clickSpecies.query("customAttributes.usdaCovered=false");
					}
					if(clickSpecies.count() > 0){
						clickSpecies = clickSpecies.elements().item(1);
						selAnimalGroup.setQualifiedAttribute('customAttributes._Species', clickSpecies);
						speciesAdminSet.addElement(clickSpecies);
						?'adding clickSpeices to speciesAdminSet =>'+clickSpecies+'\n';
						?'setting selAnimalGroup.customAttributes._Species =>'+clickSpecies+'usda =>'+usda+'\n';
					}
					else{
						?'Cant find animal =>'+species+' usda =>'+usda+'\n';
					}
					selAnimalGroup.customAttributes.approved = {{actualNumberOfAnimals}};
					?'set number of approved for this animal =>{{actualNumberOfAnimals}}\n';

					var protoGroupName = species + ' {{painCategory.category}}';
					selAnimalGroup.customAttributes._ProtocolGroup = protoGroupName;
					?'set protocolGroup name =>'+protoGroupName+'\n';


					animalGroup.setQualifiedAttribute('customAttributes._ProtocolGroup', selAnimalGroup);
					animalGroupSet.addElement(animalGroup);
					?'adding eset animalGroupSet => '+animalGroup+'\n';
					groupAdminSet.addElement(selAnimalGroup);
					?'adding to eset groupAdminSet =>'+selAnimalGroup+'\n';
			}
		}
	{{/each}}

	/*
		1e. Housing update, remove all animal housing then readd
	*/
	var housingSet = iacucQ.customAttributes.SF_AnimalHousing;
	if(housingSet == null){
		iacucQ.setQualifiedAttribute('customAttributes.SF_AnimalHousing',animalHousing)
		?'create eset iacucQ.customAttributes.SF_AnimalHousing=>'+animalHousing+'\n';
	}
	else{
		housingSet.removeAllElements();
		?'removing all housing from SF_AnimalHousing and readding'
	}

	{{#each animalHousingLocationRoom}}
		 var room = ApplicationEntity.getResultSet('_Facility').query("name='{{facilityRoom.name}}'");
		 {{#if facilityRoom.facilityRoomCustomExtension.floor}}
			 room = room.query("customAttributes.floor.name='{{facilityRoom.facilityRoomCustomExtension.floor}}'");
		 {{/if}}
		 room = room.query("customAttributes.building.name='{{facilityRoom.building.name}}'");
		 room = room.query("customAttributes._attribute2='Room'");
		 if(room.count() > 0){
			room = room.elements().item(1);
			var housing = _IS_AnimalHousing.createEntity();
			?'creating animal housing =>'+housing+'\n';
			housing.setQualifiedAttribute('customAttributes.facility', room);
			?'set facility housing =>'+room+'\n';

			housingAdminSet.addElement(room)+'\n';
			?'adding to housingAdminSet => '+room+'\n';

			var animalHousingGroupSet = _IS_SEL_AnimalGroup.createEntitySet();
			housing.customAttributes._ProtocolGroup = animalHousingGroupSet;
			?'creating housing.groupSet =>'+animalHousingGroupSet+'\n';

			var animalHousingGroupSet_1 = housing.customAttributes._ProtocolGroup;

			{{#each species}}		
				var findAnimal = "{{commonName}}";		 	
				var exists = iacucQ.customAttributes.SF_AnimalGroup.query("customAttributes._ProtocolGroup.customAttributes._Species.customAttributes._attribute0='{{commonName}}'");
				if(exists.count() > 0){
					for(var i = 1; i<=exists.count(); i++){
					 	var animal = exists.elements().item(i).customAttributes._ProtocolGroup;
					 	var animal_name = animal.customAttributes._Species.customAttributes._attribute0;
					 	if(findAnimal == animal_name){
					 		animalHousingGroupSet_1.addElement(animal);
					 		?'adding animal to housing.animalSet =>'+animal+'\n';

					 	}
					 }
				}
			 {{/each}}
			housingSet.addElement(housing);
			?'adding to housingSet => '+housing+'\n';
		 }
		else{
			?'Room Number Not Found => {{facilityRoom.name}}\n';
			{{#if facilityRoom.facilityRoomCustomExtension.floor}}
				?'Floor => {{facilityRoom.facilityRoomCustomExtension.floor}}\n';
			{{/if}}
			?'Building => {{facilityRoom.building.name}}\n';
		}
	{{/each}}

	{{#each vivariumHousingLocations}}
		var room = ApplicationEntity.getResultSet('_Facility').query("name='{{facilityBuilding.name}}'");
		room = room.query("customAttributes._attribute2='Building'");
		if(room.count() > 0){
			room = room.elements().item(1);
			var housing = _IS_AnimalHousing.createEntity();
			?'creating animal housing =>'+housing+'\n'
			housing.setQualifiedAttribute('customAttributes.facility', room);
			?'set facility housing =>'+room+'\n';

			housingAdminSet.addElement(room);
			?'adding to eset housingAdminSet => '+room+'\n';

			var animalHousingGroupSet = _IS_SEL_AnimalGroup.createEntitySet();
			housing.customAttributes._ProtocolGroup = animalHousingGroupSet;
			?'creating housing.groupSet =>'+animalHousingGroupSet+'\n';

			var animalHousingGroupSet_1 = housing.customAttributes._ProtocolGroup;

			{{#each species}}		
				var findAnimal = "{{commonName}}";		 	
				var exists = iacucQ.customAttributes.SF_AnimalGroup.query("customAttributes._ProtocolGroup.customAttributes._Species.customAttributes._attribute0='{{commonName}}'");
				if(exists.count() > 0){
					for(var i = 1; i<=exists.count(); i++){
					 	var animal = exists.elements().item(i).customAttributes._ProtocolGroup;
					 	var animal_name = animal.customAttributes._Species.customAttributes._attribute0;
					 	if(findAnimal == animal_name){
					 		animalHousingGroupSet_1.addElement(animal);
					 		?'adding animal to housing.animalSet =>'+animal+'\n';
					 	}
					}
				}
			{{/each}}
			housingSet.addElement(housing);
			?'adding Animal Housing to Housing set => '+housing+'\n';
		}
		else{
			?'Building Not Found => {{facilityBuilding.name}}\n';
		}
	{{/each}}

	{{#each longTermNonVivariumHousingLocations}}
		/*
			SF: lab locations - not done yet
		*/
	{{/each}}
}
else{
	?'DLAR(IACUC Study) Not Found => '+iacuc_id+'\n';
}
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
			?'DLAR.iacucQ protocol found =>'+iacucQ.ID+'\n';
			//update fields below total animal #.

			/*
				1a. protocol team members => first clear the set, then re-add each study team member
					contacts => first clear the set then re-add each study team member
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
				protocolTeamMembers.removeAllElements();
				?'removing all protocolTeamMembers and readding from eset => '+protocolTeamMembers+'\n';;
			}

			var contactSet = iacucQ.contacts;
			if(contactSet == null){
				iacucQ.contacts = Person.createEntitySet();
				?'created contacts eset => '+iacucQ.contacts+'\n';
				contactSet = iacucQ.contacts;
			}
			else{
				?'DLAR(IACUC) contacts => '+contactSet+'\n';
				contactSet.removeAllElements();
				?'removing all contacts from list \n';
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
				1b. Assigning PI to Study
			*/
			//assigning PI to Study(IACUCQ)
			{{#if investigator.studyTeamMember.userId}}
				var investigator = iacucQ.getQualifiedAttribute("customAttributes._attribute7");

				var person = ApplicationEntity.getResultSet("Person").query("userID = '{{investigator.studyTeamMember.userId}}'").elements();
					
				if(investigator == null && person.count() > 0){
					person = person.item(1);
					iacucQ.setQualifiedAttribute("customAttributes._attribute7", person);
					?'person adding as PI =>'+person.userID+'\n';
				}
			{{/if}}

			/*
				1c. update contact for department admins
			*/
			contactSet = iacucQ.contacts;
			var deptAdmin = iacucQ.customAttributes.departmentAdministrators;
			for(var i = 1; i<= deptAdmin.count(); i++){
				var personToAdd = deptAdmin.elements().item(i);
				contactSet.addElement(personToAdd);
				?'added dept admin to contact set => '+personToAdd+'\n';

			}

			/*
				approval/annual expiration date
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

			/*
			** 07-20-2015 => Sandy => DLAR wants the annual expiration date
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
			*/

			{{#if annualExpirationDate}}
				var date = "{{annualExpirationDate}}";
				var dateArray = date.split('-');
				var day = dateArray[2].substring(0,2);
				var month = dateArray[1] - 1;
				var year = dateArray[0];
				var a = new Date(year, month, day);
				iacucQ.customAttributes._attribute10 = a;
				?'iacucQ.customAttributes._attribute10(Date Expiration) =>'+a+'\n';
			{{/if}}

	/*
		updating species
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
	var groupAdminSet = iacucQ.customAttributes.groups;
	var speciesAdminSet = iacucQ.customAttributes._attribute32;
	var speciesArrayNew = [];
	var speciesArrayOrig = [];
	var speciesArrayNotFound = [];

	var animalGroupSet = iacucQ.customAttributes.SF_AnimalGroup;
	if(animalGroupSet == null){
		var animalGroup = _IS_AnimalGroup.createEntitySet();
		iacucQ.setQualifiedAttribute('customAttributes.SF_AnimalGroup',animalGroup)
		?'create eset iacucQ.customAttributes.SF_AnimalGroup=>'+animalGroup+'\n';
		animalGroupSet = iacucQ.customAttributes.SF_AnimalGroup;
	}
	else{
		for(var i = 1; i<=animalGroupSet.count(); i++){
			var name = animalGroupSet.elements().item(i).customAttributes._ProtocolGroup.customAttributes._ProtocolGroup;
			speciesArrayOrig.push({"species":name});
		}
	}

	if(groupAdminSet == null){
		var group = _IS_SEL_AnimalGroup.createEntitySet();
		iacucQ.setQualifiedAttribute('customAttributes.groups', group);
		?'create eset iacucQ.customAttributes.groups=>'+group+'\n';
		groupAdminSet = iacucQ.customAttributes.groups;
	}

	{{#each animalCounts}}
		var aCount = {{actualNumberOfAnimals}};

		if(aCount > 0){
			var species = "{{species.commonName}}";
			//species = species.replace(" ", "");
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

			var protoGroupName_1 = species + ' {{painCategory.category}}';
			speciesArrayNew.push({"species":protoGroupName_1});

			if(painCategory_1 != null){
				var protoGroupName = species + ' {{painCategory.category}}';
				var exists = iacucQ.customAttributes.SF_AnimalGroup.query("customAttributes._ProtocolGroup.customAttributes._Species.customAttributes._attribute0='"+species+"'");
				if(usda == "yes" || usda == "Yes" || usda == "1"){
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
						var currentAnimalAvaliable = item.customAttributes._ProtocolGroup.customAttributes.available;
						var currentAnimalUsed = item.customAttributes._ProtocolGroup.customAttributes.used;
						var currentAnimalOnOrder = item.customAttributes._ProtocolGroup.customAttributes.onOrder;
						var totalOrderUsed = currentAnimalUsed+currentAnimalOnOrder;
						if(currentAnimalCount != newAnimalCount){
							?'Protocol Group => '+item+' count is different\n';
							item.customAttributes._ProtocolGroup.customAttributes.approved = newAnimalCount;
							?'setting new animal count => '+newAnimalCount+'\n';
						}

						if(currentAnimalAvaliable != newAnimalCount && totalOrderUsed < newAnimalCount){
							?'Protocol Group => '+item+' count is different and there is more animal avaliable\n';
							var newAvaliable = newAnimalCount - totalOrderUsed;
							item.customAttributes._ProtocolGroup.customAttributes.available = newAvaliable;
							?'setting new animal count(available) => '+newAvaliable+'\n';
						}
						else if(currentAnimalAvaliable != newAnimalCount && totalOrderUsed == 0){
							?'Protocol Group => '+item+' no animal used or on order\n';
							var newAvaliable = newAnimalCount;
							item.customAttributes._ProtocolGroup.customAttributes.available = newAvaliable;
							?'setting new animal count(available) => '+newAvaliable+'\n';
						}
						else if(currentAnimalAvaliable == newAnimalCount){
							?'Protocol Group => '+item+' avaliable count is same\n';
						}
						else{
							?'Protocol Group => '+item+' count is different and there less animal avaliable\n';
							item.customAttributes._ProtocolGroup.customAttributes.available = 0;
							?'setting new animal count(available) => 0\n';	
						}
					}
				}
				else{
					?'Cant find animal in animal group =>'+species+'\n';
						var clickSpecies = ApplicationEntity.getResultSet('_IACUC-Species').query("customAttributes._attribute0='"+species+"'");
						if(usda == "yes" || usda == "Yes" || usda == "1"){
							clickSpecies = clickSpecies.query("customAttributes.usdaCovered=true");
						}
						else{
							clickSpecies = clickSpecies.query("customAttributes.usdaCovered=false");
						}
						if(clickSpecies.count() > 0){
							var animalGroup = _IS_AnimalGroup.createEntity();
							var selAnimalGroup = _IS_SEL_AnimalGroup.createEntity();
							var clickPainCategory = ApplicationEntity.getResultSet('_ClickPainCategory').query("customAttributes.Category = '"+painCategory_1+"'");
							if(clickPainCategory.count() > 0){
								clickPainCategory = clickPainCategory.elements().item(1);
								selAnimalGroup.setQualifiedAttribute('customAttributes.usdaPainCategory', clickPainCategory);
								?'setting selAnimalGroup.customAttributes.usdaPainCategory =>'+clickPainCategory+'\n';
							}


								clickSpecies = clickSpecies.elements().item(1);
								selAnimalGroup.setQualifiedAttribute('customAttributes._Species', clickSpecies);
								speciesAdminSet.addElement(clickSpecies);
								?'adding clickSpeices to speciesAdminSet =>'+clickSpecies+'\n';
								?'setting selAnimalGroup.customAttributes._Species =>'+clickSpecies+'usda =>'+usda+'\n';

								selAnimalGroup.customAttributes.approved = {{actualNumberOfAnimals}};
								?'set number of approved for this animal =>{{actualNumberOfAnimals}}\n';
								selAnimalGroup.customAttributes.available = {{actualNumberOfAnimals}};
								?'set number of avaliable for this animal =>{{actualNumberOfAnimals}}\n';

								var protoGroupName = species + ' {{painCategory.category}}';
								selAnimalGroup.customAttributes._ProtocolGroup = protoGroupName;
								?'set protocolGroup name =>'+protoGroupName+'\n';


								animalGroup.setQualifiedAttribute('customAttributes._ProtocolGroup', selAnimalGroup);
								animalGroupSet.addElement(animalGroup);
								?'adding eset animalGroupSet => '+animalGroup+'\n';
								groupAdminSet.addElement(selAnimalGroup);
								?'adding to eset groupAdminSet =>'+selAnimalGroup+'\n';
					}								
					else{
						?'Cant find animal =>'+species+' usda =>'+usda+'\n';
					}

				}
			}
		}
	{{/each}}

	for(var i=0; i<speciesArrayOrig.length; i++) {
	   var exists = false;
	   var origArrayItem = speciesArrayOrig[i].species;
	   for(var j=0; j<speciesArrayNew.length; j++){
	       var newArrayItem = speciesArrayNew[j].species;
	       if(origArrayItem == newArrayItem){
	         exists = true;
	       }  
	   }
	   if(exists == false){
	      var item = speciesArrayOrig[i].species;
	      speciesArrayNotFound.push({"species":item});
	      var exists = animalGroupSet.query("customAttributes._ProtocolGroup.customAttributes._ProtocolGroup='"+item+"'");
		   if(exists.count() > 0){
		   		var item_1 = exists.elements().item(1);
		   		?'animalGroupItem not longer used in IACUC => '+item_1+'\n';
		   		item_1.customAttributes._ProtocolGroup.customAttributes.approved = 0;
		   		?'setting approved animal count => 0\n';
				item_1.customAttributes._ProtocolGroup.customAttributes.available = 0;
				?'setting available animal count => 0\n';
		   }
		   else{
		   	?'species not found => '+item+'\n';
		   }
	   }
	}


			var count = iacucQ.customAttributes._attribute71;
			if(count > 0){
				iacucQ.calculateTotals();
				?'recalculating total animal counts\n';
			}
/*
	Locations Update
*/
	
	/*
		1e. Housing update, remove all animal housing then readd
	*/
	var housingSet = iacucQ.customAttributes.SF_AnimalHousing;
	var housingAdminSet = iacucQ.customAttributes.housingFacilities;
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

	/*
		3a. common procedures/variable procedures/husbandryExceptions
	*/

}
else{
	?'DLAR(IACUC Study) Not Found => '+iacuc_id+'\n';
}
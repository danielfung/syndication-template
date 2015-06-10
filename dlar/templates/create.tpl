{{#if protocolNumber}}
	var iacuc_id = "{{protocolNumber}}";
{{else}}
	var iacuc_id ="{{this.id}}";
{{/if}}

?'IACUC ID =>'+iacuc_id+'\n';
var iacuc;
var iacucQ = ApplicationEntity.getResultSet('_IACUC Study').query("ID='"+iacuc_id+"'");
?'iacucQ.count() =>'+iacucQ.count()+'\n';

/*
	1. Create iacuc Submission if it doesn't exist.
*/
if(iacucQ.count() == 0){
	iacucQ = wom.createTransientEntity('_IACUC Study');
	?'DLAR.iacucQ =>'+iacucQ+'\n';

	/*
		1a. update ID of iacuc Submission
	*/

		iacucQ.ID = iacuc_id;
		?'iacucQ.ID =>'+iacucQ.ID+'\n';

	/*
		1b. Register and initalize iacuc Submission
	*/
		iacucQ.registerEntity();
		//iacucQ.initalize();
		//initalize
		var iacucQ = ApplicationEntity.getResultSet('_IACUC Study').query("ID='"+iacuc_id+"'").elements().item(1);

	/*
		1c. set required fields (owner, company, createdby, pi)
		if company not found --> default to MCIT
		if createdBy not found --> default to Sys Admin
		if PI not found --> leave empty
		if owner not found --> default to PI
	*/
		{{#if company}}
			var company = iacucQ.company;
			if(company == null){
				var a = ApplicationEntity.getResultSet("Company").query("ID = '{{company.id}}'");
				if(a.count()>0){
					iacucQ.company = a.elements().item(1);
					?'iacucQ.company =>'+iacucQ.company+'\n';
				}
				else{
					?'Company Not Found =>{{company.id}}\n';
				}
			}
		{{else}}
			var company = ApplicationEntity.getResultSet("Company").query("NAME = 'MCIT'").elements().item(1);
			iacucQ.company = company;
			?'defaulting iacucQ.company => MCIT: '+company+'\n';

		{{/if}}

		//createdby - temporary
		{{#if createdBy.userId}}
			var create = iacucQ.createdBy;
			if(create == null){
				var person = ApplicationEntity.getResultSet("Person").query("userID = '{{createdBy.userId}}'");
				if(person.count() > 0){
					person = person.elements().item(1);
					iacucQ.createdBy = person;
					?'iacucQ.createdBy =>'+iacucQ.createdBy+'\n';
				}
				else{
					?'Person Not Found =>{{createdBy.userId}}\n';
					var person = ApplicationEntity.getResultSet("Person").query("userID = 'administrator'").elements().item(1);
					iacucQ.createdBy = person;
					?'defaulting iacucQ.createdBy => administrator: '+iacucQ.createdBy+'\n';
				}
			}
		{{else}}
			var person = ApplicationEntity.getResultSet("Person").query("userID = 'administrator'").elements().item(1);
			iacucQ.createdBy = person;
			?'defaulting iacucQ.createdBy => administrator: '+iacucQ.createdBy+'\n';

		{{/if}}

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

		{{#if owner}}
			var person = ApplicationEntity.getResultSet("Person").query("userID = '{{owner.userId}}'").elements();
			var owner = iacucQ.owner;
			if(owner == null && person.count() > 0){
				person = person.item(1);
				iacucQ.owner = person;
				?'person adding as owner =>'+person.userID+'\n';
			}

		{{else}}
			var person = ApplicationEntity.getResultSet("Person").query("userID = '{{investigator.studyTeamMember.userId}}'").elements();
			var owner = iacucQ.owner;
			if(owner == null && person.count() > 0){
				person = person.item(1);
				iacucQ.owner = person;
				?'setting PI as owner =>'+person.userID+'\n';
			}
		{{/if}}

	/*
		1d. set irb status to Active
			set dateCreated/dateModified/date Approved(if avaliable);
	*/
		var status = iacucQ.status;
		if(status == null){
			var statusOID = ApplicationEntity.getResultSet('ProjectStatus').query("ID='Pending Accounts'").elements().item(1);
			iacucQ.status = statusOID;
			?'iacucQ.status =>'+iacucQ.status.ID+'\n';
		}

		var dateCreate = iacucQ.dateCreated;
		if(dateCreate == null){
			iacucQ.dateCreated = new Date();
			?'iacucQ.dateCreated =>'+iacucQ.dateCreated+'\n';
		}

		var dateMod = iacucQ.dateModified;
		if(dateMod == null){
			iacucQ.dateModified = new Date();
			?'iacucQ.dateModified =>'+iacucQ.dateModified+'\n';
		}

		{{#if approvalDate}}
			var date = "{{approvalDate}}";
			var dateArray = date.split('-');
			var day = dateArray[2].substring(0,2);
			var month = dateArray[1] - 1;
			var year = dateArray[0];
			var a = new Date(year, month, day);
			iacucQ.customAttributes._attribute6 = a;
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
		1e. set resourceContainer.template
	*/
		var parentOID = "com.webridge.entity.Entity[OID[CBE99B3EEC5F2F4590DDF42629347777]]";
		theParent = EntityUtils.getObjectFromString(parentOID);
		var wsTemplate = EntityUtils.getObjectFromString("com.webridge.entity.Entity[OID[75AD149ED07BB7419E39441D9AFBC84B]]");
		var resourceContainer = iacucQ.resourceContainer;
		if(resourceContainer == null){
			if(wsTemplate != null && theParent != null){
				iacucQ.createWorkspace(theParent, wsTemplate);
				?'iacucQ.resourceContainer =>'+iacucQ.resourceContainer+'\n';
				?'iacucQ.resourceContainer.template =>'+iacucQ.resourceContainer.template+'\n';
			}
			else{
				?'Initial Template not found\n';
			}
		}

	/*
		1f. set name, shortDescription, totalNumAnimal
	*/
		iacucQ.name = "{{name}}";
		?'setting iacucQ name =>'+iacucQ.name+'\n';

		var animalCount = 0;

		{{#each animalGroups}}
			animalCount += {{numberOfAnimals}};
		{{/each}}


		/*
			1g. set total study animals approved -- need attribute from iacuc->dlar(iacuc)
		*/
		iacucQ.customAttributes._attribute71 = animalCount;
		?'setting total Number of animals for iacucQ=>'+animalCount+'\n';



	/*
		2a. create departmentAdministrators(Person) Set
	*/
		var person = Person.createEntitySet();
		iacucQ.setQualifiedAttribute('customAttributes.departmentAdministrators',person)
		?'create eset iacucQ.customAttributes.departmentAdministrators=>'+person+'\n';

	/*
		2b. create ESETS
		SF_AnimalHousing => _IS_AnimalHousing
		SF_AnimalSource  => _IS_AnimalSource
		SF_AnimalGroup => _IS_AnimalGroup
		Contact eSet => IACUC Study.contacts
	*/

		var animalHousing = _IS_AnimalHousing.createEntitySet();
		var animalSource = _IS_AnimalSource.createEntitySet();
		var animalGroup = _IS_AnimalGroup.createEntitySet();
		var contact = Person.createEntitySet();

		iacucQ.setQualifiedAttribute('customAttributes.SF_AnimalHousing',animalHousing)
		?'create eset iacucQ.customAttributes.SF_AnimalHousing=>'+animalHousing+'\n';

		iacucQ.setQualifiedAttribute('customAttributes.SF_AnimalSource',animalSource)
		?'create eset iacucQ.customAttributes.SF_AnimalSource=>'+animalSource+'\n';

		iacucQ.setQualifiedAttribute('customAttributes.SF_AnimalGroup',animalGroup)
		?'create eset iacucQ.customAttributes.SF_AnimalGroup=>'+animalGroup+'\n';

		iacucQ.contacts = contact;
		?'create eset iacucQ.contacts =>'+iacucQ.contacts+'\n';

		var painCategoryB = ' Pain Category B ';
		var painCategoryC = ' Pain Category C ';
		var painCategoryD = ' Pain Category D ';
		var painCategoryE = ' Pain Category E ';
		var speciesArray = [];
		{{#each animalGroups}}
			speciesArray.push({"species":"{{species.commonName}}", "name":"{{name}}"});
		{{/each}}
		

		{{#each animalCounts}}

			var aCount = {{actualNumberOfAnimals}};

			if(aCount > 0){
				var animalGroupSet = iacucQ.customAttributes.SF_AnimalGroup;
				if(animalGroupSet == null){
					iacucQ.setQualifiedAttribute('customAttributes.SF_AnimalGroup',animalGroup)
					?'create eset iacucQ.customAttributes.SF_AnimalGroup=>'+animalGroup+'\n';
				}

				var animalGroup = _IS_AnimalGroup.createEntity();
				var selAnimalGroup = _IS_SEL_AnimalGroup.createEntity();

				var a = "{{speciesPainCat}}";
				var partsArray = a.split('-');
				var species = partsArray[0];
				species = species.replace(" ", "");
				var painCategory = partsArray[1];
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
					var clickPainCategory = ApplicationEntity.getResultSet('_ClickPainCategory').query("customAttributes.Category = '"+painCategory_1+"'");

					if(clickPainCategory.count() > 0){
						clickPainCategory = clickPainCategory.elements().item(1);
						selAnimalGroup.setQualifiedAttribute('customAttributes.usdaPainCategory', clickPainCategory);
						?'setting selAnimalGroup.customAttributes.usdaPainCategory =>'+clickPainCategory+'\n';
					}

					var clickSpecies = ApplicationEntity.getResultSet('_IACUC-Species').query("customAttributes._attribute0='"+species+"'");
					if(clickSpecies.count() > 0){
						clickSpecies = clickSpecies.elements().item(1);
						selAnimalGroup.setQualifiedAttribute('customAttributes._Species', clickSpecies);
						?'setting selAnimalGroup.customAttributes._Species =>'+clickSpecies+'\n';
					}

					selAnimalGroup.customAttributes.approved = {{actualNumberOfAnimals}};
					?'set number of approved for this animal =>{{actualNumberOfAnimals}}\n';	

					for(var i=0; i<speciesArray.length; i++){
						if(speciesArray[i]){
							if(speciesArray[i].species == "{{species.commonName}}"){
							    var name = speciesArray[i].name;
							    var name_1 = name.replace(/\s/g,"");
							    if(name_1.length>0){
									selAnimalGroup.customAttributes._ProtocolGroup = name;
									?'set protocolGroup name =>'+name+'\n';
								}
								else{
									selAnimalGroup.customAttributes._ProtocolGroup = species;
									?'set protocolGroup name =>'+species+'\n';
								}
							}
						}
					}


					animalGroup.setQualifiedAttribute('customAttributes._ProtocolGroup', selAnimalGroup);
					animalGroupSet.addElement(animalGroup);
				}
		    }
		{{/each}}

		var contactSet = iacucQ.contacts;
		{{#each studyTeamMembers}}
			{{#if studyTeamMember.userId}}

				var person = ApplicationEntity.getResultSet("Person").query("userID = '{{studyTeamMember.userId}}'");
				if(person.count() > 0){
					person = person.elements().item(1);
					contactSet.addElement(person);
					?'added person to contact set =>'+person+'\n';
				}

			{{/if}}
		{{/each}}

		{{#if investigator.studyTeamMember.userId}}
			var person = ApplicationEntity.getResultSet("Person").query("userID = '{{investigator.studyTeamMember.userId}}'").elements();
			
			if(person.count() > 0){
				person = person.item(1);
				contactSet.addElement(person);
				?'added person to contact set =>'+person+'\n';
			}
		{{/if}}

		var housingSet = iacucQ.customAttributes.SF_AnimalHousing;

		//_IS_AnimalHousing
		{{#each animalHousingLocationRoom}}
			 var room = ApplicationEntity.getResultSet('_Facility').query("name='{{facilityRoom.name}}'");
			 room = room.query("customAttributes._attribute2='Room'");
			 if(room.count() > 0){
			 	 room = room.elements().item(1);
				 var housing = _IS_AnimalHousing.createEntity();
				 housing.setQualifiedAttribute('customAttributes.facility', room);
				 ?'creating animal housing =>'+housing+'\n';

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
			 }
		{{/each}}

		{{#each vivariumHousingLocations}}
			 var room = ApplicationEntity.getResultSet('_Facility').query("name='{{facilityBuilding.name}}'");
			 room = room.query("customAttributes._attribute2='Building'");
			 if(room.count() > 0){
			 	 room = room.elements().item(1);
				 var housing = _IS_AnimalHousing.createEntity();
				 housing.setQualifiedAttribute('customAttributes.facility', room);
				 ?'creating animal housing =>'+housing+'\n';

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
			 }
		{{/each}}


}
else{
	iacucQ = iacucQ.elements().item(1);
	?'DLAR.iacucQ protocol found =>'+iacucQ.ID+'\n';
	//update fields below total animal #.
}
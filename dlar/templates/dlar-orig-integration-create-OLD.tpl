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
				1d. set irb status to Active and take get status if data migration
					set dateCreated/dateModified/date Approved(if avaliable);
			*/	
				{{#if topaz.status.id}}
					var status = iacucQ.status;
					if(status == null){
						var statusOID = entityUtils.getObjectFromString('{{topaz.status.id}}');
						iacucQ.status = statusOID;
						?'iacucQ.status =>'+iacucQ.status.ID+'\n';
					}
				{{else}}
					var status = iacucQ.status;
					if(status == null){
						//var statusOID = ApplicationEntity.getResultSet('ProjectStatus').query("ID='Pending Accounts'").elements().item(1);
						var statusOID = entityUtils.getObjectFromString('com.webridge.entity.Entity[OID[5ABEF2B631731F4C9C9E665C2D0AF3AD]]');
						iacucQ.status = statusOID;
						?'iacucQ.status =>'+iacucQ.status.ID+'\n';
					}
				{{/if}}

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
				1e. set resourceContainer.template
			*/
				var parentOID = "com.webridge.entity.Entity[OID[CBE99B3EEC5F2F4590DDF42629347777]]";
				theParent = EntityUtils.getObjectFromString(parentOID);
				var current_status = iacucQ.status.ID;
				var wsTemplate;

				if(current_status == 'Active'){
					wsTemplate = ContainerTemplate.getElements("ContainerTemplateForID", "ID", "TMPL00000047");
				}
				else if(current_status == 'Closed' || current_status == 'Suspended' || current_status == 'Expired'){
					wsTemplate = ContainerTemplate.getElements("ContainerTemplateForID", "ID", "TMPL8D1B0D98771CBCF");
				}
				else{
					wsTemplate = ContainerTemplate.getElements("ContainerTemplateForID", "ID", "TMPL00000046");
				}

				var resourceContainer = iacucQ.resourceContainer;
				if(resourceContainer == null){
					if(wsTemplate != null && theParent != null){
						wsTemplate = wsTemplate.item(1);
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
				/*
					{{#each animalGroups}}
						animalCount += {{numberOfAnimals}};
					{{/each}}
				*/

				{{#each animalCounts}}
					animalCount += {{actualNumberOfAnimals}};
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
				2b. create the following sets for dlar IACUC Study:
				SF_AnimalHousing => _IS_AnimalHousing
				SF_AnimalSource  => _IS_AnimalSource
				SF_AnimalGroup => _IS_AnimalGroup
				Contact eSet => IACUC Study.contacts
				_attribute32(species) eSet
				groups(_IS_SEL_AnimalGroup) eSet
				housingFacilities(_Facility) eSet
				husbandryExceptionSet(_HusbandryException) eset
				prodecureSet(_Procedure) eset
				substanceSet(_Substance) eset
			*/

				var animalHousing = _IS_AnimalHousing.createEntitySet();
				var animalSource = _IS_AnimalSource.createEntitySet();
				var animalGroup = _IS_AnimalGroup.createEntitySet();
				var contact = Person.createEntitySet();

				var species = ApplicationEntity.createEntitySet("_IACUC-Species");
				var group = _IS_SEL_AnimalGroup.createEntitySet();
				var housingFacilitiy = _Facility.createEntitySet();
				var husbExcepSet = _HusbandryException.createEntitySet();
				var procedureSet = _Procedure.createEntitySet();
				var substanceSet = _Substance.createEntitySet();

				iacucQ.setQualifiedAttribute('customAttributes.SF_AnimalHousing',animalHousing)
				?'create eset iacucQ.customAttributes.SF_AnimalHousing=>'+animalHousing+'\n';

				iacucQ.setQualifiedAttribute('customAttributes.SF_AnimalSource',animalSource)
				?'create eset iacucQ.customAttributes.SF_AnimalSource=>'+animalSource+'\n';

				iacucQ.setQualifiedAttribute('customAttributes.SF_AnimalGroup',animalGroup)
				?'create eset iacucQ.customAttributes.SF_AnimalGroup=>'+animalGroup+'\n';

				iacucQ.contacts = contact;
				?'create eset iacucQ.contacts =>'+iacucQ.contacts+'\n';

				iacucQ.setQualifiedAttribute('customAttributes._attribute32', species);
				?'create eset iacucQ.customAttributes._attribute32=>'+species+'\n';

				iacucQ.setQualifiedAttribute('customAttributes.groups', group);
				?'create eset iacucQ.customAttributes.groups=>'+group+'\n';

				iacucQ.setQualifiedAttribute('customAttributes.housingFacilities', housingFacilitiy);
				?'create eset iacucQ.customAttributes.housingFacilities=>'+housingFacilitiy+'\n';

				iacucQ.setQualifiedAttribute('customAttributes.husbandryExceptionSet', husbExcepSet);
				?'create eset iacucQ.customAttributes.husbandryExceptionSet=>'+husbExcepSet+'\n';

				iacucQ.setQualifiedAttribute('customAttributes.prodecureSet', procedureSet);
				?'create eset iacucQ.customAttributes.prodecureSet=>'+procedureSet+'\n';

				iacucQ.setQualifiedAttribute('customAttributes.substanceSet', substanceSet);
				?'create eset iacucQ.customAttributes.substanceSet => '+substanceSet+'\n';

				var speciesAdminSet = iacucQ.customAttributes._attribute32;
				var groupAdminSet = iacucQ.customAttributes.groups;
				var housingAdminSet = iacucQ.customAttributes.housingFacilities;

				var painCategoryB = 'Pain Category B';
				var painCategoryC = 'Pain Category C';
				var painCategoryD = 'Pain Category D';
				var painCategoryE = 'Pain Category E';
				/*
				var painCategoryB = ' Pain Category B ';
				var painCategoryC = ' Pain Category C ';
				var painCategoryD = ' Pain Category D ';
				var painCategoryE = ' Pain Category E ';
				*/
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
						/*
						var a = "{{speciesPainCat}}";
						var partsArray = a.split('-');
						var species = partsArray[0];
						species = species.replace(" ", "");
						var painCategory = partsArray[1];
						var painCategory_1;
						var usda = partsArray[2];
						usda = usda.replace(/^.+:/,'');
						usda = usda.replace(/\s/g,"");
						*/

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

						var clickSpecies = ApplicationEntity.getResultSet('_IACUC-Species').query("customAttributes._attribute0='"+species+"'");
						if(usda == "yes" || usda == "Yes" || usda == "1"){
							clickSpecies = clickSpecies.query("customAttributes.usdaCovered=true");
						}
						else{
							clickSpecies = clickSpecies.query("customAttributes.usdaCovered=false");
						}
						if(clickSpecies.count() > 0){
							if(painCategory_1 != null){

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

								/*
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
								*/

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
								?'painCategory is null\n';
							}
					}
					else{
						?'Cant find animal =>'+species+' usda =>'+usda+'\n';
					}
			    }
			{{/each}}

				var contactSet = iacucQ.contacts;

				var protocolTeamMembers = iacucQ.customAttributes.protocolTeamMembers;
				if(protocolTeamMembers == null){
					var studyTeamMemberInfo = _StudyTeamMemberINfo.createEntitySet();
					iacucQ.customAttributes.protocolTeamMembers = studyTeamMemberInfo;
					?'iacucQ.customAttributes.protocolTeamMembers =>'+studyTeamMemberInfo+'\n';
				}


				protocolTeamMembers = iacucQ.customAttributes.protocolTeamMembers;

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
				/*
					var dlarAuthorizedToOrderAnimals = true;
					var dlarInvolvedInAnimalHandling = true;
				*/

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

			var housingSet = iacucQ.customAttributes.SF_AnimalHousing;

			//_IS_AnimalHousing
			{{#each animalHousingLocationRoom}}
				var room = ApplicationEntity.getResultSet('_Facility').query("ID='{{facilityRoom.id}}'");
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
				 var room = ApplicationEntity.getResultSet('_Facility').query("ID='{{facilityBuilding.id}}'");
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

			//_IS_AnimalSource
			var animalSourceSet = iacucQ.customAttributes.SF_AnimalSource;

			if(animalSourceSet == null){
				iacucQ.setQualifiedAttribute('customAttributes.SF_AnimalSource',animalSource)
				?'create eset iacucQ.customAttributes.SF_AnimalSource=>'+animalSource+'\n';
			}
			
				//Sandy => 07/15/15 => Animal Source's do not need to be populated.
				var animalSource = _IS_AnimalSource.createEntity();
				var animalHousingGroupSet = _IS_SEL_AnimalGroup.createEntitySet();
				animalSource.setQualifiedAttribute("customAttributes._ProtocolGroup", animalHousingGroupSet);
				?'creating source.groupSet =>'+animalHousingGroupSet+'\n';

				var animalHousingGroupSet_2 = animalSource.customAttributes._ProtocolGroup;

				var animalGroup = iacucQ.customAttributes.SF_AnimalGroup;
				for(var i = 1; i<=animalGroup.count(); i++){
					var animalGroup_1 = animalGroup.elements().item(i);
					if(animalGroup_1){
						var protoGroup = animalGroup_1.customAttributes._ProtocolGroup;
						animalHousingGroupSet_2.addElement(protoGroup);
						?'adding animal to source.animalSet =>'+protoGroup+'\n';
					}
				}

				var source = ApplicationEntity.getResultSet('_IS_SEL_AnimalSource').query("ID='FromVendor'");
				if(source.count() > 0){
					source = source.elements().item(1);
					animalSource.customAttributes._AnimalSource = source;
					?'setting animal source => '+source+'\n';
				}

				animalSourceSet.addElement(animalSource);
				?'adding Animal Source to source set => '+animalSource+'\n';
			
			{{#if id}}
				/*
					2c. Set assignNumber(IACUC ID=>(example)PROTO201500001)
				*/		

				var a = iacucQ.customAttributes.assignNumber;
				if(a == null){
					iacucQ.customAttributes.assignNumber = '{{id}}';
					?'setting iacucQ.customAttriubtes.assignNumber => '+iacucQ.customAttributes.assignNumber+'\n';
				}
			{{/if}}

		 	/*
		 		2d. log create activity(_IACUC Study)
		 	*/
		 	var actTypeSet = getElements("ActivityTypeForID", "ID", "_IACUC Study_Created");
			if(actTypeSet.count() > 0){
			 	actTypeSet = actTypeSet(1);
			 	iacucQ.logActivity(sch, actTypeSet, Person.getCurrentUser());
			 	?'logging create activity => '+actTypeSet+'\n';
			}


			/*
				2e. common procedures/variable procedures/husbandryExceptions
			*/
			var husbandryEset = iacucQ.customAttributes.husbandryExceptionSet;
			var prodecureEset = iacucQ.customAttributes.prodecureSet;
			{{#each animalGroups}}
				var species = "{{species.commonName}}";
				var usda = "{{species.isUSDASpecies}}";

				var clickSpecies = ApplicationEntity.getResultSet('_IACUC-Species').query("customAttributes._attribute0='"+species+"'");
				if(usda == "yes" || usda == "Yes" || usda == "1"){
					clickSpecies = clickSpecies.query("customAttributes.usdaCovered=true");
				}
				else{
					clickSpecies = clickSpecies.query("customAttributes.usdaCovered=false");
				}
				if(clickSpecies.count() > 0){
					var species = clickSpecies.elements().item(1);
					{{#each husbandryExceptions}}
						{{#if name}}
							var husbExcepItem = _HusbandryException.createEntity();
							?'created husbExcepItem => '+husbExcepItem+'\n';
							var husbExcepName = "{{name}}";
							var justification = "{{justification}}";
							husbExcepItem.setQualifiedAttribute("customAttributes.name", husbExcepName);
							?'setting husbandryException name => '+husbExcepName+'\n';
							husbExcepItem.setQualifiedAttribute("customAttributes.justification", justification);
							?'setting husbandryException justification => '+justification+'\n';	
							husbExcepItem.setQualifiedAttribute("customAttributes.species", species);						
							?'set animal as species => '+species+'\n';
							husbandryEset.addElement(husbExcepItem);
							?'adding husbExcepItem to eset => '+husbandryEset+'\n';
						{{/if}}
					{{/each}}
				}
				else{
					?'species not found => '+species+' usda => '+usda+'\n';
				}

			{{/each}}

			{{#each procedurePersonnel}}
				{{#if procedure.name}}
					{{#if procedure.procedureScope.name}}
						{{#if procedure.procedureType.name}}
							var species = "{{procedure.species.commonName}}";
							var usda = "{{procedure.species.isUSDASpecies}}";

							var clickSpecies = ApplicationEntity.getResultSet('_IACUC-Species').query("customAttributes._attribute0='"+species+"'");
							if(usda == "yes" || usda == "Yes" || usda == "1"){
								clickSpecies = clickSpecies.query("customAttributes.usdaCovered=true");
							}
							else{
								clickSpecies = clickSpecies.query("customAttributes.usdaCovered=false");
							}
							if(clickSpecies.count() > 0){
								var procItem = _Procedure.createEntity();
								?'created procedure => '+procItem+'\n';
								var species = clickSpecies.elements().item(1);
								var speciesName = "{{procedure.name}}";
								var procedureScopeName = "{{procedure.procedureScope.name}}";
								var procedureTypeName = "{{procedure.procedureType.name}}";
								var procedureName = procedureTypeName+": "+speciesName+" ("+procedureScopeName+")";
								procItem.setQualifiedAttribute("customAttributes.name", procedureName);
								?'setting procedure name => '+procedureName+'\n';
								procItem.setQualifiedAttribute("customAttributes.species", species);
								?'setting species => '+species+'\n';
								
								var labLocationEset = _Facility.createEntitySet();
								?'created labLocationEset => '+labLocationEset+'\n';
								procItem.setQualifiedAttribute("customAttributes.labLocation", labLocationEset);
								labLocationEset = procItem.customAttributes.labLocation;
								?'setting labLocation => '+labLocationEset+'\n';

								{{#each locations}}
									var labLocationExist = ApplicationEntity.getResultSet('_Facility').query("ID='{{id}}'");
									if(labLocationExist.count() > 0){
										var labLocationExist_1 = labLocationExist.elements().item(1);
										?'location found => '+labLocationExist_1+'\n';
										labLocationEset.addElement(labLocationExist_1);
										?'adding labLocation to eset => '+labLocationEset+'\n';
									}
									else{
										?'location not found => {{name}}\n';
									}
								{{/each}}

								prodecureEset.addElement(procItem);
								?'added procedure to eset => '+prodecureEset+'\n';
							}
							else{
								?'species not found => '+species+' usda => '+usda+'\n';
							}
						{{/if}}
					{{/if}}
				{{/if}}
			{{/each}}
			
			/*
				2f. list of substances(unique list per species)
					- administrationOfSubstances(eset) -> substances -> iacucsubstancecustomextension -> tradeName
					- inhalationExposure -> substancetobeadministered | -> otheranesthesia | -> anesthesiausage(eset) -> drugname
					- intranasalInstallation -> agent -> drugname | -> otheragent | -> substanceadministeredviaintranasal(eset) -> iacucsubstancecustomextension -> tradename
					- survivalSurgery -> setofsubstances(eset) -> iacucsubstancecustomextension -> tradename | anesthesiatechniques(eset) -> drugname
					- irradiation -> antibiotics -> iacucsubstancecustomextension -> tradename
					- imagingAndRadiation -> setofsubstances(eset) -> iacucsubstancecustomextension -> tradename | imaginganesthesiatechnique(eset) -> drugname
					- imagingWithoutRadiation -> setofsubstances(eset) -> iacucsubstancecustomextension -> tradename | -> anesthesiatechniques(eset) -> drugname
					- implantation -> setofsubstances(eset) -> iacucsubstancecustomextension -> tradename | -> otheranesthesia | -> othersubstance | anesthesiaused(eset) -> drugname
					- exposure -> setofsubstance(eset) -> iacucsubstancecustomextension -> tradename
					- euthansiaProcedures -> methodset(eset) -> drugname
					- individualIdentificationTag -> anesthesiatechniques -> drugname
					- genotypingBloodCollection -> anesthesiatechniques(eset) -> drugname
					- genotypingTailTip -> anesthesiatechniques(eset) -> drugname
					- exogenousSubstanceHazerdousMaterial -> hazardousagentset(eset) -> iacucsubstancecustomextension -> tradename
					- exogenousSubstancesAnimalPathogens -> pathogenname
					- bloodCollection -> anesthesiatechniques -> drugname

					*********** function findSubtance - if not found create otherwise return the substance *****************
			*/

			function findSubstance(substanceToFindName){
				var substanceEsetByName = ApplicationEntity.getResultSet("_Substance").query("customAttributes.name='"+substanceToFindName+"'");
				if(substanceEsetByName.count() > 0){
				  substanceEsetByName = substanceEsetByName.elements().item(1);
				  ?'substance found => '+substanceEsetByName.customAttributes.name+'\n';
				}
				else{
				   var createSub = _Substance.createEntity();
				   createSub.setQualifiedAttribute("customAttributes.name", substanceToFindName);
				   substanceEsetByName = createSub;
				   ?'created substance => '+substanceEsetByName.customAttributes.name+'\n';
				}
				return substanceEsetByName;
			}

			var iacucSubstanceSet = iacucQ.customAttributes.substanceSet;

			{{#each procedurePersonnel}}
				{{#if procedure}}		 			
					var clickSpecies = ApplicationEntity.getResultSet('_IACUC-Species').query("customAttributes._attribute0='"+species+"'");		
					if(usda == "yes" || usda == "Yes" || usda == "1"){		
						clickSpecies = clickSpecies.query("customAttributes.usdaCovered=true");		
					}		
					else{		
						clickSpecies = clickSpecies.query("customAttributes.usdaCovered=false");		
					}		
					if(clickSpecies.count() > 0){	
						clickSpecies = clickSpecies.elements().item(1);

						{{#each procedure.administrationOfSubstances}}
							{{#if substances.iACUCSubstanceCustomExtension.tradeName}}
								var drugName = "{{substances.iACUCSubstanceCustomExtension.tradeName}}";
								?'administrationOfSubstsance drug name => '+drugName+'\n';
								var item = findSubstance(drugName);
								iacucSubstanceSet.addElement(item);
								?'adding substance to eset => '+iacucSubstanceSet+'\n';
							{{/if}}
						{{/each}}

						{{#if procedure.inhalationExposure}}
							{{#if procedure.inhalationExposure.substanceToBeAdministered.id}}
								var inhalationSubstanceToBeAdmin = "{{procedure.inhalationExposure.substanceToBeAdministered.id}}";
								?'inhalationSubstanceToBeAdmin drug name => '+inhalationSubstanceToBeAdmin+'\n';
								var item = findSubstance(inhalationSubstanceToBeAdmin);
								iacucSubstanceSet.addElement(item);
								?'adding substance to eset => '+iacucSubstanceSet+'\n';
							{{/if}}

							{{#if procedure.inhalationExposure.otherAnesthesia}}
								var inhalationOtherAnesthesia = "{{procedure.inhalationExposure.otherAnesthesia}}";
								?'inhalationOtherAnesthesia drug name => '+inhalationOtherAnesthesia+'\n';
								var item = findSubstance(inhalationOtherAnesthesia);
								iacucSubstanceSet.addElement(item);
								?'adding substance to eset => '+iacucSubstanceSet+'\n';
							{{/if}}

							{{#each procedure.inhalationExposure.anesthesiaUsage}}
								{{#if drugName}}
									var inhalationDrugName = "{{drugName}}";
									?'inhalationDrugName drug name => '+inhalationDrugName+'\n';
									var item = findSubstance(inhalationDrugName);
									iacucSubstanceSet.addElement(item);
									?'adding substance to eset => '+iacucSubstanceSet+'\n';																	
								{{/if}}
							{{/each}}
						{{/if}}

						{{#if procedure.intranasalInstallation}}
							{{#if procedure.intranasalInstallation.agent.drugName}}
								var intranasalDrugName = "{{procedure.intranasalInstallation.agent.drugName}}";
								?'intranasalDrugName drug name => '+intranasalDrugName+'\n';
								var item = findSubstance(intranasalDrugName);
								iacucSubstanceSet.addElement(item);
								?'adding substance to eset => '+iacucSubstanceSet+'\n';
							{{/if}}

							{{#if procedure.intranasalInstallation.otherAgent}}
								var intranasalOtherAgent = "{{procedure.intranasalInstallation.otherAgent}}";
								?'intranasalOtherAgent drug name => '+intranasalOtherAgent+'\n';
								var item = findSubstance(intranasalOtherAgent);
								iacucSubstanceSet.addElement(item);
								?'adding substance to eset => '+iacucSubstanceSet+'\n';
							{{/if}}

							{{#each procedure.intranasalInstallation.substancesAdministeredViaIntranasal}}
								{{#if iACUCSubstanceCustomExtension.tradeName}}
									var intranasalSubstanceAdmin = "{{iACUCSubstanceCustomExtension.tradeName}}";
									?'intranasalSubstanceAdmin drug name => '+intranasalSubstanceAdmin+'\n';
									var item = findSubstance(intranasalSubstanceAdmin);
									iacucSubstanceSet.addElement(item);
									?'adding substance to eset => '+iacucSubstanceSet+'\n';
								{{/if}}
							{{/each}}
						{{/if}}

						{{#if procedure.survivalSurgery}}
							{{#each procedure.survivalSurgery.setOfSubstances}}
								{{#if iACUCSubstanceCustomExtension.tradeName}}
									var survivalSubstances = "{{iACUCSubstanceCustomExtension.tradeName}}";
									?'survivalSubstances drug name => '+survivalSubstances+'\n';
									var item = findSubstance(survivalSubstances);
									iacucSubstanceSet.addElement(item);
									?'adding substance to eset => '+iacucSubstanceSet+'\n';
								{{/if}}								
							{{/each}}

							{{#if procedure.survivalSurgery.anesthesiaTechniques.drugName}}
								var survivalDrugName = "{{procedure.survivalSurgery.anesthesiaTechniques.drugName}}";
								?'survivalDrugName drug name => '+survivalDrugName+'\n';
								var item = findSubstance(survivalDrugName);
								iacucSubstanceSet.addElement(item);
								?'adding substance to eset => '+iacucSubstanceSet+'\n';
							{{/if}}
						{{/if}}

						{{#if procedure.irradiation.antibiotics.iACUCSubstanceCustomExtension.tradeName}}
							var irradiationDrugName = "{{procedure.irradiation.antibiotics.iACUCSubstanceCustomExtension.tradeName}}";
							?'irradiationDrugName drugName => '+irradiationDrugName+'\n';
							var item = findSubstance(irradiationDrugName);
							iacucSubstanceSet.addElement(item);
							?'adding substance to eset => '+iacucSubstanceSet+'\n';
						{{/if}}

						{{#if procedure.imagingAndRadiation}}
							{{#each procedure.imagingAndRadiation.setOfSubstances}}
								{{#if iACUCSubstanceCustomExtension.tradeName}}
									var imagingRadDrugName = "{{iACUCSubstanceCustomExtension.tradeName}}";
									?'imagingRadDrugName drug name => '+imagingRadDrugName+'\n';
									var item = findSubstance(imagingRadDrugName);
									iacucSubstanceSet.addElement(item);
									?'adding substance to eset => '+iacucSubstanceSet+'\n';
								{{/if}}		
							{{/each}}

							{{#each procedure.imagingAndRadiation.imagingAnesthesiaTechnique}}
								var imagingRadDrugName = "{{drugName}}";
								?'imagingRadDrugName drug name => '+imagingRadDrugName+'\n';
								var item = findSubstance(imagingRadDrugName);
								iacucSubstanceSet.addElement(item);
								?'adding substance to eset => '+iacucSubstanceSet+'\n';
							{{/each}}
						{{/if}}

						{{#if procedure.imagingWithoutRadiation}}
							{{#each procedure.imagingWithoutRadiation.setOfSubstances}}
								{{#if iACUCSubstanceCustomExtension.tradeName}}
									var imagingRadWoDrugName = "{{iACUCSubstanceCustomExtension.tradeName}}";
									?'imagingRadWoDrugName drug name => '+imagingRadWoDrugName+'\n';
									var item = findSubstance(imagingRadWoDrugName);
									iacucSubstanceSet.addElement(item);
									?'adding substance to eset => '+iacucSubstanceSet+'\n';
								{{/if}}		
							{{/each}}

							{{#each procedure.imagingWithoutRadiation.anesthesiaTechniques}}
								var imagingRadWoDrugName = "{{drugName}}";
								?'imagingRadWoDrugName drug name => '+imagingRadWoDrugName+'\n';
								var item = findSubstance(imagingRadWoDrugName);
								iacucSubstanceSet.addElement(item);
								?'adding substance to eset => '+iacucSubstanceSet+'\n';
							{{/each}}
						{{/if}}

						{{#if procedure.implantation}}
							{{#each procedure.implantation.setOfSubstances}}
								{{#if iACUCSubstanceCustomExtension.tradeName}}
									var implantationDrugName = "{{iACUCSubstanceCustomExtension.tradeName}}";
									?'implantationDrugName drug name => '+implantationDrugName+'\n';
									var item = findSubstance(implantationDrugName);
									iacucSubstanceSet.addElement(item);
									?'adding substance to eset => '+iacucSubstanceSet+'\n';
								{{/if}}
							{{/each}}

							{{#if procedure.implantation.otherAnesthesia}}
								var implantOtherAnesth = "{{procedure.implantation.otherAnesthesia}}";
								?'implantOtherAnesth drug name => '+implantOtherAnesth+'\n';
								var item = findSubstance(implantOtherAnesth);
								iacucSubstanceSet.addElement(item);
								?'adding substance to eset => '+iacucSubstanceSet+'\n';
							{{/if}}

							{{#if procedure.implantation.otherSubstance}}
								var implantOtherSub = "{{procedure.implantation.otherSubstance}}";
								?'implantOtherSub drug name => '+implantOtherSub+'\n';
								var item = findSubstance(implantOtherSub);
								iacucSubstanceSet.addElement(item);
								?'adding substance to eset => '+iacucSubstanceSet+'\n';
							{{/if}}

							{{#if procedure.implantation.anesthesiaUsed.drugName}}
								var implantAnesthDrugName = "{{procedure.implantation.anesthesiaUsed.drugName}}";
								?'implantAnesthDrugName drug name => '+implantAnesthDrugName+'\n';
								var item = findSubstance(implantAnesthDrugName);
								iacucSubstanceSet.addElement(item);
								?'adding substance to eset => '+iacucSubstanceSet+'\n';
							{{/if}}
						{{/if}}

						{{#if procedure.exposure}}
							{{#each procedure.exposure.setOfSubstances}}
								var exposeSubstance = "{{iACUCSubstanceCustomExtension.tradeName}}";
								?'exposeSubstance drug name => '+exposeSubstance+'\n';
								var item = findSubstance(exposeSubstance);
								iacucSubstanceSet.addElement(item);
								?'adding substance to eset => '+iacucSubstanceSet+'\n';								
							{{/each}}
						{{/if}}

						{{#if procedure.euthanasiaProcedures}}
							{{#each procedure.euthanasiaProcedures.methodSet}}
								var euthMethodSet = "{{drugName}}";
								?'euthMethodSet drug name => '+euthMethodSet+'\n';
								var item = findSubstance(euthMethodSet);
								iacucSubstanceSet.addElement(item);
								?'adding substance to eset => '+iacucSubstanceSet+'\n';	
							{{/each}}
						{{/if}}

						{{#if procedure.individualIdentificationTag.anesthesiaTechniques.drugName}}
							var individualTagDrugName = "{{procedure.individualIdentificationTag.anesthesiaTechniques.drugName}}";
							?'individualTagDrugName drug name => '+individualTagDrugName+'\n';
							var item = findSubstance(individualTagDrugName);
							iacucSubstanceSet.addElement(item);
							?'adding substance to eset => '+iacucSubstanceSet+'\n';	
						{{/if}}

						{{#if procedure.genotypingBloodCollection}}
							{{#each procedure.genotypingBloodCollection.anesthesiaTechniques}}
								var genoBloodCollectionDrugName = "{{drugName}}";
								?'genoBloodCollectionDrugName drug name => '+genoBloodCollectionDrugName+'\n';
								var item = findSubstance(genoBloodCollectionDrugName);
								iacucSubstanceSet.addElement(item);
								?'adding substance to eset => '+iacucSubstanceSet+'\n';	
							{{/each}}
						{{/if}}

						{{#if procedure.genotypingTailTip}}
							{{#each procedure.genotypingTailTip.anesthesiaTechniques}}
								var genoTypingTailDrugName = "{{drugName}}";
								?'genoTypingTailDrugName drug name => '+genoTypingTailDrugName+'\n';
								var item = findSubstance(genoTypingTailDrugName);
								iacucSubstanceSet.addElement(item);
								?'adding substance to eset => '+iacucSubstanceSet+'\n';	
							{{/each}}							
						{{/if}}

						{{#if procedure.exogenousSubstancesHazardousMaterials}}
							{{#each procedure.exogenousSubstancesHazardousMaterials.hazardousAgentSet}}
								{{#if iACUCSubstanceCustomExtension.tradeName}}
									var exogenousSubstanceDrugName = "{{iACUCSubstanceCustomExtension.tradeName}}";
									?'exogenousSubstanceDrugName drug name => '+exogenousSubstanceDrugName+'\n';
									var item = findSubstance(exogenousSubstanceDrugName);
									iacucSubstanceSet.addElement(item);
									?'adding substance to eset => '+iacucSubstanceSet+'\n';	
								{{/if}}
							{{/each}}
						{{/if}}

						{{#if procedure.exogenousSubstancesAnimalPathogens.pathogenName}}
							var exogenousSubDrugName = "{{procedure.exogenousSubstancesAnimalPathogens.pathogenName}}";
							?'exogenousSubDrugName drug name => '+exogenousSubDrugName+'\n';
							var item = findSubstance(exogenousSubDrugName);
							iacucSubstanceSet.addElement(item);
							?'adding substance to eset => '+iacucSubstanceSet+'\n';
						{{/if}}

						{{#if procedure.bloodCollection.anesthesiaTechniques.drugName}}
							var bloodCollectionDrugName = "{{procedure.bloodCollection.anesthesiaTechniques.drugName}}";
							?'bloodCollectionDrugName drug name => '+bloodCollectionDrugName+'\n';
							var item = findSubstance(bloodCollectionDrugName);
							iacucSubstanceSet.addElement(item);
							?'adding substance to eset => '+iacucSubstanceSet+'\n';
						{{/if}}
					}		
					else{		
						?'species not found => '+species+' usda => '+usda+'\n';		
					}
				{{/if}}	
 			{{/each}}

			/*
				2g. recalculate totals
			*/
			var count = iacucQ.customAttributes._attribute71;
			var animalFind = iacucQ.customAttributes.SF_AnimalGroup;
			if(count > 0){
				if(animalFind.count() > 0){
					iacucQ.calculateTotals();
					?'recalculating total animal counts\n';
				}
			}

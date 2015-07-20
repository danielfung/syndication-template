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
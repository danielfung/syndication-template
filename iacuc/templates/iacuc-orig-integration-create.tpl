iacucQ = wom.createTransientEntity('_ClickIACUCSubmission');
		?'iacucQ =>'+iacucQ+'\n';

		/*
			1a. update ID of iacuc Submission
		*/

			iacucQ.ID = iacuc_id;
			?'iacucQ.ID =>'+iacucQ.ID+'\n';

		/*
			1b. Register/initalize iacuc Submission, add Project/contact eset
		*/
			iacucQ.registerEntity();
			//iacucQ.initalize();
			//initalize
			var iacucQ = ApplicationEntity.getResultSet('_ClickIACUCSubmission').query("ID='"+iacuc_id+"'").elements().item(1);

			if(iacucQ.customAttributes == null){
				var c = _ClickIACUCSubmission_CustomAttributesManager.createEntity();
				iacucQ.customAttributes = c;
				?'created iacucQ.customAttributes =>'+c+'\n';
			}


			var projectSet = iacucQ.projects;
			if(projectSet == null){
				var projectSet = Project.createEntitySet();
				iacucQ.projects = projectSet;
				?'Created Project Set => '+iacucQ.projects+'\n';
			}

			var contacts = iacucQ.contacts;
			if(contacts == null){
				iacucQ.contacts = Person.createEntitySet();
				?'created contacts set =>'+iacucQ.contacts+'\n';
			}

			var contactsSet = iacucQ.contacts;

		/*
			1c. set required fields (owner, company, createdby, pi)
			if company not found --> default to MCIT
			if createdBy not found --> default to Sys Admin
			if PI not found --> leave empty
		*/

			{{#if studyDetails.principalInvestigator}}
				//studyDetails.pi
				var investigator = iacucQ.getQualifiedAttribute("customAttributes.investigator");

				var person = ApplicationEntity.getResultSet("Person").query("userID = '{{studyDetails.principalInvestigator.userId}}'").elements();
				if(investigator == null && person.count() > 0){
					var studyTeamMember = _StudyTeamMemberInfo.createEntity();
					?'_StudyTeamMemberInfo =>'+studyTeamMember+'\n';
					iacucQ.setQualifiedAttribute("customAttributes.investigator", studyTeamMember);
					person = person.item(1);
					?'person adding as PI =>'+person+'\n';
					contactsSet.addElement(person);
					?'adding person to contacts list\n';
					studyTeamMember.setQualifiedAttribute("customAttributes.studyTeamMember", person);
					var department = person.customAttributes;
					var division;
					if(department != null){
						department = person.customAttributes.department;
						division = person.customAttributes.division;
						if(department != null){
							if(department.name == "Medicine" || department.name == "Population Health"){
								if(division != null){
									iacucQ.company = division;
									?'Department is Medicine/Population Health => Check Division\n';
									?'iacucQ.company =>'+division+'\n';
								}
								else{
									iacucQ.company = department;
									?'iacucQ.company =>'+department+'\n';
								}
							}
							else{
								iacucQ.company = department;
								?'iacucQ.company =>'+department+'\n';
							}
						}
					}

					var piEmail = person.contactInformation;
					if(piEmail){
						piEmail = piEmail.emailPreferred;
						if(piEmail){
							piEmail = piEmail.eMailAddress;
						}
					}

					var piNumber = person.contactInformation;
					if(piNumber){
						piNumber = piNumber.phoneBusiness;
						if(piNumber){
							piNumber = piNumber.phoneNumber;
						}
					}

					var piCustomExtension = _PIExtensionInfromation.createEntity();
					?'created piCustomExtension => '+piCustomExtension+'\n';
					if(department){
						piCustomExtension.setQualifiedAttribute("customAttributes.department", department);
						?'setting piCustomExtension department => '+department+'\n';
					}
					if(division){
						piCustomExtension.setQualifiedAttribute("customAttributes.division", division);
						?'setting piCustomExtension division => '+division+'\n';
					}
					if(piEmail){
						piCustomExtension.setQualifiedAttribute("customAttributes.emailAddress", piEmail);
						?'setting piCustomExtension emailAddress => '+piEmail+'\n';
					}
					if(piNumber){
						piCustomExtension.setQualifiedAttribute("customAttributes.phoneNumber", piNumber);
						?'setting piCustomExtension phoneNumber => '+piNumber+'\n';						
					}
					studyTeamMember.setQualifiedAttribute("customAttributes.pIInformation", piCustomExtension);
					?'setting studyTeamMember.customAttributes.piInfo => '+piCustomExtension+'\n';
				}
			{{/if}}

			var company = iacucQ.company;
			{{#if company}}
				if(company == null){
					var a = ApplicationEntity.getResultSet("Company").query("ID = '{{company.id}}'");
					if(a.count()>0){
						iacucQ.company = a.elements().item(1);
						?'iacucQ.company =>'+iacucQ.company+'\n';
					}
					else{
						?'Company Not Found =>{{company.id}}\n';
						var company = ApplicationEntity.getResultSet("Company").query("NAME = 'MCIT'").elements().item(1);
						iacucQ.company = company;
						?'defaulting iacucQ.company => MCIT: '+company+'\n';
					}
				}
			{{else}}
				if(company == null){
					var company = ApplicationEntity.getResultSet("Company").query("NAME = 'MCIT'").elements().item(1);
					iacucQ.company = company;
					?'defaulting iacucQ.company => MCIT: '+company+'\n';
				}
			{{/if}}

			{{#if createdBy}}
				//createdby => RN.createdBy
				var person = ApplicationEntity.getResultSet("Person").query("userID = '{{createdBy.userId}}'");
				if(person.count() > 0){
					person = person.elements().item(1);
					iacucQ.createdBy = person;
					?'iacucQ.createdBy =>'+iacucQ.createdBy+'\n';
				}
				else{
					?'Person Not Found =>{{createdBy.userId}}\n';
					?'Person Not Found =>topaz.principalInvestigator\n';
					var person = ApplicationEntity.getResultSet("Person").query("userID = 'administrator'").elements().item(1);
					iacucQ.createdBy = person;
					?'defaulting iacucQ.createdBy => administrator: '+iacucQ.createdBy+'\n';
				}
			{{/if}}

		/*
			1d. set submissionType, typeofProtocol --> required fields
		*/	
	        {{#if studyDetails}}
				var submissionType = ApplicationEntity.getResultSet("_SubmissionType").query("ID = 'PROTOYYYY'");
		    	if(submissionType.count() == 1) {
		            submissionType = submissionType.elements().item(1);
		            iacucQ.setQualifiedAttribute("customAttributes.typeOfSubmission", submissionType);
		            ?'default to iacucQ.customAttributes.typeOfSubmission =>'+submissionType+'\n';
		        }
		        else {
		            ?"IACUC New Protocol Application submission type not found, please contact an administrator\n";
		        }
	        {{/if}}

	        {{#if studyDetails}}
	        	var protocolType = ApplicationEntity.getResultSet("_ClickProtocolType").query("customAttributes.name='Experimental Research'").elements().item(1);
	        	iacucQ.setQualifiedAttribute("customAttributes.typeOfProtocol", protocolType);
	        	?'defaulting ProtocolType =>Experimental Research1\n';
	        {{/if}}

	    /*
	    	1e. set IACUC Settings
	    */
	    	var iacucSettings = _ClickIACUCSettings.getIACUCSettings();
	        iacucQ.setQualifiedAttribute("customAttributes.iacucSettings", iacucSettings);
	        ?'iacucQ.customAttributes.iacucSettings =>'+iacucQ.customAttributes.iacucSettings+'\n';

	    /*
	    	1f. set IACUC parent to self
	    */
	    	var parentStudy = iacucQ.getQualifiedAttribute("customAttributes.parentProtocol");
			if(parentStudy == null){
				iacucQ.setQualifiedAttribute("customAttributes.parentProtocol", iacucQ);
			}
			?'parentProtocol =>'+iacucQ.customAttributes.parentProtocol+'\n';

		/*
			1g. set iacuc status to pre-submission
				set dateCreated/dateModified;
		*/
				var status = iacucQ.status;
				if(status == null){
					var statusOID = entityUtils.getObjectFromString('com.webridge.entity.Entity[OID[9F73BE7925820443ABD79B34AD90AA55]]');
					iacucQ.status = statusOID;
					?'iacucQ.status =>'+iacucQ.status+'\n';
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
		
		/*
			1h. set resourceContainer.template
		*/
			var submissionTypeName = iacucQ.customAttributes.typeOfSubmission.customAttributes.name;
			var status = iacucQ.status.ID;
			var whichTemplate;

			if(submissionTypeName != null){
				if(submissionTypeName == "New Protocol Application"){
					if(status == "Approved"){
						whichTemplate = "TMPL8D07C62360C5A80";
						?'template New Proto=>'+whichTemplate+'\n';
					}
					else if(status == "Lapsed" || status == "Closed"){
						whichTemplate = "TMPL8D284738B366772";
						?'template New Proto=>'+whichTemplate+'\n';						
					}
					else{
						whichTemplate = "TMPL8D02B5766D47C23";
						?'template New Proto=>'+whichTemplate+'\n';
					}
				}

				else if(submissionTypeName == "Triennial Review"){
					if(status == "Approved"){
						whichTemplate = "TMPL8D089BC317FF635";
						?'template TR=>'+whichTemplate+'\n';
					}
					else{
						whichTemplate = "TMPL8D089BC317FF632";
						?'template TR=>'+whichTemplate+'\n';
					}
				}

				else if(submissionTypeName == "Annual Review"){
					if(status == "Approved"){
						whichTemplate = "TMPL8D0B9AB62B6DF48";
						?'template AR=>'+whichTemplate+'\n';
					}
					else{
						whichTemplate = "TMPL8D07C62360C5AC7";
						?'template AR=>'+whichTemplate+'\n';
					}
				}

				else if(submissionTypeName == "Amendment"){
					if(status == "Approved"){
						whichTemplate = "TMPL8D0C8D3FA92169A";
						?'template amendment=>'+whichTemplate+'\n';
					}
					else{
						whichTemplate = "TMPL8D0B9AB62B6DDD2";
						?'template amendment=>'+whichTemplate+'\n';
					}
				}
				else{
					whichTemplate = "TMPL8D02B5766D47C23";
					?'default template to new protocol=>'+whichTemplate+'\n';
				}
			}
			else{
				whichTemplate = "TMPL8D02B5766D47C23";
				?'default template to new protocol=>'+whichTemplate+'\n';
			}

			var template =	ContainerTemplate.getElements("ContainerTemplateForID", "ID", whichTemplate);
			var container = Container.getElements("ContainerForID", "ID", "CLICK_IACUC_SUBMISSIONS").item(1);

			var resourceContainer = iacucQ.resourceContainer;
			if(resourceContainer == null){
				if(template.count == 1 && container != null){
					template = template.item(1);
					iacucQ.createWorkspace(container, template);
					?'iacucQ.resourceContainer =>'+iacucQ.resourceContainer+'\n';
					?'iacucQ.resourceContainer.template =>'+iacucQ.resourceContainer.template+'\n';
				}
				else{
					?'Template not found\n';
				}
			}

		/*
			1i. set name, shortDescription, longTitle
		*/
			iacucQ.name = "{{breaklines name}}";
			?'setting iacucQ name =>'+iacucQ.name+'\n';
			{{#if studyDetails.longTitle}}
				iacucQ.customAttributes.fullTitle = "{{studyDetails.longTitle}}";
				?'setting iacucQ.customAttributes.fullTitle =>'+iacucQ.customAttributes.fullTitle+'\n';
				iacucQ.customAttributes.fullTitle_text = "{{studyDetails.longTitle}}";
				?'setting iacucQ.customAttributes.fullTitle_text=>'+iacucQ.customAttributes.fullTitle_text+'\n';
			{{else}}
				iacucQ.customAttributes.fullTitle = "{{breaklines name}}";
				?'default setting to name: iacucQ.customAttributes.fullTitle =>'+iacucQ.customAttributes.fullTitle+'\n';
				iacucQ.customAttributes.fullTitle_text = "{{breaklines name}}";
				?'default setting to name: iacucQ.customAttributes.fullTitle_text=>'+iacucQ.customAttributes.fullTitle_text+'\n';
			{{/if}}

		/*
			2a. set admin office --> com.webridge.entity.Entity[OID[455A658DB0BA7D498CB6DF34E2CA25EA]];
		*/
			var adminOffice = entityUtils.getObjectFromString('com.webridge.entity.Entity[OID[455A658DB0BA7D498CB6DF34E2CA25EA]]');
			iacucQ.setQualifiedAttribute('customAttributes.adminOffice', adminOffice);
			?'setting adminOffice added=>'+adminOffice+'\n';

		/*
			2b. create guest list 
		*/
			var person = Person.createEntitySet();
			iacucQ.setQualifiedAttribute("customAttributes.guestList", person );
			?'guestList set created=>'+iacucQ.customAttributes.guestList+'\n';

		/*
			2c. create readers
		*/
			var person = Person.createEntitySet();
			iacucQ.setQualifiedAttribute("customAttributes.readers", person );
			?'readers set created=> '+iacucQ.customAttributes.readers+'\n';

			var readers = iacucQ.customAttributes.readers;

		/*
			2d. create editors
		*/
			var person = Person.createEntitySet();
			iacucQ.setQualifiedAttribute("customAttributes.editors", person);
			?'editors set created => '+iacucQ.customAttributes.editors+'\n';

			var editors = iacucQ.customAttributes.editors;

		/*
			2e. add people readers/editors
			example: PI
		*/
		{{#if studyDetails.principalInvestigator}}
				var person = ApplicationEntity.getResultSet("Person").query("userID = '{{studyDetails.principalInvestigator.userId}}'").elements();
				if(person.count() > 0){
					person = person.item(1);
					readers.addElement(person);
					?'added PI to readers set => '+readers+'\n';
					editors.addElement(person);
					?'added PI to editors set => '+editors+'\n';
				}
				else{
					?'Cant Find PI => {{studyDetails.principalInvestigator.userId}} not found \n';
				}
		{{/if}}

		/*
			2f. add study team members to list and editors/readers
			--> Loredana => Study Department Administrator should not come over to iacuc.
		*/
			var contactsSet = iacucQ.contacts;
			var studyTeamMember = iacucQ.customAttributes.studyTeamMembers;
			if(studyTeamMember == null){
				var a = ApplicationEntity.createEntitySet('_StudyTeamMemberInfo');
				iacucQ.customAttributes.studyTeamMembers = a;
				?'setting studyTeamMembers eset => '+iacucQ.customAttributes.studyTeamMembers+'\n';
			}
			studyTeamMember = iacucQ.customAttributes.studyTeamMembers;
			var canEdit;
		/*
		{{#if studyDetails.studyDepartmentalAdmin.userId}}
			var exists = iacucQ.customAttributes.studyTeamMembers.query("customAttributes.studyTeamMember.userId='{{studyDetails.studyDepartmentalAdmin.userId}}'");
			var person = ApplicationEntity.getResultSet("Person").query("userID = '{{studyDetails.studyDepartmentalAdmin.userId}}'").elements();
			canEdit = true;
			if(exists.count() == 0 && person.count() > 0){
					person = person.item(1);
					readers.addElement(person);
					?'added department admin to readers set => '+readers+'\n';
					editors.addElement(person);
					?'added department admin to editors set => '+editors+'\n';
					contactsSet.addElement(person);
					?'added department admin to contacts set => '+contactsSet+'\n';
					var studyTeamMemInfo = _StudyTeamMemberInfo.createEntity();
					?'created studyTeamMemInfo => '+studyTeamMemInfo+'\n';
					studyTeamMemInfo.setQualifiedAttribute("customAttributes.studyTeamMember", person);
					?'adding person to studyTeamMemInfo => '+person+'\n';
					studyTeamMemInfo.customAttributes.canEditProtocol = canEdit;
					?'Can Edit Protocol => True\n';
					studyTeamMember.addElement(studyTeamMemInfo);
					?'added department admin to study team mem info set => '+studyTeamMember+'\n';
			}
		{{/if}}
		*/

		{{#each studyDetails.teamSubInvestigators}}
			var exists = iacucQ.customAttributes.studyTeamMembers.query("customAttributes.studyTeamMember.userId='{{userId}}'");
			var person = ApplicationEntity.getResultSet("Person").query("userID = '{{userId}}'").elements();
			canEdit = true;
			if(exists.count() == 0 && person.count() > 0){
					person = person.item(1);
					readers.addElement(person);
					?'added teamSubInvestigators to readers set => '+readers+'\n';
					editors.addElement(person);
					?'added teamSubInvestigators to editors set => '+editors+'\n';
					contactsSet.addElement(person);
					?'added teamSubInvestigators to contacts set => '+contactsSet+'\n';
					var studyTeamMemInfo = _StudyTeamMemberInfo.createEntity();
					?'created studyTeamMemInfo => '+studyTeamMemInfo+'\n';
					studyTeamMemInfo.setQualifiedAttribute("customAttributes.studyTeamMember", person);
					?'adding person to studyTeamMemInfo => '+person+'\n';
					studyTeamMemInfo.customAttributes.canEditProtocol = canEdit;
					?'Can Edit Protocol => True\n';
					studyTeamMember.addElement(studyTeamMemInfo);
					?'added teamSubInvestigators to study team mem info set => '+studyTeamMember+'\n';
			}
		{{/each}}

		{{#each studyDetails.researchCoordinators}}
			var exists = iacucQ.customAttributes.studyTeamMembers.query("customAttributes.studyTeamMember.userId='{{coordinator.userId}}'");
			var person = ApplicationEntity.getResultSet("Person").query("userID = '{{coordinator.userId}}'").elements();
			canEdit = true;
			if(exists.count() == 0 && person.count() > 0){
					person = person.item(1);
					readers.addElement(person);
					?'added researchCoordinators to readers set => '+readers+'\n';
					editors.addElement(person);
					?'added researchCoordinators to editors set => '+editors+'\n';
					contactsSet.addElement(person);
					?'added researchCoordinators to contacts set => '+contactsSet+'\n';
					var studyTeamMemInfo = _StudyTeamMemberInfo.createEntity();
					?'created studyTeamMemInfo => '+studyTeamMemInfo+'\n';
					studyTeamMemInfo.setQualifiedAttribute("customAttributes.studyTeamMember", person);
					?'adding person to studyTeamMemInfo => '+person+'\n';
					studyTeamMemInfo.customAttributes.canEditProtocol = canEdit;
					?'Can Edit Protocol => True\n';
					studyTeamMember.addElement(studyTeamMemInfo);
					?'added researchCoordinators to study team mem info set => '+studyTeamMember+'\n';
			}
		{{/each}}


		{{#each studyDetails.otherStudyStaff}}
			var exists = iacucQ.customAttributes.studyTeamMembers.query("customAttributes.studyTeamMember.userId='{{userId}}'");
			var person = ApplicationEntity.getResultSet("Person").query("userID = '{{userId}}'").elements();
			canEdit = true;
			if(exists.count() == 0 && person.count() > 0){
					person = person.item(1);
					readers.addElement(person);
					?'added otherStudyStaff to readers set => '+readers+'\n';
					editors.addElement(person);
					?'added otherStudyStaff to editors set => '+editors+'\n';
					contactsSet.addElement(person);
					?'added otherStudyStaff to contacts set => '+contactsSet+'\n';
					var studyTeamMemInfo = _StudyTeamMemberInfo.createEntity();
					?'created studyTeamMemInfo => '+studyTeamMemInfo+'\n';
					studyTeamMemInfo.setQualifiedAttribute("customAttributes.studyTeamMember", person);
					?'adding person to studyTeamMemInfo => '+person+'\n';
					studyTeamMemInfo.customAttributes.canEditProtocol = canEdit;
					?'Can Edit Protocol => True\n';
					studyTeamMember.addElement(studyTeamMemInfo);
					?'added otherStudyStaff to study team mem info set => '+studyTeamMember+'\n';
			}
		{{/each}}

		{{#each studyDetails.teamVolunteers}}
			var exists = iacucQ.customAttributes.studyTeamMembers.query("customAttributes.studyTeamMember.userId='{{userId}}'");
			var person = ApplicationEntity.getResultSet("Person").query("userID = '{{userId}}'").elements();
			canEdit = true;
			if(exists.count() == 0 && person.count() > 0){
					person = person.item(1);
					readers.addElement(person);
					?'added teamVolunteers to readers set => '+readers+'\n';
					editors.addElement(person);
					?'added teamVolunteers to editors set => '+editors+'\n';
					contactsSet.addElement(person);
					?'added teamVolunteers to contacts set => '+contactsSet+'\n';
					var studyTeamMemInfo = _StudyTeamMemberInfo.createEntity();
					?'created studyTeamMemInfo => '+studyTeamMemInfo+'\n';
					studyTeamMemInfo.setQualifiedAttribute("customAttributes.studyTeamMember", person);
					?'adding person to studyTeamMemInfo => '+person+'\n';
					studyTeamMemInfo.customAttributes.canEditProtocol = canEdit;
					?'Can Edit Protocol => True\n';
					studyTeamMember.addElement(studyTeamMemInfo);
					?'added teamVolunteers to study team mem info set => '+studyTeamMember+'\n';
			}
		{{/each}}

		{{#each studyDetails.teamCanNotEdit}}
			var exists = iacucQ.customAttributes.studyTeamMembers.query("customAttributes.studyTeamMember.userId='{{userId}}'");
			var person = ApplicationEntity.getResultSet("Person").query("userID = '{{userId}}'").elements();
			canEdit = false;
			if(exists.count() == 0 && person.count() > 0){
					person = person.item(1);
					readers.addElement(person);
					?'added teamCanNotEdit to readers set => '+readers+'\n';
					contactsSet.addElement(person);
					?'added teamCanNotEdit to contacts set => '+contactsSet+'\n';
					var studyTeamMemInfo = _StudyTeamMemberInfo.createEntity();
					?'created studyTeamMemInfo => '+studyTeamMemInfo+'\n';
					studyTeamMemInfo.setQualifiedAttribute("customAttributes.studyTeamMember", person);
					?'adding person to studyTeamMemInfo => '+person+'\n';
					studyTeamMemInfo.customAttributes.canEditProtocol = canEdit;
					?'Can Edit Protocol => False\n';
					studyTeamMember.addElement(studyTeamMemInfo);
					?'added teamCanNotEdit to study team mem info set => '+studyTeamMember+'\n';
			}
		{{/each}}

		{{#if studyDetails}}
			/*
				2g. Add RNAV ID
			*/
				var rnavID = '{{id}}';
				iacucQ.setQualifiedAttribute("customAttributes.rnavID", rnavID);
				?'set rnavID =>'+rnavID+'\n';
		{{/if}}



		/*
			2h. Log Create Activity
		*/

			var createProtocolActivity = ActivityType.getActivityType("_ClickIACUCSubmission_CreateProtocol", "_ClickIACUCSubmission");
			if(createProtocolActivity != null){
				iacucQ.logActivity(sch, createProtocolActivity, Person.getCurrentUser());
				?'Logging create protocol activity => '+createProtocolActivity+'\n';
			}

		/*
			2i. set status string for inbox
		*/
			var statusID = iacucQ.status.ID;
			iacucQ.setQualifiedAttribute("globalAttributes.clickProjectStatusAsString",statusID);
			?'setting inbox study status id => '+iacucQ.globalAttributes.clickProjectStatusAsString+'\n';
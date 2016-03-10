		iacucQ = wom.createTransientEntity('_ClickIACUCSubmission');
		?'iacucQ =>'+iacucQ+'\n';

		/*
			1a. update ID of iacuc Submission
		*/

			iacucQ.ID = iacuc_id;
			?'iacucQ.ID =>'+iacucQ.ID+'\n';

		/*
			1b. Register/initalize iacuc Submission and create project eset, log create activity
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

			contacts = iacucQ.contacts;

		/*
			1c. set required fields (owner, company, createdby, pi)
			if company not found --> default to MCIT
			if createdBy not found --> default to Sys Admin
			if PI not found --> leave empty
		*/
			{{#if topaz.principalInvestigator}}
				//topaz -> assigning PI to Study(IACUCQ)
				var investigator = iacucQ.getQualifiedAttribute("customAttributes.investigator");

				var person = ApplicationEntity.getResultSet("Person").query("userID = '{{topaz.principalInvestigator}}'").elements();
				
				if(investigator == null && person.count() > 0){
					var studyTeamMember = _StudyTeamMemberInfo.createEntity();
					?'_StudyTeamMemberInfo =>'+studyTeamMember+'\n';
					iacucQ.setQualifiedAttribute("customAttributes.investigator", studyTeamMember);
					person = person.item(1);
					?'person adding as PI =>'+person+'\n';
					studyTeamMember.setQualifiedAttribute("customAttributes.studyTeamMember", person);
					contacts.addElement(person);
					?'adding person to contacts set \n';
					var department = person.customAttributes;
					if(department != null){
						department = person.customAttributes.department;
						if(department != null){
							iacucQ.company = department;
							?'iacucQ.company =>'+department+'\n';
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
					}
				}
			{{else}}
				if(company == null){
					var company = ApplicationEntity.getResultSet("Company").query("NAME = 'MCIT'").elements().item(1);
					iacucQ.company = company;
					?'defaulting iacucQ.company => MCIT: '+company+'\n';
				}
			{{/if}}

			{{#if topaz.principalInvestigator}}
				//createdby => topaz.pi
				var create = iacucQ.createdBy;
				if(create == null){
					var person = ApplicationEntity.getResultSet("Person").query("userID = '{{topaz.principalInvestigator}}'");
					if(person.count() > 0){
						person = person.elements().item(1);
						iacucQ.createdBy = person;
						?'iacucQ.createdBy =>'+iacucQ.createdBy+'\n';
					}
					else{
						?'Person Not Found =>topaz.principalInvestigator\n';
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
				}
			{{/if}}

		/*
			1d. set submissionType, typeofProtocol --> required fields
		*/	
			{{#if topaz.submissionType}}
				var submissionType = entityUtils.getObjectFromString('{{topaz.submissionType.oid}}');
				iacucQ.setQualifiedAttribute("customAttributes.typeOfSubmission", submissionType);
		         ?'setting iacucQ.customAttributes.typeOfSubmission =>'+submissionType+'\n';
	        {{/if}}

	        {{#if topaz.protocolType}}
	        	var protocolType = entityUtils.getObjectFromString('{{topaz.protocolType.oid}}');
	        	iacucQ.setQualifiedAttribute("customAttributes.typeOfProtocol", protocolType);
	        	?'setting ProtocolType =>'+protocolType+'\n';
	        	var submissionTypeName = iacucQ.customAttributes.typeOfSubmission.customAttributes.name;
	        	if(submissionTypeName != 'New Protocol Application'){
	        		iacucQ.setQualifiedAttribute("customAttributes.previousTypeOfProtocol", protocolType);
	        		?'setting Previous ProtocolType =>'+protocolType+'\n';
	        	}
	        {{/if}}

	        {{#if topaz.draftProtocol}}
	        	var draft = ApplicationEntity.getResultSet('_ClickIACUCSubmission').query("ID='{{topaz.draftProtocol.id}}'");
	        	if(draft.count() > 0){
	        		draft = draft.elements().item(1);
	        		iacucQ.setQualifiedAttribute("customAttributes.draftProtocol", draft);
	        		?'setting draftProtocol =>'+draft+'\n';
	        	}

	        {{/if}}

	    /*
	    	1e. set IACUC Settings
	    */
	    	var iacucSettings = _ClickIACUCSettings.getIACUCSettings();
	        iacucQ.setQualifiedAttribute("customAttributes.iacucSettings", iacucSettings);
	        ?'iacucQ.customAttributes.iacucSettings =>'+iacucQ.customAttributes.iacucSettings+'\n';

	    /*
	    	1f. set IACUC parent to self if new protocol
	    */
	    {{#if topaz.draftProtocol}}
	    	var parentStudy = iacucQ.getQualifiedAttribute("customAttributes.parentProtocol");
	    	var parentSubmission = ApplicationEntity.getResultSet('_ClickIACUCSubmission').query("ID='{{topaz.draftProtocol.id}}'");
			if(parentStudy == null && parentSubmission.count() > 0){
				parentSubmission = parentSubmission.elements().item(1);
				iacucQ.setQualifiedAttribute("customAttributes.parentProtocol", parentSubmission);
			}
			?'parentProtocol =>'+iacucQ.customAttributes.parentProtocol+'\n';

			var draftProtocol = iacucQ.getQualifiedAttribute("customAttributes.draftProtocol");
			if(draftProtocol == null && parentSubmission.count() > 0){
				parentSubmission = parentSubmission.elements().item(1);
				iacucQ.setQualifiedAttribute("customAttributes.draftProtocol", parentSubmission);
			}
			?'draftProtocol =>'+iacucQ.customAttributes.draftProtocol +'\n';

	    {{else}}
	    	var parentProtocol = iacucQ.getQualifiedAttribute("customAttributes.parentProtocol");
			if(parentProtocol == null){
				iacucQ.setQualifiedAttribute("customAttributes.parentProtocol", iacucQ);
			}
			?'parentProtocol =>'+iacucQ.customAttributes.parentProtocol+'\n';
		{{/if}}

		/*
			1g. set irb status to pre-submission
				set dateCreated/dateModified;
		*/
			{{#if topaz.projectStatus}}
				var status = iacucQ.status;
				if(status == null){
					var statusOID = entityUtils.getObjectFromString('{{topaz.projectStatus.oid}}');
					iacucQ.status = statusOID;
					?'iacucQ.status =>'+statusOID+'\n';
				}
			{{else}}
				var status = iacucQ.status;
				if(status == null){
					var statusOID = entityUtils.getObjectFromString('com.webridge.entity.Entity[OID[9F73BE7925820443ABD79B34AD90AA55]]');
					iacucQ.status = statusOID;
					?'iacucQ.status =>'+iacucQ.status+'\n';
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
					else if(status == "Approved - Managed Externally" || status == "Expired - Managed Externally"){
						whichTemplate = "TMPL8D07C62360C5A80";
						?'template AR=>'+whichTemplate+'\n';					
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
					else if(status == "Approved - Managed Externally" || status == "Expired - Managed Externally"){
						whichTemplate = "TMPL8D089BC317FF635";
						?'template AR=>'+whichTemplate+'\n';					
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
					else if(status == "Approved - Managed Externally" || status == "Expired - Managed Externally"){
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
					else if(status == "Approved - Managed Externally" || status == "Expired - Managed Externally"){
						whichTemplate = "TMPL8D0C8D3FA92169A";
						?'template AR=>'+whichTemplate+'\n';					
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
			var container;
			if(submissionTypeName == "New Protocol Application"){
				container = Container.getElements("ContainerForID", "ID", "CLICK_IACUC_SUBMISSIONS").item(1);
			}
			else if(submissionTypeName == "Triennial Review" || submissionTypeName == "Annual Review" || submissionTypeName == "Amendment"){
				var parentSubmission = ApplicationEntity.getResultSet('_ClickIACUCSubmission').query("ID='{{topaz.draftProtocol.id}}'");
				if(parentSubmission.count() > 0){
						parentSubmission = parentSubmission.elements().item(1);
						container = parentSubmission.resourceContainer;
						?'using parent.resourceContainer =>'+container+'\n';
				}
				else{
					container = Container.getElements("ContainerForID", "ID", "CLICK_IACUC_SUBMISSIONS").item(1);
					?'Cant find parent, using default container =>'+container+'\n';
				}
			}
			
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
			var putName = "{{breaklines name}}"
			var shortenedPutName = putName.slice(0,255);
			iacucQ.name = shortenedPutName;
			?'setting iacucQ name =>'+iacucQ.name+'\n';
			{{#if studyDetails.longTitle}}
				//iacucQ.customAttributes.fullTitle = "{{breaklines studyDetails.longTitle}}";
				//?'setting iacucQ.customAttributes.fullTitle =>'+iacucQ.customAttributes.fullTitle+'\n';
				iacucQ.customAttributes.fullTitle_text = "{{breaklines studyDetails.longTitle_text}}";
				?'setting iacucQ.customAttributes.fullTitle_text=>'+iacucQ.customAttributes.fullTitle_text+'\n';
			{{else}}
				iacucQ.customAttributes.fullTitle = shortenedPutName;
				?'default setting to name: iacucQ.customAttributes.fullTitle =>'+iacucQ.customAttributes.fullTitle+'\n';
				iacucQ.customAttributes.fullTitle_text = shortenedPutName;
				?'default setting to name: iacucQ.customAttributes.fullTitle_text=>'+iacucQ.customAttributes.fullTitle_text+'\n';
			{{/if}}

		/*
			2a. set admin office --> com.webridge.entity.Entity[OID[455A658DB0BA7D498CB6DF34E2CA25EA]];
		*/
			var adminOffice = entityUtils.getObjectFromString('com.webridge.entity.Entity[OID[455A658DB0BA7D498CB6DF34E2CA25EA]]');
			iacucQ.setQualifiedAttribute('customAttributes.adminOffice', adminOffice);
			?'setting adminOffice added=>'+adminOffice+'\n';

		/*
			2b. create guest list eset 
		*/
			var person = Person.createEntitySet();
			iacucQ.setQualifiedAttribute("customAttributes.guestList", person );
			?'guestList set created=>'+iacucQ.customAttributes.guestList+'\n';

		/*
			2c. create readers/editors eset
		*/
			var person = Person.createEntitySet();
			iacucQ.setQualifiedAttribute("customAttributes.readers", person );
			?'readers set created=>'+iacucQ.customAttributes.readers+'\n';

			var person = Person.createEntitySet();
			iacucQ.setQualifiedAttribute("customAttributes.editors", person);
			?'editors set created => '+iacucQ.customAttributes.editors+'\n';

			var readers = iacucQ.customAttributes.readers;
			var editors = iacucQ.customAttributes.editors;

			{{#if topaz.principalInvestigator}}
				var person = ApplicationEntity.getResultSet("Person").query("userID = '{{topaz.principalInvestigator}}'").elements();
				if(person.count() > 0){
					person = person.item(1);
					readers.addElement(person);
					?'added PI to readers set => '+readers+'\n';
					editors.addElement(person);
					?'added PI to editors set => '+editors+'\n';
				}
				else{
					?'Cant Find PI => {{topaz.principalInvestigator}} not found \n';
				}
			{{/if}}
		
		{{#if topaz.protocolNumber}}
			/*
				2d. add protocol number
			*/
				var protocolNumber = '{{topaz.protocolNumber}}';
				iacucQ.setQualifiedAttribute("customAttributes.protocolNumber", protocolNumber);
				?'setting protocolNumber =>'+protocolNumber+'\n';
		{{/if}}

		/*
			2e. create active amendment eset
		*/

		var submissionTypeName = iacucQ.customAttributes.typeOfSubmission.customAttributes.name;
		if(submissionTypeName == "New Protocol Application"){
			var amend = _ClickAmendment.createEntity();
			iacucQ.setQualifiedAttribute('customAttributes.amendment', amend);
			?'set amendment=>'+amend+'\n';

			var activeAmendSet = ApplicationEntity.createEntitySet('_ClickActiveAmendment');
			iacucQ.customAttributes.amendment.setQualifiedAttribute("customAttributes.activeAmendments" , activeAmendSet);
			?'set activeAmendSet =>'+iacucQ.customAttributes.amendment.customAttributes.activeAmendments+'\n';
		}
		if(submissionTypeName == "Amendment"){
			var parent = iacucQ.customAttributes.parentProtocol;
			if(parent != null){
				var amendment = parent.customAttributes.amendment;
				if(amendment != null){
					var activeSet = amendment.customAttributes.activeAmendments;
					if(activeSet){
						var activeAmend = _ClickActiveAmendment.createEntity();
						?'iacucQ create _ClickActiveAmendment => '+activeAmend+'\n';
						activeAmend.setQualifiedAttribute('customAttributes.activeAmendment', iacucQ);
						?'assign active amendment => '+iacucQ+'\n';
						activeSet.addElement(activeAmend);
						?'add activeAmendment to set => '+activeAmend+'\n';
					}
				}
				else{
					?'parent.amendment not found\n';
					var amend = _ClickAmendment.createEntity();
					iacucQ.customAttributes.parentProtocol.setQualifiedAttribute('customAttributes.amendment', amend);
					?'set amendment=>'+amend+'\n';

					var activeAmendSet = ApplicationEntity.createEntitySet('_ClickActiveAmendment');
					iacucQ.customAttributes.parentProtocol.customAttributes.amendment.setQualifiedAttribute("customAttributes.activeAmendments" , activeAmendSet);
					?'set activeAmendSet =>'+iacucQ.customAttributes.amendment.customAttributes.activeAmendments+'\n';
				}
			}
		}

		/*
			2f. create following esets :
			alternativeProceduresSearch => _ClickProcedureRefinement --> created
			ancillaryReviews => _ancillaryReview --> created
			animalCounts => _ClickAnimalCounts --> created
			animalDisposition => _clickAnimalDisposition --> created
			animalHousingLocationRoom => _ClickNonVivariumHousingLocation --> created
			approvedDepartures => _ClickDeparture --> created
			backgroundStrains => _ClickBackgroundStrain --> created
			changeLog => _ClickChangeLog --> created
			designatedMemberReviews => _ClickDesignatedMemberReview --> created
			duplicateProceduresSearch => _ClickProcedureRefinement --> created
			editors => Person --> created
			animalGroups => _ClickAnimalGroup --> created
			externalProtocolTeamInformation => ?(Set of Document) - Type: Document --> created
			financialInterests => ?(Set of Document) - Type: Document --> created
			financiallyInterested => Person --> created
			fundingSources => _ClickFundingSource --> created
			guestList => Person --> created
			guestListOrgs => Company --> created
			historicalReviewerNotes => ?(Set of ReviewerNote) - Type: ReviewerNote --> created
			lapses => _ClickLapse --> created
			longTermNonVivariumHousingLocations => _ClickNonVivariumHousingLocation --> created
			piProxiesPerson => Person --> created
			pendingDesignatedMemberReviewers => Person --> created
			procedurePersonnel => _ClickProcedureTeam --> created
			procedureTraining => _StudyTeamMemberInfo --> created
			studyTeamMembers => _StudyTeamMemberInfo --> created
			readers => Person --> created
			relatedSafetyProtocols => _ClickRelatedSafetyProtocol --> created
			setOfReviews => _review --> doesn't work!!
			snapshots => ?(Set of Document) Type: Document --> created
			supportDocuments => ?(Set of Document) Type: Document --> created
			suspensions => _ClickSuspension --> created
			tags => _ClickTag --> created
			usedAnimalCounts => _ClickUsedAnimalCounts --> created
			vivariumHousingLocations => _ClickNonVivariumHousingLocation --> created
		*/
			var histReviewNote = iacucQ.customAttributes.historicalReviewerNotes;
			if(histReviewNote == null){
				var a = ApplicationEntity.createEntitySet('ReviewerNote');
				iacucQ.customAttributes.historicalReviewerNotes = a;
				?'setting historical reviewer notes eset => '+iacucQ.customAttributes.historicalReviewerNotes+'\n';
			}

			var externalTeamInfo = iacucQ.customAttributes.externalProtocolTeamInformation;
			if(externalTeamInfo == null){
				var a = ApplicationEntity.createEntitySet('Document');
				iacucQ.customAttributes.externalProtocolTeamInformation = a;
				?'setting external protocol team info eset => '+iacucQ.customAttributes.externalProtocolTeamInformation+'\n';
			}

			var finanInter = iacucQ.customAttributes.financialInterests;
			if(finanInter == null){
				var a = ApplicationEntity.createEntitySet('Document');
				iacucQ.customAttributes.financialInterests = a;
				?'setting financial interests eset => '+iacucQ.customAttributes.financialInterests+'\n';
			}

			var snapshot = iacucQ.customAttributes.snapshots;
			if(snapshot == null){
				var a = ApplicationEntity.createEntitySet('Document');
				iacucQ.customAttributes.snapshots = a;
				?'setting snapshots eset => '+iacucQ.customAttributes.snapshots+'\n';
			}

			var suppDoc = iacucQ.customAttributes.supportDocuments;
			if(suppDoc == null){
				var a = ApplicationEntity.createEntitySet('Document');
				iacucQ.customAttributes.supportDocuments = a;
				?'setting support document eset => '+iacucQ.customAttributes.supportDocuments+'\n';
			}

			var altProc = iacucQ.customAttributes.alternativeProceduresSearch;
			if(altProc == null){
				var a = ApplicationEntity.createEntitySet('_ClickProcedureRefinement');
				iacucQ.customAttributes.alternativeProceduresSearch = a;
				?'setting alternative procedure search => '+iacucQ.customAttributes.alternativeProceduresSearch+'\n';
			}

			var ancReview = iacucQ.customAttributes.ancillaryReviews;
			if(ancReview == null){
				var a = ApplicationEntity.createEntitySet('_ancillaryReview');
				iacucQ.customAttributes.ancillaryReviews = a;
				?'setting ancillary reviews eset => '+iacucQ.customAttributes.ancillaryReviews+'\n';
			}

			var animalCount = iacucQ.customAttributes.animalCounts;
			if(animalCount == null){
				var a = ApplicationEntity.createEntitySet('_ClickAnimalCounts');
				iacucQ.customAttributes.animalCounts = a;
				?'setting animal counts eset => '+iacucQ.customAttributes.animalCounts+'\n';
			}

			var animalDispos = iacucQ.customAttributes.animalDisposition;
			if(animalDispos == null){
				var a = ApplicationEntity.createEntitySet('_clickAnimalDisposition');
				iacucQ.customAttributes.animalDisposition = a;
				?'setting animal disposition eset => '+iacucQ.customAttributes.animalDisposition+'\n';
			}

			var animalHousing = iacucQ.customAttributes.animalHousingLocationRoom;
			if(animalHousing == null){
				var a = ApplicationEntity.createEntitySet('_ClickNonVivariumHousingLocation');
				iacucQ.customAttributes.animalHousingLocationRoom = a;
				?'setting animal housing location room eset => '+iacucQ.customAttributes.animalHousingLocationRoom+'\n';
			}

			var appDeparture = iacucQ.customAttributes.approvedDepartures;
			if(appDeparture == null){
				var a = ApplicationEntity.createEntitySet('_ClickDeparture');
				iacucQ.customAttributes.approvedDepartures = a;
				?'setting approved departures eset => '+iacucQ.customAttributes.approvedDepartures+'\n';
			}

			var bgStains = iacucQ.customAttributes.backgroundStrains;
			if(bgStains == null){
				var a = ApplicationEntity.createEntitySet('_ClickBackgroundStrain');
				iacucQ.customAttributes.backgroundStrains = a;
				?'setting back ground strains eset => '+iacucQ.customAttributes.backgroundStrains+'\n';
			}

			var changeLogs = iacucQ.customAttributes.changeLog;
			if(changeLogs == null){
				var a = ApplicationEntity.createEntitySet('_ClickChangeLog');
				iacucQ.customAttributes.changeLog = a;
				?'setting change log eset => '+iacucQ.customAttributes.changeLog+'\n';
			}

			var desMemRev = iacucQ.customAttributes.designatedMemberReviews;
			if(desMemRev == null){
				var a = ApplicationEntity.createEntitySet('_ClickDesignatedMemberReview');
				iacucQ.customAttributes.designatedMemberReviews = a;
				?'setting designated member review eset => '+iacucQ.customAttributes.designatedMemberReviews+'\n';
			}

			var dupProcSearch = iacucQ.customAttributes.duplicateProceduresSearch;
			if(dupProcSearch == null){
				var a = ApplicationEntity.createEntitySet('_ClickProcedureRefinement');
				iacucQ.customAttributes.duplicateProceduresSearch = a;
				?'setting duplicate procedures search eset => '+iacucQ.customAttributes.duplicateProceduresSearch+'\n';
			}

			var animalGroup = iacucQ.customAttributes.animalGroups;
			if(animalGroup == null){
				var a = ApplicationEntity.createEntitySet('_ClickAnimalGroup');
				iacucQ.customAttributes.animalGroups = a;
				?'setting animal groups eset => '+iacucQ.customAttributes.animalGroups+'\n';
			}

			var financialInterest = iacucQ.customAttributes.financiallyInterested;
			if(financialInterest == null){
				var a = ApplicationEntity.createEntitySet('Person');
				iacucQ.customAttributes.financiallyInterested = a;
				?'setting financiallyInterested eset => '+iacucQ.customAttributes.financiallyInterested+'\n';
			}

			var fundSources = iacucQ.customAttributes.fundingSources;
			if(fundSources == null){
				var a = ApplicationEntity.createEntitySet('_ClickFundingSource');
				iacucQ.customAttributes.fundingSources = a;
				?'setting funding sources eset => '+iacucQ.customAttributes.fundingSources+'\n';
			}

			var guestListsOrg = iacucQ.customAttributes.guestListOrgs;
			if(guestListsOrg == null){
				var a = ApplicationEntity.createEntitySet('Company');
				iacucQ.customAttributes.guestListOrgs = a;
				?'setting guest list organizations eset => '+iacucQ.customAttributes.guestListOrgs+'\n';
			}

			var lapse = iacucQ.customAttributes.lapses;
			if(lapse == null){
				var a = ApplicationEntity.createEntitySet('_ClickLapse');
				iacucQ.customAttributes.lapses = a;
				?'setting lapses eset => '+iacucQ.customAttributes.lapses+'\n';
			}

			var longTermVivHousing = iacucQ.customAttributes.longTermNonVivariumHousingLocations;
			if(longTermVivHousing == null){
				var a = ApplicationEntity.createEntitySet('_ClickNonVivariumHousingLocation');
				iacucQ.customAttributes.longTermNonVivariumHousingLocations = a;
				?'setting long term non viv housing eset => '+iacucQ.customAttributes.longTermNonVivariumHousingLocations+'\n';
			}

			var piProxies = iacucQ.customAttributes.piProxiesPerson;
			if(piProxies == null){
				var a = ApplicationEntity.createEntitySet('Person');
				iacucQ.customAttributes.piProxiesPerson = a;
				?'setting pi proxies eset => '+iacucQ.customAttributes.piProxiesPerson+'\n';
			}

			var pendDesMember = iacucQ.customAttributes.pendingDesignatedMemberReviewers;
			if(pendDesMember == null){
				var a = ApplicationEntity.createEntitySet('Person');
				iacucQ.customAttributes.pendingDesignatedMemberReviewers = a;
				?'setting pending designated member reviewer eset => '+iacucQ.customAttributes.pendingDesignatedMemberReviewers+'\n';
			}

			var procPersonnel = iacucQ.customAttributes.procedurePersonnel;
			if(procPersonnel == null){
				var a = ApplicationEntity.createEntitySet('_ClickProcedureTeam');
				iacucQ.customAttributes.procedurePersonnel = a;
				?'setting procedure personnel eset => '+iacucQ.customAttributes.procedurePersonnel+'\n';
			}

			var procTraining = iacucQ.customAttributes.procedureTraining;
			if(procTraining == null){
				var a = ApplicationEntity.createEntitySet('_StudyTeamMemberInfo');
				iacucQ.customAttributes.procedureTraining = a;
				?'setting procedureTraining eset => '+iacucQ.customAttributes.procedureTraining+'\n';
			}

			var studyTeamMember = iacucQ.customAttributes.studyTeamMembers;
			if(studyTeamMember == null){
				var a = ApplicationEntity.createEntitySet('_StudyTeamMemberInfo');
				iacucQ.customAttributes.studyTeamMembers = a;
				?'setting studyTeamMembers eset => '+iacucQ.customAttributes.studyTeamMembers+'\n';
			}

			var relatedSafetyProto = iacucQ.customAttributes.relatedSafetyProtocols;
			if(relatedSafetyProto == null){
				var a = ApplicationEntity.createEntitySet('_ClickRelatedSafetyProtocol');
				iacucQ.customAttributes.relatedSafetyProtocols = a;
				?'setting related safetly protocols eset => '+iacucQ.customAttributes.relatedSafetyProtocols+'\n';
			}

			/*
			var setReview = iacucQ.customAttributes.setOfReviews;
			if(setReview == null){
				var a = ApplicationEntity.createEntitySet('_review');
				iacucQ.customAttributes.setOfReviews = a;
				?'setting set of reviews eset => '+iacucQ.customAttributes.setOfReviews+'\n';
			}
			*/

			var suspension = iacucQ.customAttributes.suspensions;
			if(suspension == null){
				var a = ApplicationEntity.createEntitySet('_ClickSuspension');
				iacucQ.customAttributes.suspensions = a;
				?'setting suspensions eset => '+iacucQ.customAttributes.suspensions;
			}

			var tag = iacucQ.customAttributes.tags;
			if(tag == null){
				var a = ApplicationEntity.createEntitySet('_ClickTag');
				iacucQ.customAttributes.tags = a;
				?'setting tags eset => '+iacucQ.customAttributes.tags+'\n';
			}

			var usedAniCount = iacucQ.customAttributes.usedAnimalCounts;
			if(usedAniCount == null){
				var a = ApplicationEntity.createEntitySet('_ClickUsedAnimalCounts');
				iacucQ.customAttributes.usedAnimalCounts = a;
				?'setting used animal count eset => '+iacucQ.customAttributes.usedAnimalCounts+'\n';
			}

			var vivHousingLocation = iacucQ.customAttributes.vivariumHousingLocations;
			if(vivHousingLocation == null){
				var a = ApplicationEntity.createEntitySet('_ClickNonVivariumHousingLocation');
				iacucQ.customAttributes.vivariumHousingLocations = a;
				?'setting vivHousingLocation eset => '+iacucQ.customAttributes.vivariumHousingLocations+'\n';
			}


			/*
				2g. log create activity
			*/
			var createProtocolActivity = ActivityType.getActivityType("_ClickIACUCSubmission_CreateProtocol", "_ClickIACUCSubmission");
			if(createProtocolActivity != null){
				iacucQ.logActivity(sch, createProtocolActivity, Person.getCurrentUser());
				?'Logging create protocol activity => '+createProtocolActivity+'\n';
			}

			/*
				2h. add study team members
			*/

			var readers = iacucQ.customAttributes.readers;
			var editors = iacucQ.customAttributes.editors;
			var studyTeamMember = iacucQ.customAttributes.studyTeamMembers;
			var contacts = iacucQ.contacts;
			var canEdit;

			{{#if topaz.coInvestigators}}
				var coInvestigatorSet = "{{topaz.coInvestigators}}";
				var kerborosArray = new Array();
				canEdit = true;
				kerborosArray = coInvestigatorSet.split(",");
				for( var i = 0; i<kerborosArray.length; i++){
					var studyTeamMem = kerborosArray[i];
					var exists = iacucQ.customAttributes.studyTeamMembers.query("customAttributes.studyTeamMember.userId='"+studyTeamMem+"'");
					var person = ApplicationEntity.getResultSet("Person").query("userID = '"+studyTeamMem+"'").elements();
					if(exists.count() == 0 && person.count() > 0){
						person = person.item(1);
						readers.addElement(person);
						?'added teamSubInvestigators to readers set => '+readers+'\n';
						editors.addElement(person);
						?'added teamSubInvestigators to editors set => '+editors+'\n';
						contacts.addElement(person);
						?'adding person to contacts set => '+contacts+'\n';
						var studyTeamMemInfo = _StudyTeamMemberInfo.createEntity();
						?'created studyTeamMemInfo => '+studyTeamMemInfo+'\n';
						studyTeamMemInfo.setQualifiedAttribute("customAttributes.studyTeamMember", person);
						?'adding person to studyTeamMemInfo => '+person+'\n';
						studyTeamMemInfo.customAttributes.canEditProtocol = canEdit;
						?'Can Edit Protocol => True\n';
						studyTeamMember.addElement(studyTeamMemInfo);
						?'added teamSubInvestigators to study team mem info set => '+studyTeamMember+'\n';
					}
					else if(exists.count() > 0){
						?'Person already exists => '+studyTeamMem+'\n';
					}
					else{
						?'Person not found by kerboros id => '+studyTeamMem+'\n';
					}
				}
			{{/if}}

			{{#if topaz.associates}}
				var associateSet = "{{topaz.associates}}";
				var kerborosArray = new Array();
				kerborosArray = associateSet.split(",");
				canEdit = true;
				for( var i = 0; i<kerborosArray.length; i++){
					var studyTeamMem = kerborosArray[i];
					var exists = iacucQ.customAttributes.studyTeamMembers.query("customAttributes.studyTeamMember.userId='"+studyTeamMem+"'");
					var person = ApplicationEntity.getResultSet("Person").query("userID = '"+studyTeamMem+"'").elements();
					if(exists.count() == 0 && person.count() > 0){
						person = person.item(1);
						readers.addElement(person);
						?'added associates to readers set => '+readers+'\n';
						editors.addElement(person);
						?'added associates to editors set => '+editors+'\n';
						contacts.addElement(person);
						?'adding person to contacts set => '+contacts+'\n';
						var studyTeamMemInfo = _StudyTeamMemberInfo.createEntity();
						?'created studyTeamMemInfo => '+studyTeamMemInfo+'\n';
						studyTeamMemInfo.setQualifiedAttribute("customAttributes.studyTeamMember", person);
						?'adding person to studyTeamMemInfo => '+person+'\n';
						studyTeamMemInfo.customAttributes.canEditProtocol = canEdit;
						?'Can Edit Protocol => True\n';
						studyTeamMember.addElement(studyTeamMemInfo);
						?'added associates to study team mem info set => '+studyTeamMember+'\n';
					}
					else if(exists.count() > 0){
						?'Person already exists => '+studyTeamMem+'\n';
					}
					else{
						?'Person not found by kerboros id => '+studyTeamMem+'\n';
					}
				}
			{{/if}}


			/*
				2i. setting approvalDate/annualExpirationDate/effectiveDate on original, status ID as string in inbox
			*/
			{{#if topaz.approvalDate}}
				var date = "{{topaz.approvalDate}}";
				var dateArray = date.split('-');
				var day = dateArray[2].substring(0,2);
				var month = dateArray[1] - 1;
				var year = dateArray[0];
				var a = new Date(year, month, day);
				iacucQ.customAttributes.approvalDate = a;
				?'setting approvalDate => '+iacucQ.customAttributes.approvalDate+'\n';
			{{/if}}

			{{#if topaz.expirationDate}}
				var date = "{{topaz.expirationDate}}";
				var dateArray = date.split('-');
				var day = dateArray[2].substring(0,2);
				var month = dateArray[1] - 1;
				var year = dateArray[0];
				var a = new Date(year, month, day);
				iacucQ.customAttributes.annualExpirationDate = a;
				?'setting annualExpirationDate => '+iacucQ.customAttributes.annualExpirationDate+'\n';

			{{/if}}

			{{#if topaz.effectiveDate}}
				var date = "{{topaz.effectiveDate}}";
				var dateArray = date.split('-');
				var day = dateArray[2].substring(0,2);
				var month = dateArray[1] - 1;
				var year = dateArray[0];
				var a = new Date(year, month, day);
				iacucQ.customAttributes.effectiveDate = a;
				?'setting effectiveDate => '+iacucQ.customAttributes.effectiveDate+'\n';

			{{/if}}	

			{{#if topaz.annualExpirationDate}}
				var date = "{{topaz.annualExpirationDate}}";
				var dateArray = date.split('-');
				var day = dateArray[2].substring(0,2);
				var month = dateArray[1] - 1;
				var year = dateArray[0];
				var a = new Date(year, month, day);
				iacucQ.customAttributes.annualExpirationDate = a;
				?'setting annualExpirationDate => '+iacucQ.customAttributes.annualExpirationDate+'\n';
			{{/if}}		

			var statusID = iacucQ.status.ID;
			iacucQ.setQualifiedAttribute("globalAttributes.clickProjectStatusAsString",statusID);
			?'setting inbox study status id => '+iacucQ.globalAttributes.clickProjectStatusAsString+'\n';

			/*
				2j. Create DRAFT Protocol
			*/

			var newClone = wom.createTransientEntity('_ClickIACUCSubmission');
			?'created Draft Protocol => '+newClone+'\n';
			newClone.ID = _ClickIACUCSubmission.getID("_ClickIACUCSubmission");
			?'draft ID => '+newClone.ID+'\n';
			newClone.name = iacucQ.name;
			?'draft name => '+newClone.name+'\n';
			newClone.registerEntity();
			var today = new Date();
			newClone.setQualifiedAttribute("dateModified",today);
			newClone.setQualifiedAttribute("dateCreated",today);
			var submissionTypeID = iacucQ.getQualifiedAttribute("customAttributes.typeOfSubmission.ID");
			if (submissionTypeID == "PROTOYYYY") {
				var draftState = wom.getEntityFromString("com.webridge.entity.Entity[OID[FD2459F62BE5EF4784A54A250997A3D2]]");
				var draftSubmissionType = _SubmissionType.getResultSet("_SubmissionType").query("ID = 'DRAFTYYYY'").elements().item(1);
				?'Draft SubmissionType => '+draftSubmissionType+'\n';
				?'Draft State => '+draftState+'\n';
				newClone.setQualifiedAttribute("customAttributes.typeOfSubmission", draftSubmissionType);
				newClone.setQualifiedAttribute("status", draftState);
				newClone.setQualifiedAttribute("customAttributes.parentProtocol", iacucQ);
				iacucQ.setQualifiedAttribute("customAttributes.draftProtocol", newClone);

				/*
					create readers
				*/
					var person = Person.createEntitySet();
					newClone.setQualifiedAttribute("customAttributes.readers", person );
					?'readers set created=> '+newClone.customAttributes.readers+'\n';

					var readers = iacucQ.customAttributes.readers;
					var draftReaders = newClone.customAttributes.readers;

				/*
					create editors
				*/
					var person = Person.createEntitySet();
					newClone.setQualifiedAttribute("customAttributes.editors", person);
					?'editors set created => '+newClone.customAttributes.editors+'\n';

					var editors = iacucQ.customAttributes.editors;
					var draftEditors = newClone.customAttributes.editors;

				/*
					create studyTeamMembers
				*/
					var studyTeamMember = newClone.customAttributes.studyTeamMembers;
					if(studyTeamMember == null){
						var a = ApplicationEntity.createEntitySet('_StudyTeamMemberInfo');
						newClone.customAttributes.studyTeamMembers = a;
						?'setting studyTeamMembers eset => '+newClone.customAttributes.studyTeamMembers+'\n';
					}

					var studyTeamMember = iacucQ.customAttributes.studyTeamMembers;
					var draftStudyTeam = newClone.customAttributes.studyTeamMembers;

					for(var i = 1; i<=readers.count(); i++){
						var person = readers.elements().item(i);
						draftReaders.addElement(person);
						?'adding person to draft readers => '+person.userId+'\n';
					}

					for(var i = 1; i<=editors.count(); i++){
						var person = editors.elements().item(i);
						draftEditors.addElement(person);
						?'adding person to draft editors => '+person.userId+'\n';

					}

					for(var i = 1; i<=studyTeamMember.count(); i++){
						var studyTeamMem = studyTeamMember.elements().item(i);
						var studyTeamMem_1 = EntityCloner.quickClone(studyTeamMem);
						draftStudyTeam.addElement(studyTeamMem_1);
						?'adding studyTEamMem to draft studyTeamMember => '+studyTeamMem_1+'\n';
					}
				/*
					set ProtocolType
				*/

					{{#if topaz.protocolType}}
			        	var protocolType = entityUtils.getObjectFromString('{{topaz.protocolType.oid}}');
			        	newClone.setQualifiedAttribute("customAttributes.typeOfProtocol", protocolType);
			        	?'setting ProtocolType =>'+protocolType+'\n';
			        	var submissionTypeName = iacucQ.customAttributes.typeOfSubmission.customAttributes.name;
			        	if(submissionTypeName != 'New Protocol Application'){
			        		iacucQ.setQualifiedAttribute("customAttributes.previousTypeOfProtocol", protocolType);
			        		?'setting Previous ProtocolType =>'+protocolType+'\n';
			        	}
			        {{/if}}

			     /*
			     	set ProtocolNumber
			     */
			     	var mainProtocolNumber = iacucQ.customAttributes.protocolNumber;
			     	if(mainProtocolNumber != null){
			     		newClone.customAttributes.protocolNumber = mainProtocolNumber;
			     		?'setting protocolNumber for draft study => '+newClone.customAttributes.protocolNumber+'\n';
			     	}

			    /*
			    	set approval/FinalExpirationDate in draft
			    */

			    {{#if topaz.approvalDate}}
					var date = "{{topaz.approvalDate}}";
					var dateArray = date.split('-');
					var day = dateArray[2].substring(0,2);
					var month = dateArray[1] - 1;
					var year = dateArray[0];
					var a = new Date(year, month, day);
					newClone.customAttributes.approvalDate = a;
					?'setting draft approvalDate => '+newClone.customAttributes.approvalDate+'\n';
				{{/if}}

				{{#if topaz.expirationDate}}
					var date = "{{topaz.expirationDate}}";
					var dateArray = date.split('-');
					var day = dateArray[2].substring(0,2);
					var month = dateArray[1] - 1;
					var year = dateArray[0];
					var a = new Date(year, month, day);
					newClone.customAttributes.finalExpirationDate = a;
					?'setting draft finalExpirationDate => '+newClone.customAttributes.finalExpirationDate+'\n';

				{{/if}}

				{{#if topaz.effectiveDate}}
					var date = "{{topaz.effectiveDate}}";
					var dateArray = date.split('-');
					var day = dateArray[2].substring(0,2);
					var month = dateArray[1] - 1;
					var year = dateArray[0];
					var a = new Date(year, month, day);
					newClone.customAttributes.effectiveDate = a;
					?'setting draft effectiveDate => '+newClone.customAttributes.effectiveDate+'\n';

				{{/if}}

				{{#if topaz.annualExpirationDate}}
					var date = "{{topaz.annualExpirationDate}}";
					var dateArray = date.split('-');
					var day = dateArray[2].substring(0,2);
					var month = dateArray[1] - 1;
					var year = dateArray[0];
					var a = new Date(year, month, day);
					newClone.customAttributes.annualExpirationDate = a;
					?'setting draft annualExpirationDate => '+newClone.customAttributes.annualExpirationDate+'\n';
				{{/if}}

				  var parentSubmission = newClone.customAttributes.parentProtocol;
			 	  var parentInvest = parentSubmission.customAttributes.investigator;
			 	  var adminOffice = entityUtils.getObjectFromString('com.webridge.entity.Entity[OID[455A658DB0BA7D498CB6DF34E2CA25EA]]');
			 	  var parentComp = parentSubmission.company;
			 	  var parentCreatedby = parentSubmission.createdBy;
			 	  if(parentInvest){
			 	  		var invest = EntityCloner.quickClone(parentInvest);
			 	  		newClone.setQualifiedAttribute('customAttributes.investigator', invest);
			 	  }

			 	  newClone.setQualifiedAttribute('customAttributes.adminOffice', adminOffice);

			 	  newClone.company =  parentComp;
			 	  
			 	  newClone.createdBy = parentCreatedby;

			 	var projectSet = newClone.projects;
				if(projectSet == null){
					var projectSet = Project.createEntitySet();
					newClone.projects = projectSet;
					?'Created Project Set for Draft => '+newClone.projects+'\n';
				}

			}
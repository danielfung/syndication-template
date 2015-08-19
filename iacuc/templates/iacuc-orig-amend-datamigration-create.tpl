		//TESTING PARTIALS(DATA MIGRATION TEST)
		iacucQ = wom.createTransientEntity('_ClickIACUCSubmission');
		?'iacucQ =>'+iacucQ+'\n';

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
			var iacucQ = ApplicationEntity.getResultSet('_ClickIACUCSubmission').query("ID='"+iacuc_id+"'").elements().item(1);

			if(iacucQ.customAttributes == null){
				var c = _ClickIACUCSubmission_CustomAttributesManager.createEntity();
				iacucQ.customAttributes = c;
				?'created iacucQ.customAttributes =>'+c+'\n';
			}

		/*
			1c. set required fields (owner, company, createdby, pi, parentProject)
			if company not found --> default to MCIT
			if createdBy not found --> default to Sys Admin
			if PI not found --> leave empty
		*/	

			if(draft != null){
				iacucQ.parentProject = draft;
				?'setting iacucQ.parentProject => '+iacucQ.parentProject+'\n';
			}

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
				var parentSubmission_1 = parentSubmission.elements().item(1);
				iacucQ.setQualifiedAttribute("customAttributes.parentProtocol", parentSubmission_1);
			}
			?'parentProtocol =>'+iacucQ.customAttributes.parentProtocol+'\n';

			var draftProtocol = iacucQ.getQualifiedAttribute("customAttributes.draftProtocol");
			if(draftProtocol == null && parentSubmission.count() > 0){
				var parentSubmission_1 = parentSubmission.elements().item(1);
				if(parentSubmission_1.customAttributes.draftProtocol){
					var parentDraft = parentSubmission_1.customAttributes.draftProtocol;
						iacucQ.setQualifiedAttribute("customAttributes.draftProtocol", parentDraft);
				}
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
			var createProtocolActivity;

			if(submissionTypeName != null){
				if(submissionTypeName == "New Protocol Application"){
					if(status == "Approved"){
						whichTemplate = "TMPL8D07C62360C5A80";
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
			var putName = "{{breaklines name}}";
			var shortenedPutName = putName.slice(0,255);
			iacucQ.name = shortenedPutName;
			?'setting iacucQ name =>'+iacucQ.name+'\n';
			{{#if studyDetails.longTitle}}
				iacucQ.customAttributes.fullTitle = "{{studyDetails.longTitle}}";
				?'setting iacucQ.customAttributes.fullTitle =>'+iacucQ.customAttributes.fullTitle+'\n';
				iacucQ.customAttributes.fullTitle_text = "{{studyDetails.longTitle}}";
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
			2b. create guest list 
		*/
			var person = Person.createEntitySet();
			iacucQ.setQualifiedAttribute("customAttributes.guestList", person );
			?'guestList set created=>'+iacucQ.customAttributes.guestList+'\n';

		/*
			2c. create readers/editors
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
			2e. create active amendment set or add to active amendment set
		*/

		var submissionTypeName = iacucQ.customAttributes.typeOfSubmission.customAttributes.name;
		var currentStatus = iacucQ.status.ID;
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
					if(currentStatus != "Approved" && currentStatus != "Lapsed"){
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
						?'Dont Add to parent active amend set\n';
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

			var amendmentAdd = iacucQ.customAttributes.amendment;
			if(amendmentAdd == null){
				var putName = "{{breaklines name}}";
				var shortenedPutName = putName.slice(0,255);
				iacucQ.customAttributes.amendment = _ClickAmendment.createEntity();
				?'create amendent to include changes details for amendment => '+iacucQ.customAttributes.amendment+'\n';
				iacucQ.customAttributes.amendment.setQualifiedAttribute("customAttributes.summaryOfChanges", shortenedPutName);
				?'iacucQ.summaryOfChanges => '+iacucQ.customAttributes.amendment.customAttributes.summaryOfChanges+'\n';
				iacucQ.customAttributes.amendment.setQualifiedAttribute("customAttributes.rationale", shortenedPutName);
				?'iacucQ.summaryOfChanges => '+iacucQ.customAttributes.amendment.customAttributes.rationale+'\n';
				iacucQ.customAttributes.amendment.customAttributes.type = _ClickAmendmentType.createEntitySet();
				?'iacucQ.summaryOfChanges => '+iacucQ.customAttributes.amendment.customAttributes.type+'\n';
			}
		}
		if(submissionTypeName == "Annual Review"){
			var parent = iacucQ.customAttributes.parentProtocol;
			if(parent != null){
				var annualreview = parent.customAttributes.activeAnnualReview;
				if(currentStatus != "Approved" && currentStatus != "Lapsed"){
					parent.customAttributes.activeAnnualReview = iacucQ;
					?'adding annual review to parent activeANnualReview => '+iacucQ+'\n';
				}
				else{
					?'Not adding annual review to activeAnnualReview because status is approved or lapsed\n';
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
			2f. setting approvalDate/annualExpirationDate
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

		/*
			2g. set inbox status
		*/
		var statusID = iacucQ.status.ID;
		iacucQ.setQualifiedAttribute("globalAttributes.clickProjectStatusAsString",statusID);
		?'setting inbox study status id => '+iacucQ.globalAttributes.clickProjectStatusAsString+'\n';

		/*
			2h. add logging activity for amends/renewals
		*/

		var submissionTypeName = iacucQ.customAttributes.typeOfSubmission.customAttributes.name;
		var logActivity;
		if(submissionTypeName == "Triennial Review"){
	        var createTriennialReviewActivity = ActivityType.getActivityType("_ClickIACUCSubmission_CreateTriennialReview", "_ClickIACUCSubmission");
	        if(createTriennialReviewActivity == null) {
	            ?"Create Triennial Review activity not found\n";
	        }
	        else{
	        	iacucQ.logActivity(sch, createTriennialReviewActivity, Person.getCurrentUser());
	        }
		}
		else if(submissionTypeName == "Annual Review"){
	        var createAnnualReviewActivity = ActivityType.getActivityType("_ClickIACUCSubmission_CreateAnnualReview", "_ClickIACUCSubmission");
	        if(createAnnualReviewActivity == null) {
	            ?"Create Annual Review activity not found\n";
	        }
	        else{
	        	iacucQ.logActivity(sch, createAnnualReviewActivity, Person.getCurrentUser());
	        }
		}
		else if(submissionTypeName == "Amendment"){
			var createAmendmentActivity = ActivityType.getActivityType("_ClickIACUCSubmission_CreateAmendment", "_ClickIACUCSubmission");
	        if(createAmendmentActivity == null) {
	           ?"Create amendment activity not found\n";
	        }
	        else{
	        	iacucQ.logActivity(sch, createAmendmentActivity, Person.getCurrentUser());
	        }
		}
		else{
			?'Not Renewal or amendment => dont log anything\n';
		}

		if(submissionTypeName == "Amendment"){
			var readers = iacucQ.customAttributes.readers;
			var editors = iacucQ.customAttributes.editors;
			var studyTeamMember = iacucQ.customAttributes.studyTeamMembers;
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

			var draft = iacucQ.customAttributes.draftProtocol;
			var readers = iacucQ.customAttributes.readers;
			var draftReaders = draft.customAttributes.readers;
			var editors = iacucQ.customAttributes.editors;
			var draftEditors = draft.customAttributes.editors;
			var studyTeamMember = iacucQ.customAttributes.studyTeamMembers;
			var draftStudyTeam = draft.customAttributes.studyTeamMembers;

			if(draftStudyTeam != null){
				draftStudyTeam.removeAllElements();
				draftStudyTeam = draft.customAttributes.studyTeamMembers; 
			}

			if(draftReaders != null){
				draftReaders.removeAllElements();
				draftReaders = draft.customAttributes.readers; 
			}
			
			if(draftEditors != null){
				draftEditors.removeAllElements();
				draftEditors = draft.customAttributes.editors; 
			}
			
			
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

			var investigator = iacucQ.getQualifiedAttribute("customAttributes.investigator");
			if(investigator != null){
				var invest = EntityCloner.quickClone(investigator);
				draft.setQualifiedAttribute("customAttributes.investigator", invest);
				?'adding Invest to draft investigator => '+invest+'\n';				
			}

			var draft = iacucQ.customAttributes.draftProtocol;
			if(draft){
				draft.setQualifiedAttribute("customAttributes.amendmentForDraft",iacucQ);
			}

		}

		var draft = iacucQ.customAttributes.draftProtocol;
		var draftName = draft.name;
		if(draftName == null){
			var newName = iacucQ.name;
			draft.name = newName;
			?'setting draft.name => '+draft.name+'\n';
			draft.customAttributes.fullTitle_text = newName;
			?'setting draft.fullTitle_text => '+draft.customAttributes.fullTitle_text+'\n';
		}


		var draftAdminOffice = draft.customAttributes.adminOffice;
		if(draftAdminOffice == null){
			var adminOffice = entityUtils.getObjectFromString('com.webridge.entity.Entity[OID[455A658DB0BA7D498CB6DF34E2CA25EA]]');
			draft.setQualifiedAttribute('customAttributes.adminOffice', adminOffice);
			?'setting admin office for draft study => '+adminOffice+'\n';
		}

		var draftCompany = draft.company;
		if(draftCompany == null){
			var mainCompany = iacucQ.company;
			draft.company = mainCompany;
		}

		var draftCreatedBy = draft.createdBy;
		if(draftCreatedBy == null){
			var mainCreatedBy = iacucQ.createdBy;
			draft.createdBy = mainCreatedBy;			
		}

		var draftProtocolNumber = draft.customAttributes.protocolNumber;
		var newProtocolNumber = iacucQ.customAttributes.protocolNumber;
		draft.setQualifiedAttribute("customAttributes.protocolNumber", newProtocolNumber);			
		?'setting draftProtocolNumber =>'+draftProtocolNumber+'\n';


		/*
			3a. starting smart form based on submission type
		*/
		var startingSmartForm;
		var submissionTypeName = iacucQ.customAttributes.typeOfSubmission.customAttributes.name;
		if(submissionTypeName == "Amendment"){
			//Amendment Summary: ApplicationEntity.getResultSet('WizardPage').query("name='Amendment Summary'")
			startingSmartForm = entityUtils.getObjectFromString('com.webridge.entity.Entity[OID[9044B1F5DD68904DA1A8F354092EA281]]');
			?'starting smartform for amendments => '+startingSmartForm.name+'\n';
		}
		if(submissionTypeName == "Annual Review"){
			//Annual Review Introduction: ApplicationEntity.getResultSet('WizardPage').query("name='Annual Review Introduction'")
			startingSmartForm = entityUtils.getObjectFromString('com.webridge.entity.Entity[OID[BF87D119D3493A458BAF11C039E7249C]]');
			?'starting smartform for annual review => '+startingSmartForm.name+'\n';
		}
		if(startingSmartForm){
			iacucQ.currentSmartFormStartingStep  = startingSmartForm;
			?'setting amendment or annual review starting smartform => '+startingSmartForm+'\n';
		}
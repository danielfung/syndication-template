{{#if _uid}}
	var iacuc_id = "{{this._uid}}";
	//iacuc_id = iacuc_id.split('-')[1];
	//var currentYear = new Date().getFullYear();
	//iacuc_id = 'PROTO'+currentYear+iacuc_id;
	iacuc_id = "IA"+iacuc_id;
{{else}}
	var iacuc_id ="{{this.id}}";
{{/if}}
?'IACUC ID =>'+iacuc_id+'\n';

var iacuc;
var iacucQ = ApplicationEntity.getResultSet('_ClickIACUCSubmission').query("ID='"+iacuc_id+"'");
?'iacucQ.count() =>'+iacucQ.count()+'\n';

{{#if topaz.draftProtocol}}
/*
	DRAFT PROTOCOL IN JSON
*/
var draft = ApplicationEntity.getResultSet('_ClickIACUCSubmission').query("ID='{{topaz.draftProtocol.id}}'");

if(draft.count() > 0)
{
	draft = draft.elements().item(1);
	{{#if topaz.submissionType.oid}}
	{{#if topaz.protocolType.oid}}
	/*
		1. Create iacuc Submission if it doesn't exist.
	*/
	if(iacucQ.count() == 0){
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
			var putName = "{{name}}";
			iacucQ.name = putName;
			?'setting iacucQ name =>'+iacucQ.name+'\n';
			{{#if studyDetails.longTitle}}
				iacucQ.customAttributes.fullTitle = "{{studyDetails.longTitle}}";
				?'setting iacucQ.customAttributes.fullTitle =>'+iacucQ.customAttributes.fullTitle+'\n';
				iacucQ.customAttributes.fullTitle_text = "{{studyDetails.longTitle}}";
				?'setting iacucQ.customAttributes.fullTitle_text=>'+iacucQ.customAttributes.fullTitle_text+'\n';
			{{else}}
				iacucQ.customAttributes.fullTitle = "{{name}}";
				?'default setting to name: iacucQ.customAttributes.fullTitle =>'+iacucQ.customAttributes.fullTitle+'\n';
				iacucQ.customAttributes.fullTitle_text = "{{name}}";
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
			2e. create active amendment set
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
			2f. setting approvalDate/finalExpirationDate
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
				iacucQ.customAttributes.finalExpirationDate = a;
				?'setting finalExpirationDate => '+iacucQ.customAttributes.finalExpirationDate+'\n';

			{{/if}}

	}
	else{
		iacucQ = iacucQ.elements().item(1);
		?'iacucQ submission found =>'+iacucQ.ID+'\n';

		var parent = ApplicationEntity.getResultSet('_ClickIACUCSubmission').query("ID='{{topaz.draftProtocol.id}}'");

		if(parent.count() > 0){
			parent = parent.elements().item(1);
			iacucQ.parentProject = parent;
			?'setting iacucQ.parentProject => '+iacucQ.parentProject+'\n';
		}

		{{#if topaz.projectStatus}}
				var status = iacucQ.status;
				if(status == null){
					var statusOID = entityUtils.getObjectFromString('{{topaz.projectStatus.oid}}');
					iacucQ.status = statusOID;
					?'iacucQ.status =>'+statusOID+'\n';
				}
		{{/if}}

		{{#if topaz.principalInvestigator}}
				//update PI field
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
						iacucQ.company = department;
						?'iacucQ.company =>'+department+'\n';
					}
				}
		{{/if}}

		{{#if topaz.protocolType}}
				//updating protocolType
	        	var protocolType = entityUtils.getObjectFromString('{{topaz.protocolType.oid}}');
	        	iacucQ.setQualifiedAttribute("customAttributes.typeOfProtocol", protocolType);
	        	?'setting ProtocolType =>'+protocolType+'\n';
	    {{/if}}

	    {{#if topaz.submissionType}}
	    		//updating submissionType
				var submissionType = entityUtils.getObjectFromString('{{topaz.submissionType.oid}}');
				iacucQ.setQualifiedAttribute("customAttributes.typeOfSubmission", submissionType);
		        ?'setting iacucQ.customAttributes.typeOfSubmission =>'+submissionType+'\n';
	    {{/if}}

		{{#if topaz.protocolNumber}}
				var protocolNumber = '{{topaz.protocolNumber}}';
				iacucQ.setQualifiedAttribute("customAttributes.protocolNumber", protocolNumber);
				?'updating iacucQ.protocolNumber => '+protocolNumber+'\n';
				if(draftProtocol != null){
					draftProtocol.customAttributes.protocolNumber = protocolNumber;
					?'updating draftProtocol.protocolNumber => '+protocolNumber+'\n';
				}
		{{/if}}

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
			iacucQ.customAttributes.finalExpirationDate = a;
			?'setting finalExpirationDate => '+iacucQ.customAttributes.finalExpirationDate+'\n';

		{{/if}}
	}

	{{/if}}
	{{/if}}
}
else{
	?'ERROR: Draft Protocol Not Found =>{{topaz.draftProtocol.id}}\n';
	?'IACUC ID =>{{id}}\n';
	?'SubmissionType =>{{topaz.submissionType.oid}}\n';
	?'ProtocolType =>{{topaz.protocolType.oid}}\n';
}

{{else}}
{{#if topaz.submissionType.oid}}
{{#if topaz.protocolType.oid}}
/*
	NO DRAFT PROTOCOL IN JSON
*/
	/*
		1. Create iacuc Submission if it doesn't exist.
	*/
	if(iacucQ.count() == 0){
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
					var department = person.customAttributes;
					if(department != null){
						department = person.customAttributes.department;
						if(department != null){
							iacucQ.company = department;
							?'iacucQ.company =>'+department+'\n';
						}
					}
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
			iacucQ.name = "{{name}}";
			?'setting iacucQ name =>'+iacucQ.name+'\n';
			{{#if studyDetails.longTitle}}
				iacucQ.customAttributes.fullTitle = "{{studyDetails.longTitle}}";
				?'setting iacucQ.customAttributes.fullTitle =>'+iacucQ.customAttributes.fullTitle+'\n';
				iacucQ.customAttributes.fullTitle_text = "{{studyDetails.longTitle}}";
				?'setting iacucQ.customAttributes.fullTitle_text=>'+iacucQ.customAttributes.fullTitle_text+'\n';
			{{else}}
				iacucQ.customAttributes.fullTitle = "{{name}}";
				?'default setting to name: iacucQ.customAttributes.fullTitle =>'+iacucQ.customAttributes.fullTitle+'\n';
				iacucQ.customAttributes.fullTitle_text = "{{name}}";
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


			/*
				2i. setting approvalDate/finalExpirationDate on original
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
				iacucQ.customAttributes.finalExpirationDate = a;
				?'setting finalExpirationDate => '+iacucQ.customAttributes.finalExpirationDate+'\n';

			{{/if}}

			/*
				2j. Create DRAFT Protocol
			*/

			var newClone = wom.createTransientEntity('_ClickIACUCSubmission');
			?'created Draft Protocol => '+newClone+'\n';
			newClone.ID = _ClickIACUCSubmission.getID("_ClickIACUCSubmission");
			?'draft ID => '+newClone.ID+'\n';
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
					?'setting approvalDate => '+newClone.customAttributes.approvalDate+'\n';
				{{/if}}

				{{#if topaz.expirationDate}}
					var date = "{{topaz.expirationDate}}";
					var dateArray = date.split('-');
					var day = dateArray[2].substring(0,2);
					var month = dateArray[1] - 1;
					var year = dateArray[0];
					var a = new Date(year, month, day);
					newClone.customAttributes.finalExpirationDate = a;
					?'setting finalExpirationDate => '+newClone.customAttributes.finalExpirationDate+'\n';

				{{/if}}
			}

	}
	else{
		iacucQ = iacucQ.elements().item(1);
		?'iacucQ submission found =>'+iacucQ.ID+'\n';
		var draftProtocol = iacucQ.customAttributes.draftProtocol;
		{{#if topaz.principalInvestigator}}
				//update PI field
				var investigator = iacucQ.getQualifiedAttribute("customAttributes.investigator");

				var person = ApplicationEntity.getResultSet("Person").query("userID = '{{topaz.principalInvestigator}}'").elements();
				
				var reader = iacucQ.customAttributes.readers;
				var editor = iacucQ.customAttributes.editors;
				var draft = iacucQ.customAttributes.draftProtocol;
				var draftReader;
				var draftEditor;
				if(draft != null){
					draftReader = draft.customAttributes.readers;
					draftEditor = draft.customAttributes.editors;
				}

				?'Main protcol readers eset => '+reader+'\n';
				?'Main protcol editors eset => '+editor+'\n';
				?'Draft protcol readers eset => '+draftReader+'\n';
				?'Draft protcol editors eset => '+draftEditor+'\n';


				if(investigator == null && person.count() > 0){
					var studyTeamMember = _StudyTeamMemberInfo.createEntity();
					?'_StudyTeamMemberInfo =>'+studyTeamMember+'\n';
					iacucQ.setQualifiedAttribute("customAttributes.investigator", studyTeamMember);
					person = person.item(1);
					?'person adding as PI =>'+person+'\n';
					studyTeamMember.setQualifiedAttribute("customAttributes.studyTeamMember", person);
					if(reader != null){
						reader.addElement(person);
						?'adding pi to readers list\n';
					}
					if(editor != null){
						editor.addElement(person);
						?'adding pi to editor list\n';
					}
					if(draftReader != null){
						draftReader.addElement(person);
						?'adding pi to draftReader list\n';
					}
					if(draftEditor != null){
						draftEditor.addElement(person);
						?'adding pi to draftEditor list\n';
					}
					var department = person.customAttributes;
					if(department != null){
						department = person.customAttributes.department;
						iacucQ.company = department;
						?'iacucQ.company =>'+department+'\n';
					}
				}
		{{/if}}

		{{#if topaz.protocolType}}
				//updating protocolType
	        	var protocolType = entityUtils.getObjectFromString('{{topaz.protocolType.oid}}');
	        	iacucQ.setQualifiedAttribute("customAttributes.typeOfProtocol", protocolType);
	        	?'updating ProtocolType =>'+protocolType+'\n';
	        	if(draftProtocol != null){
					draftProtocol.customAttributes.typeOfProtocol = protocolType;
					?'updating draftProtocol.ProtocolType => '+protocolType+'\n';
				}
	    {{/if}}

	    {{#if topaz.submissionType}}
	    		//updating submissionType
				var submissionType = entityUtils.getObjectFromString('{{topaz.submissionType.oid}}');
				iacucQ.setQualifiedAttribute("customAttributes.typeOfSubmission", submissionType);
		        ?'updating iacucQ.customAttributes.typeOfSubmission =>'+submissionType+'\n';
	    {{/if}}

		{{#if topaz.projectStatus}}
			var status = iacucQ.status;
			var statusOID = entityUtils.getObjectFromString('{{topaz.projectStatus.oid}}');
			iacucQ.status = statusOID;
			?'updating iacucQ.status =>'+statusOID+'\n';
		{{/if}}

		{{#if topaz.protocolNumber}}
				var protocolNumber = '{{topaz.protocolNumber}}';
				iacucQ.setQualifiedAttribute("customAttributes.protocolNumber", protocolNumber);
				?'updating iacucQ.protocolNumber => '+protocolNumber+'\n';
				if(draftProtocol != null){
					draftProtocol.customAttributes.protocolNumber = protocolNumber;
					?'updating draftProtocol.protocolNumber => '+protocolNumber+'\n';
				}
		{{/if}}

		var draftStudyTeamMember = draft.customAttributes.studyTeamMembers;
		var draftReaders = draft.customAttributes.readers;
		var draftEditors = draft.customAttributes.editors;
		var parentReaders = iacucQ.customAttributes.readers;
		var parentEditors = iacucQ.customAttributes.editors;
		var parentStudyTeamMember = iacucQ.customAttributes.studyTeamMembers;

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
					parentReaders.addElement(person);
					?'added associates to parent readers set => '+parentReaders+'\n';
					if(draftReaders != null){
						draftReaders.addElement(person);
					}
					?'added associates to draft readers set => '+draftReaders+'\n';
					parentEditors.addElement(person);
					?'added associates to parent editors set => '+parentEditors+'\n';
					if(draftEditors != null){
						draftEditors.addElement(person);
						?'added associates to draft editors set => '+draftEditors+'\n';
					}
					var studyTeamMemInfo = _StudyTeamMemberInfo.createEntity();
					?'created studyTeamMemInfo => '+studyTeamMemInfo+'\n';
					studyTeamMemInfo.setQualifiedAttribute("customAttributes.studyTeamMember", person);
					?'adding person to studyTeamMemInfo => '+person+'\n';
					studyTeamMemInfo.customAttributes.canEditProtocol = canEdit;
					?'Can Edit Protocol => True\n';
					parentStudyTeamMember.addElement(studyTeamMemInfo);
					?'added associates to study team mem info set => '+parentStudyTeamMember+'\n';
					if(draftStudyTeamMember != null){
						var studyTeamMem_1 = EntityCloner.quickClone(studyTeamMemInfo);
						draftStudyTeamMember.addElement(studyTeamMem_1);
						?'added associates to draft study team member info set => '+draftStudyTeamMember+'\n';
					}
				}
				else if(exists.count() > 0){
					?'Person already exists => '+studyTeamMem+'\n';
				}
					else{
					?'Person not found by kerboros id => '+studyTeamMem+'\n';
				}
			}
		{{/if}}

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
					parentReaders.addElement(person);
					?'added teamSubInvestigators to parent readers set => '+parentReaders+'\n';
					if(draftReaders != null){
						draftReaders.addElement(person);
						?'added teamSubInvestigators to draft readers set => '+draftReaders+'\n';
					}
					parentEditors.addElement(person);
					if(draftEditors != null){
						?'added teamSubInvestigators to parent editors set => '+parentEditors+'\n';
						draftEditors.addElement(person);
					}
					?'added teamSubInvestigators to draft editors set => '+draftEditors+'\n';
					var studyTeamMemInfo = _StudyTeamMemberInfo.createEntity();
					?'created studyTeamMemInfo => '+studyTeamMemInfo+'\n';
					studyTeamMemInfo.setQualifiedAttribute("customAttributes.studyTeamMember", person);
					?'adding person to studyTeamMemInfo => '+person+'\n';
					studyTeamMemInfo.customAttributes.canEditProtocol = canEdit;
					?'Can Edit Protocol => True\n';
					parentStudyTeamMember.addElement(studyTeamMemInfo);
					?'added teamSubInvestigators to study team mem info set => '+parentStudyTeamMember+'\n';
					if(draftStudyTeamMember != null){
						var studyTeamMem_1 = EntityCloner.quickClone(studyTeamMemInfo);
						draftStudyTeamMember.addElement(studyTeamMem_1);
						?'added associates to draft study team member info set => '+draftStudyTeamMember+'\n';
					}
				}
				else if(exists.count() > 0){
					?'Person already exists => '+studyTeamMem+'\n';
				}
				else{
					?'Person not found by kerboros id => '+studyTeamMem+'\n';
				}
			}
		{{/if}}

	    {{#if topaz.approvalDate}}
			var date = "{{topaz.approvalDate}}";
			var dateArray = date.split('-');
			var day = dateArray[2].substring(0,2);
			var month = dateArray[1] - 1;
			var year = dateArray[0];
			var a = new Date(year, month, day);
			draftProtocol.customAttributes.approvalDate = a;
			?'setting draft approvalDate => '+draftProtocol.customAttributes.approvalDate+'\n';
			iacucQ.customAttributes.approvalDate = a;
			?'setting orig approvalDate => '+iacucQ.customAttributes.approvalDate+'\n';
		{{/if}}

		{{#if topaz.expirationDate}}
			var date = "{{topaz.expirationDate}}";
			var dateArray = date.split('-');
			var day = dateArray[2].substring(0,2);
			var month = dateArray[1] - 1;
			var year = dateArray[0];
			var a = new Date(year, month, day);
			draftProtocol.customAttributes.finalExpirationDate = a;
			?'setting draft finalExpirationDate => '+draftProtocol.customAttributes.finalExpirationDate+'\n';
			iacucQ.customAttributes.finalExpirationDate = a;
			?'setting orig finalExpirationDate => '+iacucQ.customAttributes.finalExpirationDate+'\n';
		{{/if}}


	}

	{{/if}}
	{{/if}}
{{/if}}

{{#if studyDetails}}
{{#if studyDetails.iacucProtocol}}
if(iacucQ.count() == 0){
	var subjectType = "{{studyDetails.subjectType.name}}";
	if(subjectType == "Animal"){
		var status = "{{status}}";
		if(status == "Submitted"){
			var iacucStudy = '{{studyDetails.iacucProtocol}}';
			var iacucStudyExist = ApplicationEntity.getResultSet('_ClickIACUCSubmission').query("ID='"+iacucStudy+"'");
			if(iacucStudyExist.count() > 0){
				iacucStudyExist = iacucStudyExist.elements().item(1);
				?'IACUC Study(Exist) Found =>'+iacucStudyExist+'\n';
				var name = '{{name}}';
				var id = iacuc_id;
				var date = new Date();
				var activity = _ClickIACUCSubmission_CopySubmission.createEntity();
				?'_ClickIACUCSubmission_CopySubmission created =>'+activity+'\n';
				activity.setQualifiedAttribute('customAttributes.newStudyName', name);
				?'activity set newStudyName =>'+activity.customAttributes.newStudyName+'\n';
				activity.setQualifiedAttribute('customAttributes.newStudyID', id);
				?'activity set newstudyID =>'+activity.customAttributes.newStudyID+'\n';
				activity.dateCreated = date;
				?'activity set dateCreated =>'+activity.dateCreated+'\n';
				activity.dateModified = date;
				?'activity.dateModified =>'+activity.dateModified+'\n';
				activity.loggedFor = iacucStudyExist;
				?'activity.loggedFor =>'+activity.loggedFor+'\n';
				activity.notesAsStr = "Copy in progress...Refresh the new page and repeat until copy completes.";
				?'activity.notesAsStr =>'+activity.notesAsStr+'\n';

				var thisRequest = EntityCloner.createRequest(activity, iacucStudyExist, "Copied submission.");
				?'create request =>'+thisRequest+'\n';
				if (thisRequest==null) {
		        	?"The clone request could not be created.\n";
		    	}
		    	else{
		    		thisRequest.startRequest();
		    		?'starting copy\n';
		    	}
			}
			else{
				?'IACUC Protocol To Copy From Does Not Exist =>{{studyDetails.iacucProtocol}}\n';
				?'RN Study ID =>{{id}}\n';
				?'RN Current Status =>{{status}}\n';
			}
		}
		else{
			?'Error: Status is not submitted\n';
			?'RN Study ID =>{{id}}\n';
			?'current status =>{{status}}\n';
		}
	}
	else{
		?'Error: subjectType is not animal, not for IACUC\n';
		?'RN Study ID =>{{id}}\n';
	}
}
else{
	?'IACUC Protocol Already Exists =>'+iacuc_id+'\n';
	?'iacuc =>'+iacucQ.elements().item(1)+'\n';
}

{{else}}
var subjectType = "{{studyDetails.subjectType.name}}";
if(subjectType == "Animal"){
	var status = "{{status}}";
	if(status == "Submitted"){
	/*
		1. Create iacuc Submission if it doesn't exist.
	*/
	if(iacucQ.count() == 0){
		iacucQ = wom.createTransientEntity('_ClickIACUCSubmission');
		?'iacucQ =>'+iacucQ+'\n';

		/*
			1a. update ID of iacuc Submission
		*/

			iacucQ.ID = iacuc_id;
			?'iacucQ.ID =>'+iacucQ.ID+'\n';

		/*
			1b. Register/initalize iacuc Submission, add Project eset
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
					studyTeamMember.setQualifiedAttribute("customAttributes.studyTeamMember", person);
					var department = person.customAttributes;
					if(department != null){
						department = person.customAttributes.department;
						if(department != null){
							if(department.name == "Medicine" || department.name == "Population Health"){
								var division = person.customAttributes.division;
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
			1g. set irb status to pre-submission
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
			iacucQ.name = "{{name}}";
			?'setting iacucQ name =>'+iacucQ.name+'\n';
			{{#if studyDetails.longTitle}}
				iacucQ.customAttributes.fullTitle = "{{studyDetails.longTitle}}";
				?'setting iacucQ.customAttributes.fullTitle =>'+iacucQ.customAttributes.fullTitle+'\n';
				iacucQ.customAttributes.fullTitle_text = "{{studyDetails.longTitle}}";
				?'setting iacucQ.customAttributes.fullTitle_text=>'+iacucQ.customAttributes.fullTitle_text+'\n';
			{{else}}
				iacucQ.customAttributes.fullTitle = "{{name}}";
				?'default setting to name: iacucQ.customAttributes.fullTitle =>'+iacucQ.customAttributes.fullTitle+'\n';
				iacucQ.customAttributes.fullTitle_text = "{{name}}";
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

	}
	else{
		iacucQ = iacucQ.elements().item(1);
		?'iacucQ submission found =>'+iacucQ.ID+'\n';
	}
	}
	else{
		?'Error: Status is not submitted\n';
		?'RN Study ID =>{{id}}\n';
		?'current status =>{{status}}\n';
	}
}
else{
	?'Error: subjectType is not animal, not for IACUC\n';
	?'RN Study ID =>{{id}}\n';
}
{{/if}}
{{/if}}
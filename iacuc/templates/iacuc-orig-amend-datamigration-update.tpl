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

	    {{#if topaz.draftProtocol}}
	    	var parentSubmission = ApplicationEntity.getResultSet('_ClickIACUCSubmission').query("ID='{{topaz.draftProtocol.id}}'");
			if(parentSubmission.count() > 0){
				var parentSubmission_1 = parentSubmission.elements().item(1);
				iacucQ.setQualifiedAttribute("customAttributes.parentProtocol", parentSubmission_1);
			}
			?'parentProtocol =>'+iacucQ.customAttributes.parentProtocol+'\n';

			if(parentSubmission.count() > 0){
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

		{{#if topaz.principalInvestigator}}
				//update PI field
				var person = ApplicationEntity.getResultSet("Person").query("userID = '{{topaz.principalInvestigator}}'").elements();
				
				if(person.count() > 0){
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
			set inbox status
		*/
		var statusID = iacucQ.status.ID;
		iacucQ.setQualifiedAttribute("globalAttributes.clickProjectStatusAsString",statusID);
		?'setting inbox study status id => '+iacucQ.globalAttributes.clickProjectStatusAsString+'\n';

		var parent = iacucQ.customAttributes.parentProtocol;
		var parentAmend = parent.customAttributes.amendment;
		var parentAmendSet;

		var submissionTypeName = iacucQ.customAttributes.typeOfSubmission.customAttributes.name;
		var currentStatus = iacucQ.status.ID;

		if(parentAmend == null){
			var amend = _ClickAmendment.createEntity();
			iacucQ.customAttributes.parentProtocol.setQualifiedAttribute('customAttributes.amendment', amend);
			?'setting parent amendment => '+amend+'\n';
			var activeAmendSet = ApplicationEntity.createEntitySet('_ClickActiveAmendment');
			iacucQ.customAttributes.parentProtocol.customAttributes.amendment.setQualifiedAttribute("customAttributes.activeAmendments" , activeAmendSet);
			?'set activeAmendSet =>'+iacucQ.customAttributes.amendment.customAttributes.activeAmendments+'\n';
			parentAmendSet = iacucQ.customAttributes.parentProtocol.customAttributes.amendment.customAttributes.activeAmendments;
		}
		else{
			parentAmendSet = parentAmend.customAttributes.activeAmendments;
			if(parentAmendSet == null){
				iacucQ.customAttributes.parentProtocol.customAttributes.amendment.setQualifiedAttribute("customAttributes.activeAmendments" , activeAmendSet);
				?'set activeAmendSet =>'+iacucQ.customAttributes.amendment.customAttributes.activeAmendments+'\n';
				parentAmendSet = iacucQ.customAttributes.parentProtocol.customAttributes.amendment.customAttributes.activeAmendments;				
			}
		}

		if(parent != null){
			if(submissionTypeName == "Annual Review"){
				var annualreview = parent.customAttributes.activeAnnualReview;
				if(currentStatus != "Approved" && currentStatus != "Lapsed"){
					parent.customAttributes.activeAnnualReview = iacucQ;
					?'adding annual review to parent activeANnualReview => '+iacucQ+'\n';
				}
				else{
					?'Not adding annual review to activeAnnualReview because status is approved or lapsed\n';
				}
			}
			if(submissionTypeName == "Amendment"){
				if(currentStatus != "Approved" && currentStatus != "Lapsed"){
					if(parentAmendSet){
						var activeAmend = _ClickActiveAmendment.createEntity();
						?'iacucQ create _ClickActiveAmendment => '+activeAmend+'\n';
						activeAmend.setQualifiedAttribute('customAttributes.activeAmendment', iacucQ);
						?'assign active amendment => '+iacucQ+'\n';
						parentAmendSet.addElement(activeAmend);
						?'add activeAmendment to set => '+parentAmendSet+'\n';
					}
				}
				else{
					?'Dont Add to parent active amend set\n';
				}			
			}
		}
		else{
			?'ERROR => parent not found for submission => '+iacucQ.ID+'\n';
		}
		if(submissionTypeName == "Amendment"){
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
			else{
				var putName = "{{breaklines name}}";
				var shortenedPutName = putName.slice(0,255);
				iacucQ.customAttributes.amendment.setQualifiedAttribute("customAttributes.summaryOfChanges", shortenedPutName);
				?'iacucQ.summaryOfChanges => '+iacucQ.customAttributes.amendment.customAttributes.summaryOfChanges+'\n';
				iacucQ.customAttributes.amendment.setQualifiedAttribute("customAttributes.rationale", shortenedPutName);
				?'iacucQ.summaryOfChanges => '+iacucQ.customAttributes.amendment.customAttributes.rationale+'\n';		
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

		/*
			3a. starting smart form based on submission type
		*/
		var startingSmartForm;
		var submissionTypeName = iacucQ.customAttributes.typeOfSubmission.customAttributes.name;
		if(submissionTypeName == "Amendment"){
			//amendment
			startingSmartForm = entityUtils.getObjectFromString('com.webridge.entity.Entity[OID[9044B1F5DD68904DA1A8F354092EA281]]');
			?'starting smartform for amendments => '+startingSmartForm.name+'\n';
		}
		if(submissionTypeName == "Annual Review"){
			//Annual Review Introduction
			startingSmartForm = entityUtils.getObjectFromString('com.webridge.entity.Entity[OID[BF87D119D3493A458BAF11C039E7249C]]');
			?'starting smartform for annual review => '+startingSmartForm.name+'\n';
		}
		if(startingSmartForm){
			iacucQ.currentSmartFormStartingStep  = startingSmartForm;
			?'setting amendment or annual review starting smartform => '+startingSmartForm+'\n';
		}

		/* Rebuild Template */
		iacucQ.resourceContainer = null;
		?'setting resource container to null\n';

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

			var dateMod = new Date();
			iacucQ.dateModified = dateMod;
			?'dateModifed => '+iacucQ.dateModified+'\n';

			var submissionTypeName = iacucQ.customAttributes.typeOfSubmission.customAttributes.name;
			if(submissionTypeName == "Amendment" || submissionTypeName == "Annual Review"){
				var draft = iacucQ.customAttributes.draftProtocol;
				var draftStudyTeamMember = draft.customAttributes.studyTeamMembers;
				var draftReaders = draft.customAttributes.readers;
				var draftEditors = draft.customAttributes.editors;
				var parentReaders = iacucQ.customAttributes.readers;
				var parentEditors = iacucQ.customAttributes.editors;
				var parentStudyTeamMember = iacucQ.customAttributes.studyTeamMembers;

						if(draftStudyTeamMember){
							//draftStudyTeamMember.removeAllElements();
							//?'removing all elements from draft study team member\n';
							draftStudyTeamMember = draft.customAttributes.studyTeamMembers;
						}

						if(draftReaders){
							//draftReaders.removeAllElements();
							//?'removing all elements from draft readers\n';
							draftReaders = draft.customAttributes.readers;
						}

						if(draftEditors){
							//draftEditors.removeAllElements();
							//?'removing all elements from draft editors\n';
							draftEditors = draft.customAttributes.editors;
						}

						if(parentReaders){
							//parentReaders.removeAllElements();
							//?'removing all elements from parent readers\n';
							parentReaders = iacucQ.customAttributes.readers;
						}

						if(parentEditors){
							//parentEditors.removeAllElements();
							//?'removing all elements from parent editors\n';
							parentEditors = iacucQ.customAttributes.editors;
						}
						if(parentStudyTeamMember){
							//parentStudyTeamMember.removeAllElements();
							//?'removing all elements from parent study team member\n';
							parentStudyTeamMember = iacucQ.customAttributes.studyTeamMembers;
						}

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
			}


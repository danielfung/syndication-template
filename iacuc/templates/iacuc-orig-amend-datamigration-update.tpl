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
				if(activeAnnualReview == null){
					var activeAnnualReviewSet = _ClickIACUCSubmission.createEntitySet();
					parent.customAttributes.activeAnnualReview = activeAnnualReviewSet;
					?'setting parent activeAnnualReviewSet => '+activeAnnualReviewSet+'\n';
					annualreview = parent.customAttributes.activeAnnualReview;
				}
				if(currentStatus != "Approved" && currentStatus != "Lapsed"){
					annualreview.addElement(iacucQ);
					?'adding annual review to parent activeANnualReview Set => '+annualreview+'\n';
				}
				else{
					?'Not adding annual review to activeAnnualReview Set because status is approved or lapsed\n';
				}
			}
			if(submissionTypeName == "Amendment"){
				if(currentStatus != "Approved" && currentStatus != "Lapsed"){
					if(parentAmendSet){
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
		}
		else{
			?'ERROR => parent not found for submission => '+iacucQ.ID+'\n';
		}
		if(submissionTypeName == "Amendment"){
			var amendmentAdd = iacucQ.customAttributes.amendment;
			if(amendmentAdd == null){
				iacucQ.customAttributes.amendment = _ClickAmendment.createEntity();
				?'create amendent to include changes details for amendment => '+iacucQ.customAttributes.amendment+'\n';
				iauccQ.customAttributes.amendment.setQualifiedAttribute("customAttributes.summaryOfChanges", "{{name}}");
				?'iacucQ.summaryOfChanges => '+iacucQ.customAttributes.amendment.customAttributes.summaryOfChanges+'\n';
				iacucQ.customAttributes.amendment.setQualifiedAttribute("customAttributes.rationale", "{{name}}");
				?'iacucQ.summaryOfChanges => '+iacucQ.customAttributes.amendment.customAttributes.rationale+'\n';
				iacucQ.customAttributes.amendment.customAttributes.type = _ClickAmendmentType.createEntitySet();
				?'iacucQ.summaryOfChanges => '+iacucQ.customAttributes.amendment.customAttributes.type+'\n';
			}
			else{
				iauccQ.customAttributes.amendment.setQualifiedAttribute("customAttributes.summaryOfChanges", "{{name}}");
				?'iacucQ.summaryOfChanges => '+iacucQ.customAttributes.amendment.customAttributes.summaryOfChanges+'\n';
				iacucQ.customAttributes.amendment.setQualifiedAttribute("customAttributes.rationale", "{{name}}");
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

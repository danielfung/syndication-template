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

		/*
			set inbox status
		*/
		var statusID = iacucQ.status.ID;
		iacucQ.setQualifiedAttribute("globalAttributes.clickProjectStatusAsString",statusID);
		?'setting inbox study status id => '+iacucQ.globalAttributes.clickProjectStatusAsString+'\n';
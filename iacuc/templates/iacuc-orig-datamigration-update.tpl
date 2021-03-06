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
				var contacts = iacucQ.contacts;
				if(contacts == null){
					iacucQ.contacts = Person.createEntitySet();
					?'created contacts set =>'+iacucQ.contacts+'\n';
				}
				contacts = iacucQ.contacts;

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
					if(contacts != null){
						contacts.addElement(person);
						?'adding person to contacts list\n';
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

		var draft = iacucQ.customAttributes.draftProtocol;
		var draftStudyTeamMember = draft.customAttributes.studyTeamMembers;
		var draftReaders = draft.customAttributes.readers;
		var draftEditors = draft.customAttributes.editors;
		var parentReaders = iacucQ.customAttributes.readers;
		var parentEditors = iacucQ.customAttributes.editors;
		var parentStudyTeamMember = iacucQ.customAttributes.studyTeamMembers;
		var parentContacts = iacucQ.contacts;

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
					parentContacts.addElement(person);
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
					parentContacts.addElement(person);
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
			draftProtocol.customAttributes.approvalDate = a;
			?'setting draft approval date => '+draftProtocol.customAttributes.approvalDate+'\n';
		{{/if}}

		{{#if topaz.expirationDate}}
			var date = "{{topaz.expirationDate}}";
			var dateArray = date.split('-');
			var day = dateArray[2].substring(0,2);
			var month = dateArray[1] - 1;
			var year = dateArray[0];
			var a = new Date(year, month, day);
			draftProtocol.customAttributes.annualExpirationDate = a;
			?'setting draft annualExpirationDate => '+draftProtocol.customAttributes.annualExpirationDate+'\n';
			iacucQ.customAttributes.annualExpirationDate = a;
			?'setting orig annualExpirationDate => '+iacucQ.customAttributes.annualExpirationDate+'\n';
		{{/if}}

		{{#if topaz.effectiveDate}}
			var date = "{{topaz.effectiveDate}}";
			var dateArray = date.split('-');
			var day = dateArray[2].substring(0,2);
			var month = dateArray[1] - 1;
			var year = dateArray[0];
			var a = new Date(year, month, day);
			iacucQ.customAttributes.effectiveDate = a;
			?'setting orig effectiveDate => '+iacucQ.customAttributes.effectiveDate+'\n';
			draftProtocol.customAttributes.effectiveDate = a;
			?'setting draft effectiveDate => '+draftProtocol.customAttributes.effectiveDate+'\n';
		{{/if}}

		{{#if topaz.annualExpirationDate}}
			var date = "{{topaz.annualExpirationDate}}";
			var dateArray = date.split('-');
			var day = dateArray[2].substring(0,2);
			var month = dateArray[1] - 1;
			var year = dateArray[0];
			var a = new Date(year, month, day);
			iacucQ.customAttributes.annualExpirationDate = a;
			?'setting orig annualExpirationDate => '+iacucQ.customAttributes.annualExpirationDate+'\n';
			draftProtocol.customAttributes.annualExpirationDate = a;
			?'setting draft annualExpirationDate => '+draftProtocol.customAttributes.annualExpirationDate+'\n';
		{{/if}}		

		var dateMod = new Date();
		iacucQ.dateModified = dateMod;
		?'dateModifed => '+iacucQ.dateModified+'\n';

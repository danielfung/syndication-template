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
			1c. set required fields (owner, company, createdby, pi)
			if company not found --> default to MCIT
			if createdBy not found --> default to Sys Admin
			if PI not found --> leave empty
		*/
			{{#if topaz.principalInvestigator.userId}}
				//topaz -> assigning PI to Study(IACUCQ)
				var investigator = iacucQ.getQualifiedAttribute("customAttributes.investigator");

				var person = ApplicationEntity.getResultSet("Person").query("userID = '{{topaz.principalInvestigator.userId}}'").elements();
				
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

			{{#if topaz.principalInvestigator.userId}}
				//createdby => topaz.pi
				var create = iacucQ.createdBy;
				if(create == null){
					var person = ApplicationEntity.getResultSet("Person").query("userID = '{{topaz.principalInvestigator.userId}}'");
					if(person.count() > 0){
						person = person.elements().item(1);
						iacucQ.createdBy = person;
						?'iacucQ.createdBy =>'+iacucQ.createdBy+'\n';
					}
					else{
						?'Person Not Found =>topaz.principalInvestigator.userId\n';
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
			?'readers set created=>'+iacucQ.customAttributes.readers+'\n';

		
		{{#if topaz.protocolNumber}}
			/*
				2d. add protocol number
			*/
				var protocolNumber = '{{topaz.protocolNumber.id}}';
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
	}
	else{
		iacucQ = iacucQ.elements().item(1);
		?'iacucQ submission found =>'+iacucQ.ID+'\n';

		{{#if topaz.principalInvestigator.userId}}
				//update PI field
				var investigator = iacucQ.getQualifiedAttribute("customAttributes.investigator");

				var person = ApplicationEntity.getResultSet("Person").query("userID = '{{topaz.principalInvestigator.userId}}'").elements();
				
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
			1c. set required fields (owner, company, createdby, pi)
			if company not found --> default to MCIT
			if createdBy not found --> default to Sys Admin
			if PI not found --> leave empty
		*/
			{{#if topaz.principalInvestigator.userId}}
				//topaz -> assigning PI to Study(IACUCQ)
				var investigator = iacucQ.getQualifiedAttribute("customAttributes.investigator");

				var person = ApplicationEntity.getResultSet("Person").query("userID = '{{topaz.principalInvestigator.userId}}'").elements();
				
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

			{{#if topaz.principalInvestigator.userId}}
				//createdby => topaz.pi
				var create = iacucQ.createdBy;
				if(create == null){
					var person = ApplicationEntity.getResultSet("Person").query("userID = '{{topaz.principalInvestigator.userId}}'");
					if(person.count() > 0){
						person = person.elements().item(1);
						iacucQ.createdBy = person;
						?'iacucQ.createdBy =>'+iacucQ.createdBy+'\n';
					}
					else{
						?'Person Not Found =>topaz.principalInvestigator.userId\n';
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
			?'readers set created=>'+iacucQ.customAttributes.readers+'\n';

		
		{{#if topaz.protocolNumber}}
			/*
				2d. add protocol number
			*/
				var protocolNumber = '{{topaz.protocolNumber.id}}';
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
	}
	else{
		iacucQ = iacucQ.elements().item(1);
		?'iacucQ submission found =>'+iacucQ.ID+'\n';

		{{#if topaz.principalInvestigator.userId}}
				//update PI field
				var investigator = iacucQ.getQualifiedAttribute("customAttributes.investigator");

				var person = ApplicationEntity.getResultSet("Person").query("userID = '{{topaz.principalInvestigator.userId}}'").elements();
				
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
	}

	{{/if}}
	{{/if}}
{{/if}}

{{#if studyDetails}}
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
				?'Person Not Found =>topaz.principalInvestigator.userId\n';
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
		?'readers set created=>'+iacucQ.customAttributes.readers+'\n';

	{{#if studyDetails}}
		/*
			2e. Add RNAV ID
		*/
			var rnavID = '{{id}}';
			iacucQ.setQualifiedAttribute("customAttributes.rnavID", rnavID);
			?'set rnavID =>'+rnavID+'\n';
	{{/if}}
}
else{
	iacucQ = iacucQ.elements().item(1);
	?'iacucQ submission found =>'+iacucQ.ID+'\n';
}
{{/if}}
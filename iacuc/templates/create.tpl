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
			2c. create readers/editors
		*/
			var person = Person.createEntitySet();
			iacucQ.setQualifiedAttribute("customAttributes.readers", person );
			?'readers set created=>'+iacucQ.customAttributes.readers+'\n';

			var person = Person.createEntitySet();
			iacucQ.setQualifiedAttribute("customAttributes.editors", person);
			?'editors set created => '+iacucQ.customAttributes.editors+'\n';
		
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
			1b. Register/initalize iacuc Submission and create project eset
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

		
		{{#if topaz.protocolNumber}}
			/*
				2d. add protocol number
			*/
				var protocolNumber = '{{topaz.protocolNumber.id}}';
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
			externalProtocolTeamInformation => ?(Set of Document)
			financialInterests => ?(Set of Document)
			financiallyInterested => Person --> created
			fundingSources => _ClickFundingSource --> created
			guestList => Person --> created
			guestListOrgs => Company --> created
			historicalReviewerNotes => ?(Set of ReviewerNote)
			lapses => _ClickLapse --> created
			longTermNonVivariumHousingLocations => _ClickNonVivariumHousingLocation --> created
			piProxiesPerson => Person --> created
			pendingDesignatedMemberReviewers => Person --> created
			procedurePersonnel => _ClickProcedureTeam --> created
			procedureTraining => _StudyTeamMemberInfo --> created
			studyTeamMembers => _StudyTeamMemberInfo --> created
			readers => Person --> created
			relatedSafetyProtocols => _ClickRelatedSafetyProtocol --> created
			setOfReviews => _review --> created
			snapshots => ?(Set of Document)
			supportDocuments => ?(Set of Document)
			suspensions => _ClickSuspension --> created
			tags => _ClickTag --> created
			usedAnimalCounts => _ClickUsedAnimalCounts --> created
			vivariumHousingLocations => _ClickNonVivariumHousingLocation --> created
		*/	
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
				?'setting animal disposition eset => '+animalDisposition+'\n';
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
				?'setting guest list organizations eset => '+acucQ.customAttributes.guestListOrgs+'\n';
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

			var pendDesMemmber = iacucQ.customAttributes.pendingDesignatedMemberReviewers;
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

			var setReview = iacucQ.customAttributes.setOfReviews;
			if(setReview == null){
				var a = ApplicationEntity.createEntitySet('_review');
				iacucQ.customAttributes.setOfReviews = a;
				?'setting set of reviews eset => '+iacucQ.customAttributes.setOfReviews+'\n';
			}

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
				?'setting used animal count eset => '+iacucQ>customAttributes.usedAnimalCounts+'\n';
			}

			var vivHousingLocation = iacucQ.customAttributes.vivariumHousingLocations;
			if(vivHousingLocation == null){
				var a = ApplicationEntity.createEntitySet('_ClickNonVivariumHousingLocation');
				iacucQ.customAttributes.vivariumHousingLocations = a;
				?'setting vivHousingLocation eset => '+iacucQ.customAttributes.vivariumHousingLocations+'\n';
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

		{{#if studyDetails}}
			/*
				2f. Add RNAV ID
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
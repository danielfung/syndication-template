{{#if _uid}}
	var rnumber_uid = "{{this._uid}}";
	var rnumber_id = "{{this.id}}";
	var checkID = rnumber_id;
	checkID = checkID.toLowerCase();
	var index = checkID.indexOf("tz:");
	if(index == -1){
		rnumber_id = "s"+rnumber_uid;
	}
{{else}}
	var rnumber_id = "{{this.id}}";
	rnumber_id = rnumber_id.replace(/[^\d.-]/g, '');
	rnumber_id = "s"+rnumber_id;
{{/if}}

?'RN Study ID => '+rnumber_id+'\n';

var rnumber;
var rnumberQ = ApplicationEntity.getResultSet('_Research Project').query("ID='"+rnumber_id+"'");
?'rnumberQ.count() => '+rnumberQ.count()+'\n';

var submissionStatus = "{{status}}";

{{#if typeOfSubmission}}
//IACUC Update
	//if(submissionStatus == "Approved" || submissionStatus == "Discarded" || submissionStatus == "Closed" || submissionStatus == "Approved - Managed Externally" || submissionStatus == "Expired - Managed Externally"){
	//if(submissionStatus == "Approved"){
	if(submissionStatus == "Approved" || submissionStatus == "Discarded" || submissionStatus == "Closed"){
		if(rnumberQ.count() > 0){
			rnumberQ = rnumberQ.elements().item(1);
			?'RN Study Found => '+rnumberQ.ID+'\n';
			var canEdit = rnumberQ.customAttributes.studyDetails.customAttributes.otherStudyStaff;
			var cantEdit = rnumberQ.customAttributes.studyDetails.customAttributes.teamCanNotEdit;
			var canEditExists = rnumberQ.customAttributes.studyDetails.customAttributes.otherStudyStaff;
			var cantEditExists = rnumberQ.customAttributes.studyDetails.customAttributes.teamCanNotEdit;
			var studyDetailsRnum = rnumberQ.customAttributes.studyDetails;
			//Team Member - Read Only
			if(cantEdit == null){
				?'team can not edit Eset not found => '+cantEdit+'\n';
				var a = ApplicationEntity.createEntitySet('Person');
				studyDetailsRnum.setQualifiedAttribute('customAttributes.teamCanNotEdit', a);
				cantEdit = studyDetailsRnum.customAttributes.teamCanNotEdit;
				cantEditExists = rnumberQ.customAttributes.studyDetails.customAttributes.teamCanNotEdit;
				?'created team can not edit eset => '+cantEdit+'\n';

			}
			else{
				?'cantEdit Set found => '+cantEdit+'\n';

			}

			//Team Member 
			if(canEdit == null){
				?'team can edit Eset not found => '+canEdit+'\n';
				var a = ApplicationEntity.createEntitySet('Person');
				studyDetailsRnum.setQualifiedAttribute('customAttributes.otherStudyStaff', a);
				canEdit = studyDetailsRnum.customAttributes.otherStudyStaff;
				canEditExists = rnumberQ.customAttributes.studyDetails.customAttributes.otherStudyStaff;
				?'created team can edit eset => '+canEdit+'\n';

			}
			else{
				?'canEdit Set found => '+canEdit+'\n';
			}

			canEdit = rnumberQ.customAttributes.studyDetails.customAttributes.otherStudyStaff;
			cantEdit = rnumberQ.customAttributes.studyDetails.customAttributes.teamCanNotEdit;

			{{#each studyTeamMembers}}
				{{#if studyTeamMember.userId}}
					var person = ApplicationEntity.getResultSet("Person").query("userID = '{{studyTeamMember.userId}}'");
					if(person.count() > 0){
						person = person.elements().item(1);
						var personUserID = person.userID;
						var canEditProtocol = "{{canEditProtocol}}";
						var rnumberCanEditProtocol;

						if(canEditProtocol == "1"){
							var personExist = canEditExists.query("userID='"+personUserID+"'");
							if(personExist.count() == 0){
								rnumberCanEditProtocol = true;
								canEdit.addElement(person);
								?'person can edit => '+person+'\n';
							}
							else{
								?'Person already exists in the canEditSet => '+person+'\n';
							}
						}
						else{
							var personExist = cantEditExists.query("userID='"+personUserID+"'");
							if(personExist.count() == 0){
								rnumberCanEditProtocol = false;
								cantEdit.addElement(person);
								?'person cant edit => '+person+'\n';
							}
							else{
								?'Person already exists in the cantEditSet => '+person+'\n';
							}
						}	
					}
				{{/if}}
			{{/each}}

			{{#if investigator.studyTeamMember.userId}}
				var person = ApplicationEntity.getResultSet("Person").query("userID = '{{investigator.studyTeamMember.userId}}'").elements();
				if(person.count() > 0){
					person = person.item(1);
					var canEditProtocol = "{{canEditProtocol}}";
					var rnumberCanEditProtocol;

					if(canEditProtocol == "1"){
						rnumberCanEditProtocol = true;
						rnumberQ.customAttributes.studyDetails.customAttriubtes.principalInvestigator = person;
						?'setting person as PI => '+person+'\n';
					}
					else{
						rnumberCanEditProtocol = false;
					}
				}
				else{
					?'Investigator not found => {{investigator.studyTeamMember.userId}}\n';
				}
			{{/if}}		


 			var status = "{{status}}";		
			if(status == "Discarded"){		
 				var discardStatus = entityUtils.getObjectFromString('com.webridge.entity.Entity[OID[A4395FC87BADA242B299D1E1B029FBE2]]');		
 				rnumberQ.setQualifiedAttribute("status",discardStatus);			
 				?'Updated status to discard => '+rnumberQ.status+'\n';		
 			}		
 			else if(status == "Closed"){		
 				var closedStatus = entityUtils.getObjectFromString('com.webridge.entity.Entity[OID[AB57EC44D558484DAB9CCFA2176AFAB0]]');		
 				rnumberQ.setQualifiedAttribute("status",closedStatus);	
 				?'Updated status to closed => '+rnumberQ.status+'\n';		
 			}		
 			else{		
 				var submitStatus = entityUtils.getObjectFromString('com.webridge.entity.Entity[OID[EC4D938EFD0F244FAD70F312C85E0AF7]]');		
 				rnumberQ.setQualifiedAttribute("status",submitStatus);		
 				?'Updated status to submit => '+rnumberQ.status+'\n';		
 			}

			rnumberQ.updateReadersAndEditors();
			?'running updateReadersAndEditors\n';
			rnumberQ.updateContacts(null);
			?'updating contacts\n';
		}
		else{
			//IACUC Legacy Study Creation
			//?'IACUC Study ID => {{id}}\n';
			//var rnumber_id = "{{this.id}}";
			/*
				1a. Create Research Project and assign ID 
			*/

			rnumberQ = wom.createTransientEntity('_Research Project');
			rnumberQ.ID = rnumber_id;
			?'rnumberQ.ID => '+rnumberQ.ID+'\n';

			/*
				1b. Register the entity.
			*/
			rnumberQ.registerEntity();
			var rnumberQ = ApplicationEntity.getResultSet('_Research Project').query("ID='"+rnumber_id+"'").elements().item(1);

			/*
				1c. set Study Details
			*/
			var studyDetailsEntity = _StudyDetails.createEntity();
			rnumberQ.setQualifiedAttribute("customAttributes.studyDetails", studyDetailsEntity);
			studyDetailsEntity = rnumberQ.customAttributes.studyDetails;
			?'setting studyDetails => '+studyDetailsEntity;

			/*
				1d. Assign PI to Study, set company, createdBy, owner
			*/
			{{#if investigator.studyTeamMember.userId}}
				var investigator = rnumberQ.getQualifiedAttribute("customAttributes.studyDetails.customAttributes.principalInvestigator");
				var person = ApplicationEntity.getResultSet("Person").query("userID = '{{investigator.studyTeamMember.userId}}'").elements();
				if(investigator == null && person.count() > 0){
					person = person.item(1);
					rnumberQ.setQualifiedAttribute("customAttributes.studyDetails.customAttributes.principalInvestigator", person);
					?'setting PI => '+rnumberQ.customAttributes.studyDetails.customAttributes.principalInvestigator+'\n';

					var comp=rnumberQ.getQualifiedAttribute("customAttributes.studyDetails.customAttributes.principalInvestigator.customAttributes.department");
					if(comp.name == "Medicine" || comp.name == "Population Health"){
						var div = rnumberQ.getQualifiedAttribute("customAttributes.studyDetails.customAttributes.principalInvestigator.customAttributes.division");
						if(div != null){
							comp = div;
							?'company is population health or medicine use division => '+comp+'\n';
						}
					}

					rnumberQ.setQualifiedAttribute("company",comp);
					?'setting rnumberQ.company => '+comp+'\n';

				}
			{{/if}}

			var company = rnumberQ.company;
			if(company == null){
				//couldn't find department from PI, default to MCIT
				var company = ApplicationEntity.getResultSet("Company").query("NAME = 'MCIT'").elements().item(1);
				rnumberQ.company = company;
				?'defaulting rnumberQ.company => MCIT: '+company+'\n';

			}

			{{#if createdBy.userId}}
				var create = rnumberQ.createdBy;
				if(create == null){
					var person = ApplicationEntity.getResultSet("Person").query("userID = '{{createdBy.userId}}'");
					if(person.count() > 0){
						person = person.elements().item(1);
						rnumberQ.createdBy = person;
						?'rnumberQ.createdBy =>'+rnumberQ.createdBy+'\n';
					}
					else{
						?'Person Not Found =>{{createdBy.userId}}\n';
						var person = ApplicationEntity.getResultSet("Person").query("userID = 'administrator'").elements().item(1);
						rnumberQ.createdBy = person;
						?'defaulting rnumberQ.createdBy => administrator: '+rnumberQ.createdBy+'\n';
						}
				}
			{{else}}
				var person = ApplicationEntity.getResultSet("Person").query("userID = 'administrator'").elements().item(1);
				rnumberQ.createdBy = person;
				?'defaulting rnumberQ.createdBy => administrator: '+rnumberQ.createdBy+'\n';
			{{/if}}

			{{#if owner}}
				var person = ApplicationEntity.getResultSet("Person").query("userID = '{{owner.userId}}'").elements();
				var owner = rnumberQ.owner;
				if(owner == null && person.count() > 0){
					person = person.item(1);
					rnumberQ.owner = person;
					?'person adding as owner =>'+person.userID+'\n';
				}

			{{else}}
				var person = ApplicationEntity.getResultSet("Person").query("userID = '{{investigator.studyTeamMember.userId}}'").elements();
				var owner = rnumberQ.owner;
				if(owner == null && person.count() > 0){
					person = person.item(1);
					rnumberQ.owner = person;
					?'setting PI as owner =>'+person.userID+'\n';
				}
			{{/if}}

			/*
				1e. Set study name, longTitle, existingProtocol
			*/

				rnumberQ.name = "{{breaklines name}}";
				?'setting rnumberQ name => '+rnumberQ.name+'\n';

				rnumberQ.setQualifiedAttribute("customAttributes.studyDetails.customAttributes.longTitle", "{{breaklines fullTitle}}");
				?'setting rnumberQ longTitle => '+rnumberQ.customAttributes.studyDetails.customAttributes.longTitle+'\n';

				rnumberQ.setQualifiedAttribute("customAttributes.studyDetails.customAttributes.existingProtocol", false);
				?'setting rnumberQ existingProtocol => '+rnumberQ.customAttributes.studyDetails.customAttributes.existingProtocol+'\n';

			/*
				1f. Set Study Team Members(can/can't edit protocol) - studyDetails.customAttributes.otherStudyStaff - teamCanNotEdit
			*/

				var otherStudyStaffEset = rnumberQ.customAttributes.studyDetails.customAttributes.otherStudyStaff
				if(otherStudyStaffEset == null){
					var personSet = Person.createEntitySet();
					rnumberQ.setQualifiedAttribute("customAttributes.studyDetails.customAttributes.otherStudyStaff", personSet);
					?'create team can edit eset => '+rnumberQ.customAttributes.studyDetails.customAttributes.otherStudyStaff+'\n';
					otherStudyStaffEset = rnumberQ.customAttributes.studyDetails.customAttributes.otherStudyStaff;
				}

				var teamCantEditEset = rnumberQ.customAttributes.studyDetails.customAttributes.teamCanNotEdit
				if(teamCantEditEset == null){
					var personSet = Person.createEntitySet();
					rnumberQ.setQualifiedAttribute("customAttributes.studyDetails.customAttributes.teamCanNotEdit", personSet);
					?'create team cant edit eset => '+rnumberQ.customAttributes.studyDetails.customAttributes.teamCanNotEdit+'\n';
					teamCantEditEset = rnumberQ.customAttributes.studyDetails.customAttributes.teamCanNotEdit;
					
				}

				{{#each studyTeamMembers}}
					{{#if studyTeamMember.userId}}
						var person = ApplicationEntity.getResultSet("Person").query("userID = '{{studyTeamMember.userId}}'");
						if(person.count() > 0){
							person = person.elements().item(1);
							var canEditProtocol = '{{canEditProtocol}}';
							if(canEditProtocol == '1'){
								otherStudyStaffEset.addElement(person);
								?'add person to other study staff eset => '+person+'\n';
							}
							else{
								teamCantEditEset.addElement(person);
								?'add person to team cant edit eset => '+person+'\n';
							}
						}
						else{
							?'person not found by userID => {{studyTeamMember.userId}}\n';
						}
					{{/if}}
				{{/each}}
				
			/*
				1g. Set Study Subject Type -> Animal, Copy of existing protocol -> New Protocol, existingProtocol -> False
			*/
				var subjectType = ApplicationEntity.getResultSet('_Study Subject Type').query("customAttributes.name='Animal'").elements().item(1);
				rnumberQ.setQualifiedAttribute("customAttributes.studyDetails.customAttributes.subjectType", subjectType);
				?'setting studyType to Animal => '+rnumberQ.customAttributes.studyDetails.customAttributes.subjectType+'\n';

				rnumberQ.setQualifiedAttribute("customAttributes.studyDetails.customAttributes.existingProtocol", false);

				var existingProtocol = rnumberQ.customAttributes.studyDetails.customAttributes.existingProtocol;
				if(existingProtocol){
				  var protocoltype = ApplicationEntity.getResultSet('_Type of Protocol').query("customAttributes.name='New Animal Protocol Based on Existing'").elements().item(1);
				  rnumberQ.setQualifiedAttribute("customAttributes.studyDetails.customAttributes.protocolType", protocoltype);
				  ?'setting protocolType => '+rnumberQ.customAttributes.studyDetails.customAttributes.protocolType+'\n';
				}
				else{
				  var protocoltype = ApplicationEntity.getResultSet('_Type of Protocol').query("customAttributes.name='New Animal Protocol'").elements().item(1);
				  rnumberQ.setQualifiedAttribute("customAttributes.studyDetails.customAttributes.protocolType", protocoltype);
				  ?'setting protocolType => '+rnumberQ.customAttributes.studyDetails.customAttributes.protocolType+'\n';
				}

			/*
				1h. Create Contacts, Readers, Editors Eset
			*/
				var personSet = Person.createEntitySet();
				rnumberQ.contacts = personSet;
				?'created Contacts eset => '+rnumberQ.contacts+'\n';

				var personSet = Person.createEntitySet();
				rnumberQ.setQualifiedAttribute("customAttributes.editors",personSet);
				?'created editors eset => '+rnumberQ.customAttributes.editors+'\n';

				var personSet = Person.createEntitySet();
				rnumberQ.setQualifiedAttribute("customAttributes.readers",personSet);
				?'created readers eset => '+rnumberQ.customAttributes.readers+'\n';

			/*
				2a. Create/ Modified Date
			*/

				var newDate = new Date();

				rnumberQ.dateCreated = newDate;
				?'set dateCreated => '+rnumberQ.dateCreated+'\n';
				rnumberQ.dateModified = newDate;
				?'set dateModified => '+rnumberQ.dateCreated+'\n';

			/*
				2b. Set Status -> Submitted - com.webridge.entity.Entity[OID[EC4D938EFD0F244FAD70F312C85E0AF7]]
			*/
				var statusOID = entityUtils.getObjectFromString('com.webridge.entity.Entity[OID[EC4D938EFD0F244FAD70F312C85E0AF7]]');
				rnumberQ.status = statusOID;
				?'setting status to submitted => '+rnumberQ.status.ID+'\n';


			/*
				2c. Set Resource Container
			*/
				var theParent = entityUtils.getObjectFromString('com.webridge.entity.Entity[OID[A0EE3AF11AD8A948B6EC12D80E8886F6]]');
				var current_status = rnumberQ.status.ID;
				var wsTemplate = ContainerTemplate.getElements("ContainerTemplateForID", "ID", "TMPL535EFB9496400");
				var resourceContainer = rnumberQ.resourceContainer;
				if(resourceContainer == null){
					if(wsTemplate != null && theParent != null){
						wsTemplate = wsTemplate.item(1);
						rnumberQ.createWorkspace(theParent, wsTemplate);
						?'rnumberQ.resourceContainer =>'+rnumberQ.resourceContainer+'\n';
						?'rnumberQ.resourceContainer.template =>'+rnumberQ.resourceContainer.template+'\n';
					}
				}

			/*
				2d. Update Contacts/Editors/Readers List
			*/
				rnumberQ.updateContacts(null);
				rnumberQ.updateReadersAndEditors();

			/*
				2e. Set up smartform starting step - should not be null
			*/

				var smartFormStartingStep = entityUtils.getObjectFromString('com.webridge.entity.Entity[OID[5CEC12A73CC6DD4B9AFC3D82038932FF]]');
				rnumberQ.currentSmartFormStartingStep = smartFormStartingStep;
				?'smartform starting step => '+rnumberQ.currentSmartFormStartingStep+'\n';				
		}

	}
	else{
		?'IACUC Status is not approved/closed/dicarded => {{id}}\n';
	}
{{/if}}
var irb_id = "{{this._uid}}";
irb_id = 'i'+irb_id;
var irb;
var irbQ = ApplicationEntity.getResultSet('_IRBSubmission').query("ID='"+irb_id+"'");
?'irbQ.count() =>'+irbQ.count()+'\n';

var status = '{{status}}';
if(status == "Submitted"){
/*
	1. Create IRB Submission if it doesn't exist.
*/
if(irbQ.count() == 0){
	irbQ = wom.createTransientEntity('_IRBSubmission');
	? 'irbQ =>'+irbQ+'\n';

	/*
		1a. update ID of IRB Submission
	*/

		irbQ.ID = irb_id;
		?'irbQ.ID =>'+irbQ.ID+'\n';

	/*
		1b. Register and initalize IRB Submission
	*/
		irbQ.registerEntity();

		//initalize
		var irbQ = ApplicationEntity.getResultSet('_IRBSubmission').query("ID='"+irb_id+"'").elements().item(1);
		//irbQ.initalize();

	/*
		1c. set required fields (owner, company, createdby, pi)
	*/
		var company = irbQ.company;
		if(company == null){
			var a = ApplicationEntity.getResultSet("Company").query("customAttributes.organizationCustomExtension.customAttributes.masterID = '{{company.id}}'");
			if(a.count()>0){
				irbQ.company = a.elements().item(1);
				?'irbQ.company =>'+irbQ.company+'\n';
			}
			else{
				?'Company Not Found =>{{company.id}}\n';
			}
		}

		//createdby - temporary
		var create = irbQ.createdBy;
		if(create == null){
			var person = ApplicationEntity.getResultSet("Person").query("userID = '{{createdBy.userId}}'");
			if(person.count() > 0){
				person = person.elements().item(1);
				irbQ.createdBy = person;
				?'irbQ.createdBy =>'+irbQ.createdBy+'\n';
			}
			else{
				?'Person Not Found =>{{createdBy.userId}}\n';
			}
		}

		//assigning PI to Study(IRB)
		var investigator = irbQ.getQualifiedAttribute("customAttributes.investigator");

		var person = ApplicationEntity.getResultSet("Person").query("userID = '{{studyDetails.principalInvestigator.userId}}'").elements();
		
		if(investigator == null && person.count() > 0){
			var studyTeamMember = _StudyTeamMemberInfo.createEntity();
			?'_StudyTeamMemberInfo =>'+studyTeamMember+'\n';
			irbQ.setQualifiedAttribute("customAttributes.investigator", studyTeamMember);
			person = person.item(1);
			?'person adding as PI =>'+person.ID+'\n';
			studyTeamMember.setQualifiedAttribute("customAttributes.studyTeamMember", person);
		}

	/*
		1d. set parentStudy to itself;
		if null, set to itself inorder for read security to work correctly
	*/
		var parentStudy = irbQ.getQualifiedAttribute("customAttributes.parentStudy");
		if(parentStudy == null){
			irbQ.setQualifiedAttribute("customAttributes.parentStudy", irbQ);
		}
		?'parentStudy =>'+irbQ.customAttributes.parentStudy+'\n';


	/*
		1e. set submissionType = 'STUDY'; 
	*/
		var submissionTypes = ApplicationEntity.getResultSet("_SubmissionType");
		var queryStr = "ID ='STUDY'";
		submissionTypes = submissionTypes.query(queryStr);
		if(submissionTypes.count() > 0){
			var submissionType = submissionTypes.elements().item(1);
			irbQ.setQualifiedAttribute("customAttributes.submissionType", submissionType);
		}
		?'submissionType =>'+irbQ.customAttributes.submissionType.ID+'\n';

	/*
		1f. set irb Settings, irbSubmissionCustomExtension.irbSettingsNYU, irb Group
	*/
		var irbSettings = _IRBSettings.getIRBSettings();
		var setting = irbQ.customAttributes.irbSettings
		if(setting == null){
			irbQ.setQualifiedAttribute("customAttributes.irbSettings", irbSettings);
		}
		?'irbSettings =>'+irbQ.customAttributes.irbSettings+'\n';

		var irbCustomSettings = irbQ.customAttributes.irbSubmissionCustomExtension;
		if(irbCustomSettings == null){
			var a = _IRBSubmissionCustomExtension.createEntity();
			irbQ.customAttributes.irbSubmissionCustomExtension = a;
			?'irbSubmissionCustomExtension created =>'+irbQ.customAttributes.irbSubmissionCustomExntesion+'\n';
		}

		irbCustomSettings = irbQ.customAttributes.irbSubmissionCustomExtension;

		var e = entityUtils.getObjectFromString('com.webridge.entity.Entity[OID[7218FC2296DCB946838E4148D35F63A5]]');
		if(e != null){
			?'found irbSubmissionCustomExtension.irbSettings =>'+e+'\n';
			irbQ.customAttributes.irbSubmissionCustomExtension.setQualifiedAttribute("customAttributes.irbSettingsNYU", e);
			?'added irbSettingsNYU =>'+irbQ.customAttributes.irbSubmissionCustomExtension.customAttributes.irbSettingsNYU+'\n';
		}
		var f = entityUtils.getObjectFromString('com.webridge.entity.Entity[OID[C7F8EC20F5F3504CBBAE38054DD6F29F]]');
			if(f != null){
			?'found irbSubmissionCustomExtension.irbGroup =>'+f+'\n';
			irbQ.customAttributes.irbSubmissionCustomExtension.setQualifiedAttribute("customAttributes.irbGroup", f);
			?'added irbGroup =>'+irbQ.customAttributes.irbSubmissionCustomExtension.customAttributes.irbGroup+'\n';
		}

	/*
		1g. set irb status to pre-submission
			set dateCreated/dateModified;
	*/
		var status = irbQ.status;
		if(status == null){
			var statusOID = ApplicationEntity.getResultSet('ProjectStatus').query("ID='Pre-Submission'").elements().item(1);
			irbQ.status = statusOID;
			?'irbQ.status =>'+irbQ.status.ID+'\n';
		}

		var dateCreate = irbQ.dateCreated;
		if(dateCreate == null){
			irbQ.dateCreated = new Date();
			?'irbQ.dateCreated =>'+irbQ.dateCreated+'\n';
		}

		var dateMod = irbQ.dateModified;
		if(dateMod == null){
			irbQ.dateModified = new Date();
			?'irbQ.dateModified =>'+irbQ.dateModified+'\n';
		}

	/*
		1h. create and set the resource container for IRB Submission
	*/
		// Find the IRB Container
		var theParent = Container.getElements("ContainerForID", "ID", "IRB");
		if (theParent.count()==1) {
			theParent = theParent.item(1);
		} else {
			?'IRB Submissions folder not found\n';
		}

		var resourceContainer = irbQ.resourceContainer;
		if(resourceContainer == null){
			var template = wom.getEntityFromString("com.webridge.entity.Entity[OID[7CDE218AEB7E7D45804ED6F0B895B017]]");
			if(template != null && theParent.count()==1){
				irbQ.createWorkspace(theParent, template);
				?'irbQ.resourceContainer =>'+irbQ.resourceContainer+'\n';
			}
			else{
				?'Initial Template not found\n';
			}
			?'irbQ.resourceContainer.template =>'+irbQ.resourceContainer.template+'\n';
		}

	/*
		1i. set name, shortDescription, longTitle
	*/
		irbQ.name = "{{name}}";
		?'setting irbQ name =>'+irbQ.name+'\n';
		irbQ.description = "{{studyDetails.shortDescription}}";
		?'setting irbQ description =>'+irbQ.description+'\n';
		irbQ.customAttributes.studyTeamDescription = "{{studyDetails.longTitle}}";
		?'setting irbQ studyTeamDescription =>'+irbQ.customAttributes.studyTeamDescription+'\n';
		irbQ.customAttributes.studyTeamDescription_Text = "{{studyDetails.longTitle}}";
		?'setting irbQ.customAttributes.studyTeamDesciption_Text =>'+irbQ.customAttributes.studyTeamDescription_Text+'\n';

	/*
		1j. set irb
	*/
		var name = "{{studyDetails.responsibleIRB.irbType}}";
		var IRB;
		if(name == "BRANY"){
			IRB = ApplicationEntity.getResultSet('_AdminOffice').query("ID='BRANY IRB'");
			if(IRB.count() > 0){
				IRB = IRB.elements().item(1);
				irbQ.customAttributes.IRB = IRB;
				?'setting IRB Office =>'+irbQ.customAttributes.IRB+'\n';
			}
			else{
				?'BRANY IRB => NOT FOUND\n';
			}
		}
		else{
			IRB = ApplicationEntity.getResultSet('_AdminOffice').query("ID='NYUSOM IRB'");
			if(IRB.count() > 0){
				IRB = IRB.elements().item(1);
				irbQ.customAttributes.IRB = IRB;
				?'setting IRB Office =>'+irbQ.customAttributes.IRB+'\n';
			}
			else{
				?'NYUSOM IRB => NOT FOUND\n';
			}
		}

	/*
		2a. set FundingSources
		ex) _FundingSource.createEntity();
	*/
		//Primary Funding Source
		var newFundingSource = _FundingSource.createEntity();
		?'fundingSource =>'+newFundingSource+'\n';
		var a = ApplicationEntity.getResultSet("Company").query("customAttributes.organizationCustomExtension.customAttributes.masterID = '{{studyDetails.fundingSponsorPrimary.id}}'");
		newFundingSource.customAttributes = _FundingSource_CustomAttributesManager.createEntity();
		?'fundingSource.customAttributes =>'+newFundingSource.customAttributes+'\n';
		if(a.count() > 0){
			var organization = a.elements().item(1);
			?'organization found =>'+organization+'\n';

			newFundingSource.customAttributes.organization = organization;
			?'adding organization =>'+newFundingSource.customAttributes.organization+'\n';
			irbQ.setQualifiedAttribute("customAttributes.fundingSources", newFundingSource, "add");
		}

		//Secondary Funding Source
		{{#each studyDetails.fundingSponsorSecondary}}			
			{{#if fundingSponsor.organizationCustomExtension.ID}}

					var newFundingSource = _FundingSource.createEntity();
					?'fundingSource =>'+newFundingSource+'\n';
					var a = ApplicationEntity.getResultSet("Company").query("customAttributes.organizationCustomExtension.customAttributes.masterID = '{{fundingSponsor.organizationCustomExtension.masterID}}'");
					newFundingSource.customAttributes = _FundingSource_CustomAttributesManager.createEntity();
					?'fundingSource.customAttributes =>'+newFundingSource.customAttributes+'\n';
					if(a.count() > 0){
						var organization = a.elements().item(1);
						?'organization found =>'+organization+'\n';

						newFundingSource.customAttributes.organization = organization;
						?'adding organization =>'+newFundingSource.customAttributes.organization+'\n';
						irbQ.setQualifiedAttribute("customAttributes.fundingSources", newFundingSource, "add");
					}			
			{{/if}}
		{{/each}}

	/*
		2b. set StudyTeam 
		'customAttributes.studyDetails.customAttributes.teamSubInvestigators' --> co-investigator
		'customAttributes.studyDetails.customAttributes.researchCoordinators' --> Study Coordinator/Primary Contact
		'customAttributes.studyDetails.customAttributes.otherStudyStaff' --> studyTeamMember
		'customAttributes.studyDetails.customAttributes.teamVolunteers' --> studyTeamMember
		ex) var a = ApplicationEntity.createEntitySet("_StudyTeamMemberInfo");
		    irbQ.setQualifiedAttribute("customAttributes.studyTeamMembers", a);	 
			var stubTeamMap = {
				"stubSubInvestigators":{
					"role": wom.getEntityFromString("com.webridge.entity.Entity[OID[975C66840E61074B9E445C485B28B58C]]"),//co investigator
					"attr": stubResearchProject.getQualifiedAttribute("customAttributes.teamSubInvestigators")//subinvestigator
				},
				"stubResearchCoordinators":{
					"role": wom.getEntityFromString("com.webridge.entity.Entity[OID[22DEA0DE85F4EB4684FCA11837F4B923]]"),//Study Coordinator / Primary Contact
					"attr": stubResearchProject.getQualifiedAttribute("customAttributes.researchCoordinatorsPerson")//researchCoordinator
				},
				"stubStudyContacts":{
					"role":  wom.getEntityFromString("com.webridge.entity.Entity[OID[6F29389EA272CA409AB4AEA2542F7D6D]]"),// Study Team Member
					"attr": stubResearchProject.getQualifiedAttribute("customAttributes.studyTeamContacts")//study team
				}
			};   
	*/
		var studyTeamMemberInfo = ApplicationEntity.createEntitySet("_StudyTeamMemberInfo");
		?'studyTeamMemberInfo =>'+studyTeamMemberInfo+'\n';
		irbQ.setQualifiedAttribute("customAttributes.studyTeamMembers", studyTeamMemberInfo);	

		//teamSubInvestigators --> co-investigator
		{{#each studyDetails.teamSubInvestigators}}
				var existingMember = studyTeamMemberInfo.query("customAttributes.studyTeamMember.customAttributes.personCustomExtension.customAttributes.masterID ='{{userId}}'");
				var role = wom.getEntityFromString("com.webridge.entity.Entity[OID[975C66840E61074B9E445C485B28B58C]]");
				if(existingMember != null && existingMember.count > 0){

					existingMember = existingMember.elements().item(1);
					?'exisitngMember =>'+existingMember+'\n';

					var rolesOnStudy = existingMember.customAttributes.rolesOnstudy;
					?'roleOnStudy =>'+rolesOnStudy+'\n';

					if(rolesOnStudy != null && rolesOnStudy.count > 0){
						rolesOnStudy.addElement(role);
						studyTeamMemberInfo.addElement(existingMember);
					}
				}
				else{
					var studyTeamMember = _StudyTeamMemberInfo.createEntity();
					var person = ApplicationEntity.getResultSet("Person").query("userID = '{{userId}}'").elements();
					if(person != null && person.count > 0){
						person = person.item(1);
						studyTeamMember.setQualifiedAttribute("customAttributes.studyTeamMember", person);//add person by userId
						studyTeamMember.setQualifiedAttribute("customAttributes.rolesOnStudy", role, "add");
						studyTeamMemberInfo.addElement(studyTeamMember);
						?'person to added into study team =>'+person+'\n';
					}
				}

		{{/each}}

		//researchCoordinators --> Study Coordinator/Primary Contact
		{{#each studyDetails.researchCoordinators}}
				var existingMember = studyTeamMemberInfo.query("customAttributes.studyTeamMember.customAttributes.personCustomExtension.customAttributes.masterID ='{{coordinator.userId}}'");
				var role = wom.getEntityFromString("com.webridge.entity.Entity[OID[22DEA0DE85F4EB4684FCA11837F4B923]]");
				if(existingMember != null && existingMember.count > 0){

					existingMember = existingMember.elements().item(1);
					?'exisitngMember =>'+existingMember+'\n';

					var rolesOnStudy = existingMember.customAttributes.rolesOnstudy;
					?'roleOnStudy =>'+rolesOnStudy+'\n';

					if(rolesOnStudy != null && rolesOnStudy.count > 0){
						rolesOnStudy.addElement(role);
						studyTeamMemberInfo.addElement(existingMember);
					}
				}
				else{
					var studyTeamMember = _StudyTeamMemberInfo.createEntity();
					var person = ApplicationEntity.getResultSet("Person").query("userID = '{{coordinator.userId}}'").elements();
					if(person != null && person.count > 0){
						person = person.item(1);
						studyTeamMember.setQualifiedAttribute("customAttributes.studyTeamMember", person);//add person by userId
						studyTeamMember.setQualifiedAttribute("customAttributes.rolesOnStudy", role, "add");
						studyTeamMemberInfo.addElement(studyTeamMember);
						?'person to added into study team =>'+person+'\n';
					}
				}
				
		{{/each}}

		//other study staff --> study team member
		{{#each studyDetails.otherStudyStaff}}
				var existingMember = studyTeamMemberInfo.query("customAttributes.studyTeamMember.customAttributes.personCustomExtension.customAttributes.masterID ='{{userId}}'"); 
				var role = wom.getEntityFromString("com.webridge.entity.Entity[OID[6F29389EA272CA409AB4AEA2542F7D6D]]");
				if(existingMember != null && existingMember.count > 0){

					existingMember = existingMember.elements().item(1);
					?'exisitngMember =>'+existingMember+'\n';

					var rolesOnStudy = existingMember.customAttributes.rolesOnstudy;
					?'roleOnStudy =>'+rolesOnStudy+'\n';

					if(rolesOnStudy != null && rolesOnStudy.count > 0){
						rolesOnStudy.addElement(role);
						studyTeamMemberInfo.addElement(existingMember);
					}
				}
				else{
					var studyTeamMember = _StudyTeamMemberInfo.createEntity();
					var person = ApplicationEntity.getResultSet("Person").query("userID = '{{userId}}'").elements();
					if(person != null && person.count > 0){
						person = person.item(1);
						studyTeamMember.setQualifiedAttribute("customAttributes.studyTeamMember", person);//add person by userId
						studyTeamMember.setQualifiedAttribute("customAttributes.rolesOnStudy", role, "add");
						studyTeamMemberInfo.addElement(studyTeamMember);
						?'person to added into study team =>'+person+'\n';
					}
				}

		{{/each}}

		//team Volunteer --> study team member
		{{#each studyDetails.teamVolunteers}}
				var existingMember = studyTeamMemberInfo.query("customAttributes.studyTeamMember.customAttributes.personCustomExtension.customAttributes.masterID ='{{userId}}'"); 
				var role = wom.getEntityFromString("com.webridge.entity.Entity[OID[6F29389EA272CA409AB4AEA2542F7D6D]]");
				if(existingMember != null && existingMember.count > 0){

					existingMember = existingMember.elements().item(1);
					?'exisitngMember =>'+existingMember+'\n';

					var rolesOnStudy = existingMember.customAttributes.rolesOnstudy;
					?'roleOnStudy =>'+rolesOnStudy+'\n';

					if(rolesOnStudy != null && rolesOnStudy.count > 0){
						rolesOnStudy.addElement(role);
						studyTeamMemberInfo.addElement(existingMember);
					}
				}
				else{
					var studyTeamMember = _StudyTeamMemberInfo.createEntity();
					var person = ApplicationEntity.getResultSet("Person").query("userID = '{{userId}}'").elements();
					if(person != null && person.count > 0){
						person = person.item(1);
						studyTeamMember.setQualifiedAttribute("customAttributes.studyTeamMember", person);//add person by userId
						studyTeamMember.setQualifiedAttribute("customAttributes.rolesOnStudy", role, "add");
						studyTeamMemberInfo.addElement(studyTeamMember);
						?'person to added into study team =>'+person+'\n';
					}
				}		
		{{/each}}

	/*
		2c. set Drugs/Devices 
		1f. set drugs and devices
		if drugSet does not exist - create it.
		if drug not found in drug selection list, don't create.
		if deviceSet does not exist - create it.
		if device not found, don't create.
	*/
		var irbDrugs;
		var irbDevices;

		var drugSet = irbQ.getQualifiedAttribute("customAttributes.drugs");

		if(drugSet == null){
			drugSet = _Drug.createEntitySet();
			irbQ.setQualifiedAttribute("customAttributes.drugs", drugSet);
		}

		{{#if studyDetails.Drugs}}
			irbQ.customAttributes.drugInvolved = true;
		{{else}}
			irbQ.customAttributes.drugInvolved = false;
		{{/if}}

		{{#each studyDetails.Drugs}}
			irbDrugs = ApplicationEntity.getResultSet("_DrugSelection").query("ID ='{{ID}}'");
			if(irbDrugs != null && irbDrugs.count() > 0){
				irbDrugs = irbDrugs.elements().item(1);
				var newDrug = _Drug.createEntity();
				newDrug.setQualifiedAttribute("customAttributes.drug", irbDrugs);
				?'adding drug to drugSet =>'+newDrug+'\n';
				drugSet.addElement(newDrug);
			}
			else{
				?'Cant Find Drug => {{ID}}\n';
			}
		{{/each}}

		var deviceSet = irbQ.getQualifiedAttribute("customAttributes.devices");

		if(deviceSet == null){
			deviceSet = _Device.createEntitySet();
			irbQ.setQualifiedAttribute("customAttributes.devices", deviceSet);
		}

		{{#if studyDetails.Devices}}
			irbQ.customAttributes.deviceInvolved = true;
		{{else}}
			irbQ.customAttributes.deviceInvolved = false;
		{{/if}}

		{{#each studyDetails.Devices}}
			irbDevices = ApplicationEntity.getResultSet("_DeviceSelection").query("ID ='{{deviceSelection.ID}}'");
			if(irbDevices != null && irbDevices.count() > 0){
				irbDevices = irbDevices.elements().item(1);
				var newDevice = _Device.createEntity();
				newDevice.setQualifiedAttribute("customAttributes.device", irbDevices);
				?'adding device to deviceSet =>'+newDevice+'\n';
				deviceSet.addElement(newDevice);
			}
			else{
				?'Cant Find Device => {{deviceSelection.ID}}\n';
			}
		{{/each}}

	/*
		2d. set external sites
		otherLocations -> externalSites
	*/
		var externalSites = irbQ.getQualifiedAttribute("customAttributes.externalSites");

		if(externalSites == null){
			externalSites = _ExternalSite.createEntitySet();
			?'externalSites =>'+externalSites;
		}
		{{#if studyDetails.otherLocations}}
			irbQ.customAttributes.externalSitesPresent = true;
		{{else}}
			irbQ.customAttributes.externalSitesPresent = false;
		{{/if}}

		{{#each studyDetails.otherLocations}}
			{{#if name}}
				var newSite = _ExternalSite.createEntity();
				newSite.setQualifiedAttribute("customAttributes.siteName", "{{name}}");
				externalSites.addElement(newSite);
				?'adding site => {{name}}\n';
			{{/if}}
		{{/each}}

		irbQ.setQualifiedAttribute("customAttributes.externalSites", externalSites);

	/*
		2e. update editor/reader list
	*/
		irbQ.updateReadersAndEditors();

	/*
		2f. create Locations
	*/

		var belleuveLocation = irbQ.customAttributes.locationsBellevue;
		var offsiteFGPLocation = irbQ.customAttributes.locationsOffsiteFgp;
		var vaLocation = irbQ.customAttributes.locationsVA;
		var nyuSchoolOrCollegeLocation = irbQ.customAttributes.nyuSchoolCollegeLocation;
		var nyumcLocation = irbQ.customAttributes.nyumcLocations;
		var otherLocation = irbQ.customAttributes.otherNYULocations;

		if(belleuveLocation == null){
			var locationSet = _NYULocations.createEntitySet();
			irbQ.customAttributes.locationsBellevue = locationSet;
			?'Created Belleuve Set =>'+locationSet+'\n';
		}

		if(offsiteFGPLocation == null){
			var locationSet = _NYULocations.createEntitySet();
			irbQ.customAttributes.locationsOffsiteFgp = locationSet;
			?'Created Offsite FGP Set =>'+locationSet+'\n';
		}

		if(vaLocation == null){
			var locationSet = _NYULocations.createEntitySet();
			irbQ.customAttributes.locationsVA = locationSet;
			?'Created VA Hospital Set =>'+locationSet+'\n';
		}

		if(nyuSchoolOrCollegeLocation == null){
			var locationSet = _NYULocations.createEntitySet();
			irbQ.customAttributes.nyuSchoolCollegeLocation = locationSet;
			?'Created NYU School or College Set =>'+locationSet+'\n';
		}

		if(nyumcLocation == null){
			var locationSet = _NYULocations.createEntitySet();
			irbQ.customAttributes.nyumcLocations = locationSet;
			?'Created NYUMC Set =>'+locationSet+'\n';
		}

		if(otherLocation == null){
			var locationSet = _NYULocations.createEntitySet();
			irbQ.customAttributes.otherNYULocations = locationSet;
			?'Created NYUMC Set =>'+locationSet+'\n';
		}

		{{#each studyDetails.bellevueLocations}}
			var location = ApplicationEntity.getResultSet('_NYULocations').query("ID='{{ID}}'").elements().item(1);
			irbQ.setQualifiedAttribute("customAttributes.locationsBellevue", location, "add");
			?'adding belleuve location =>'+location+'\n';
		{{/each}}

		{{#each studyDetails.nyuSchoolCollegeLocations}}
			var location = ApplicationEntity.getResultSet('_NYULocations').query("ID='{{ID}}'").elements().item(1);
			irbQ.setQualifiedAttribute("customAttributes.nyuSchoolCollegeLocation", location, "add");
			?'adding belleuve location =>'+location+'\n';
		{{/each}}

		{{#each studyDetails.nyufgpLocations}}
			var location = ApplicationEntity.getResultSet('_NYULocations').query("ID='{{ID}}'").elements().item(1);
			irbQ.setQualifiedAttribute("customAttributes.locationsOffsiteFgp", location, "add");
			?'adding offsite FGP location =>'+location+'\n';
		{{/each}}

		{{#each studyDetails.nyumcLocations}}
			var location = ApplicationEntity.getResultSet('_NYULocations').query("ID='{{ID}}'").elements().item(1);
			irbQ.setQualifiedAttribute("customAttributes.nyumcLocations", location, "add");
			?'adding NYUMC location =>'+location+'\n';
		{{/each}}

		{{#each studyDetails.otherLocations}}
			var location = ApplicationEntity.getResultSet('_NYULocations').query("ID='{{ID}}'").elements().item(1);
			irbQ.setQualifiedAttribute("customAttributes.otherNYULocations", location, "add");
			?'adding Other location =>'+location+'\n';
		{{/each}}

		{{#each studyDetails.vaHospitalLocations}}
			var location = ApplicationEntity.getResultSet('_NYULocations').query("ID='{{ID}}'").elements().item(1);
			irbQ.setQualifiedAttribute("customAttributes.locationsVA", location, "add");
			?'adding Other location =>'+location+'\n';
		{{/each}}

}
}
else{
	?'Error: Status is not submitted\n';
	?'RN Study ID =>{{id}}\n';
	?'current status =>{{status}}\n';
}
var crms_id = "{{this._uid}}";
crms_id = 'c'+crms_id;
var crms;
var crmsQ = ApplicationEntity.getResultSet('_ClinicalTrial').query("ID='"+crms_id+"'");
?'crmsQ.count() =>'+crmsQ.count()+'\n';

var status = '{{status}}';
if(status == "Submitted"){
	/*
		1. Create CRMS Submission if it doesn't exist.
	*/
	if(crmsQ.count() == 0){
		crmsQ = wom.createTransientEntity('_ClinicalTrial');
		?'crmsQ =>'+crmsQ+'\n';

		/*
			1a. update ID of CRMS Submission
		*/

			crmsQ.ID = crms_id;
			?'crmsQ.ID =>'+crmsQ.ID+'\n';

		/*
			1b. Register and initalize CRMS Submission
		*/
			crmsQ.registerEntity();
			//initalize
			var crmsQ = ApplicationEntity.getResultSet('_ClinicalTrial').query("ID='"+crms_id+"'").elements().item(1);
			//crmsQ.initalize();

			if(crmsQ.customAttributes == null){
				var c = _ClinicalTrial_CustomAttributesManager.createEntity();
				crmsQ.customAttributes = c;
				?'created crmsQ.customAttributes =>'+c+'\n';
			}

		/*
			1c. set required fields (company, createdby, pi, departmentAdmin, contacts)
		*/
			//contacts
			if(crmsQ.contacts == null){
				var a = ApplicationEntity.createEntitySet("Person");
				crmsQ.contacts = a;
				?'crmsQ.contacts =>'+crmsQ.contacts+'\n';
			}

			var contacts = crmsQ.contacts;

			var company = crmsQ.company;
			if(company == null){
				var a = ApplicationEntity.getResultSet("Company").query("customAttributes.organizationCustomExtension.customAttributes.masterID = '{{company.id}}'");
				if(a.count()>0){
					crmsQ.company = a.elements().item(1);
					?'crmsQ.company =>'+crmsQ.company+'\n';
				}
			}

			//createdby - temporary
			var create = crmsQ.createdBy;
			if(create == null){
				var person = ApplicationEntity.getResultSet("Person").query("userID = '{{createdBy.userId}}'");
				if(person.count() > 0){
					person = person.elements().item(1);
					crmsQ.createdBy = person;
					?'crmsQ.createdBy =>'+crmsQ.createdBy+'\n';
				}
				else{
					?'Person Not Found =>{{createdBy.userId}}\n';
				}
			}

			//assigning PI to Study(CRMS)
			var investigator = crmsQ.getQualifiedAttribute("customAttributes.pi");

			var person = ApplicationEntity.getResultSet("Person").query("userID = '{{studyDetails.principalInvestigator.userId}}'");
			
			if(investigator == null && person.count() > 0){
				person = person.elements().item(1);
				crmsQ.customAttributes.pi = person;
				?'crmsQ.customAttributes.pi =>'+crmsQ.customAttributes.pi+'\n';
				contacts.addElement(person);
				?person+' added into contacts\n';
			}

			//assigning Department Admin to Study(CRMS)
			var deptAdmin = crmsQ.getQualifiedAttribute("customAttributes.departmentAdministrator");

			var person = ApplicationEntity.getResultSet("Person").query("userID = '{{studyDetails.studyDepartmentalAdmin.userId}}'");
			
			if(deptAdmin== null && person.count() > 0){
				person = person.elements().item(1);
				crmsQ.customAttributes.departmentAdministrator = person;
				?'crmsQ.customAttributes.deptartmentAdministrator =>'+crmsQ.customAttributes.departmentAdministrator+'\n';
				contacts.addElement(person);
				?person+' added into contacts\n';
			}

		/*
			1d. set parentStudy to itself -- NOT USED IN CRMS(_ClinicalTrial)?;
			if null, set to itself inorder for read security to work correctly
		*/
			var parentStudy = crmsQ.getQualifiedAttribute("customAttributes.parentClinicalTrial");
			if(parentStudy == null){
				//crmsQ.setQualifiedAttribute("customAttributes.parentClinicalTrial", crmsQ);
			}
			//?'parentStudy =>'+crmsQ.customAttributes.parentClinicalTrial+'\n';


		/*
			1e. set dateCreated/dateModified/dateEnteredState;
		*/
			var dateCreate = crmsQ.dateCreated;
			if(dateCreate == null){
				crmsQ.dateCreated = new Date();
				?'crmsQ.dateCreated =>'+crmsQ.dateCreated+'\n';
			}

			var dateMod = crmsQ.dateModified;
			if(dateMod == null){
				crmsQ.dateModified = new Date();
				?'crmsQ.dateModified =>'+crmsQ.dateModified+'\n';
			}

			var dateEnter = crmsQ.dateEnteredState;
			if(dateEnter == null){
				crmsQ.dateEnteredState = new Date();
				?'crmsQ.dateEnteredState =>'+crmsQ.dateEnteredState+'\n';
			}

		/*
			1f. create and set resource Container for CRMS Submission
		*/
			var theParent = wom.getEntityFromString("com.webridge.entity.Entity[OID[D26D4DF0230184469659F06947FA2F50]]");
			if (theParent != null) {
				?'CRMS Container Found =>'+theParent+'\n';
			} else {
				?'CRMS Submissions container not found\n';
			}

			var resourceContainer = crmsQ.resourceContainer;
			if(resourceContainer == null && theParent != null){
				var template = entityUtils.getObjectFromString('com.webridge.entity.Entity[OID[AE2DB3E8DB7A2D4F8C1067472B7DBCD9]]');
				if(template != null){
					crmsQ.createWorkspace(theParent, template); //???THE PARENT???
					?'crmsQ.resourceContainer =>'+crmsQ.resourceContainer+'\n';
				}
				else{
					?'Initial Template not found\n';
				}
				?'crmsQ.resourceContainer.template =>'+crmsQ.resourceContainer.template+'\n';
			}

		/*
			1g. set name, description, status
		*/
			crmsQ.name = "{{studyDetails.longTitle}}";
			?'crmsQ.name =>'+crmsQ.name+'\n';
			crmsQ.description = "{{name}}";
			?'crmsQ.description =>'+crmsQ.description+'\n';
			var a = wom.getEntityFromString('com.webridge.entity.Entity[OID[5A67B5F619549944A1117B02429E8F02]]');
			if(crmsQ.status == null){
				crmsQ.status = a;
				?'crmsQ.status =>'+a.ID+'\n';
		}

		/*
			2a. set primary sponsor
		*/
			var mainSponsor = crmsQ.customAttributes.primarySponsor;
			var a = ApplicationEntity.getResultSet("Company").query("customAttributes.organizationCustomExtension.customAttributes.masterID = '{{studyDetails.fundingSponsorPrimary.id}}'");
			if(a.count>0){
				a = a.elements().item(1);
				crmsQ.customAttributes.primarySponsor = a;
				?'crmsQ.customAttributes.primarySponsor =>'+crmsQ.customAttributes.primarySponsor+'\n';
			}

		/*
			2b. set other sponsor[SET]
		*/
			var otherSponsorSet;
			if(crmsQ.customAttributes.otherSponsors == null){
				var a = ApplicationEntity.createEntitySet("Company");
				crmsQ.customAttributes.otherSponsors = a;
				?'crmsQ.customAttributes.otherSponsors =>'+crmsQ.customAttributes.otherSponsors+'\n';
			}
			otherSponsorSet = crmsQ.customAttributes.otherSponsors;
			{{#each studyDetails.fundingSponsorSecondary}}
				{{#if fundingSponsor.organizationCustomExtension.ID}}
					var a = ApplicationEntity.getResultSet("Company").query("customAttributes.organizationCustomExtension.customAttributes.masterID = '{{fundingSponsor.organizationCustomExtension.masterID}}'");
					if(a.count()>0){
						var organization = a.elements().item(1);
						?'organization found =>'+organization+'\n';
						otherSponsorSet.addElement(organization);
						?'Added to set =>'+organization+'\n';
					}
				{{/if}}
			{{/each}}
		
		/*
			2c. set is Cancer Related
			//researchCancerRelated => isOncologyStudy
		*/
			var isCancerRelated = {{studyDetails.researchCancerRelated}};
			if(isCancerRelated == 0){
				crmsQ.customAttributes.isOncologyStudy = false;
				?'isOncologyStudy => false\n';
			}
			else{
				crmsQ.customAttributes.isOncologyStudy = true;
				?'isOncologyStudy => true\n';
			}

		/*
			2d. create/set Locations
		*/
			var belleuveLocation = crmsQ.customAttributes.locationsBellevue;
			var offsiteFGPLocation = crmsQ.customAttributes.locationsOffsiteFgp;
			var vaLocation = crmsQ.customAttributes.locationsVA;
			var nyuSchoolOrCollegeLocation = crmsQ.customAttributes.nyuSchoolCollegeLocation;
			var nyumcLocation = crmsQ.customAttributes.nyumcLocations;
			var otherLocation = crmsQ.customAttributes.otherNYULocations;

			if(belleuveLocation == null){
				var locationSet = _NYULocations.createEntitySet();
				crmsQ.customAttributes.locationsBellevue = locationSet;
				?'Created Belleuve Set =>'+locationSet+'\n';
			}

			if(offsiteFGPLocation == null){
				var locationSet = _NYULocations.createEntitySet();
				crmsQ.customAttributes.locationsOffsiteFgp = locationSet;
				?'Created Offsite FGP Set =>'+locationSet+'\n';
			}

			if(vaLocation == null){
				var locationSet = _NYULocations.createEntitySet();
				crmsQ.customAttributes.locationsVA = locationSet;
				?'Created VA Hospital Set =>'+locationSet+'\n';
			}

			if(nyuSchoolOrCollegeLocation == null){
				var locationSet = _NYULocations.createEntitySet();
				crmsQ.customAttributes.nyuSchoolCollegeLocation = locationSet;
				?'Created NYU School or College Set =>'+locationSet+'\n';
			}

			if(nyumcLocation == null){
				var locationSet = _NYULocations.createEntitySet();
				crmsQ.customAttributes.nyumcLocations = locationSet;
				?'Created NYUMC Set =>'+locationSet+'\n';
			}

			if(otherLocation == null){
				var locationSet = _NYULocations.createEntitySet();
				crmsQ.customAttributes.otherNYULocations = locationSet;
				?'Created Other NYU Set =>'+locationSet+'\n';
			}

			{{#each studyDetails.bellevueLocations}}
				var location = ApplicationEntity.getResultSet('_NYULocations').query("ID='{{ID}}'").elements().item(1);
				crmsQ.setQualifiedAttribute("customAttributes.locationsBellevue", location, "add");
				?'adding belleuve location =>'+location+'\n';
			{{/each}}

			{{#each studyDetails.nyuSchoolCollegeLocations}}
				var location = ApplicationEntity.getResultSet('_NYULocations').query("ID='{{ID}}'").elements().item(1);
				crmsQ.setQualifiedAttribute("customAttributes.nyuSchoolCollegeLocation", location, "add");
				?'adding belleuve location =>'+location+'\n';
			{{/each}}

			{{#each studyDetails.nyufgpLocations}}
				var location = ApplicationEntity.getResultSet('_NYULocations').query("ID='{{ID}}'").elements().item(1);
				crmsQ.setQualifiedAttribute("customAttributes.locationsOffsiteFgp", location, "add");
				?'adding offsite FGP location =>'+location+'\n';
			{{/each}}

			{{#each studyDetails.nyumcLocations}}
				var location = ApplicationEntity.getResultSet('_NYULocations').query("ID='{{ID}}'").elements().item(1);
				crmsQ.setQualifiedAttribute("customAttributes.nyumcLocations", location, "add");
				?'adding NYUMC location =>'+location+'\n';
			{{/each}}

			{{#each studyDetails.otherLocations}}
				var location = ApplicationEntity.getResultSet('_NYULocations').query("ID='{{ID}}'").elements().item(1);
				crmsQ.setQualifiedAttribute("customAttributes.otherNYULocations", location, "add");
				?'adding Other location =>'+location+'\n';
			{{/each}}

			{{#each studyDetails.vaHospitalLocations}}
				var location = ApplicationEntity.getResultSet('_NYULocations').query("ID='{{ID}}'").elements().item(1);
				crmsQ.setQualifiedAttribute("customAttributes.locationsVA", location, "add");
				?'adding Other location =>'+location+'\n';
			{{/each}}

		/*
			2e. add sets(person) => otherStudyStaff, researchCoordinators, subInvestigators, team Volunteers(-- Need to create new eset) -- not done
		*/
			var otherStaff = crmsQ.customAttributes.otherStudyStaff;
			var researchCoor = crmsQ.customAttributes.researchCoordinators;
			var subInves = crmsQ.customAttributes.subInvestigators;

			if(otherStaff == null){
				var a = ApplicationEntity.createEntitySet("Person");
				crmsQ.customAttributes.otherStudyStaff = a;
				?'Created otherStudyStaff Set =>'+crmsQ.customAttributes.otherStudyStaff+'\n';
				otherStaff = crmsQ.customAttributes.otherStudyStaff;
			}

			if(researchCoor == null){
				var a = ApplicationEntity.createEntitySet("Person");
				crmsQ.customAttributes.researchCoordinators = a;
				?'Created researchCoordinators Set =>'+crmsQ.customAttributes.researchCoordinators+'\n';
				researchCoor = crmsQ.customAttributes.researchCoordinators;
			}

			if(subInves == null){
				var a = ApplicationEntity.createEntitySet("Person");
				crmsQ.customAttributes.subInvestigators = a;
				?'Created subInvestigators Set =>'+crmsQ.customAttributes.subInvestigators+'\n';
				subInves = crmsQ.customAttributes.subInvestigators;
			}

			{{#each studyDetails.otherStudyStaff}}
				var person = ApplicationEntity.getResultSet("Person").query("userID = '{{userId}}'");
				if(person.count()>0){
					person = person.elements().item(1);
					otherStaff.addElement(person);
					?'Added person to otherStudyStaff =>'+person+'\n';
					contacts.addElement(person);
					?'Added person to contacts =>'+person+'\n';
				}
			{{/each}}

			{{#each studyDetails.researchCoordinators}}
				var person = ApplicationEntity.getResultSet("Person").query("userID = '{{coordinator.userId}}'");
				if(person.count()>0){
					person = person.elements().item(1);
					researchCoor.addElement(person);
					?'Added person to researchCoordinators =>'+person+'\n';
					contacts.addElement(person);
					?'Added person to contacts =>'+person+'\n';
				}
			{{/each}}

			{{#each studyDetails.teamSubInvestigators}}
				var person = ApplicationEntity.getResultSet("Person").query("userID = '{{userId}}'");
				if(person.count()>0){
					person = person.elements().item(1);
					subInves.addElement(person);
					?'Added person to subInvestigator =>'+person+'\n';
					contacts.addElement(person);
					?'Added person to contacts =>'+person+'\n';
				}
			{{/each}}
			
		/*
			2f. Set properties.
		*/
			// force creation of custom property and initialize default values
			var newOncologyProperties = _CTOncologyProperties.createEntity();
			newOncologyProperties.setQualifiedAttribute("customAttributes.studyIdentifier", ""); // triggers load of default property values	
			?'_CTOncologyProperties.studyIdentifier =>'+newOncologyProperties.customAttributes.studyIdentifier+'\n';

			crmsQ.setQualifiedAttribute("customAttributes.oncologyProperties", newOncologyProperties);
			?'set crmsQ.oncologyProperties =>'+crmsQ.customAttributes.oncologyProperties+'\n';

			// Inflation Markup Rates(_InflationMarkup) must be initialized.
			crmsQ.setQualifiedAttribute("customAttributes.inflationMarkup", CustomUtils.createEntityWithCAM("_InflationMarkup"));
			?'set crmsQ.inflationMarkup =>'+crmsQ.customAttributes.inflationMarkup+'\n';

			crmsQ.setQualifiedAttribute("customAttributes.fixedCostInformation", CustomUtils.createEntityWithCAM("_CTFinancialInformation"));
			?'set crmsQ.fixedCostInformation =>'+crmsQ.customAttributes.fixedCostInformation+'\n';

			crmsQ.setQualifiedAttribute("customAttributes.costInformation", CustomUtils.createEntityWithCAM("_CTFinancialInformation"));
			?'set crmsQ.costInformation =>'+crmsQ.customAttributes.costInformation+'\n';

			// Initialize Indirect Rates
			var newDE = wom.createEntity("_IndirectRateScheduleDataEntry");
			crmsQ.setQualifiedAttribute("customAttributes.indirectRate", newDE);
			?'crmsQ.indirectRate =>'+crmsQ.customAttributes.indirectRate+'\n';

			var newSEL = wom.createEntity("_IndirectRateScheduleSelection");
			var totalDirectType = EntityUtils.getObjectFromString("com.webridge.entity.Entity[OID[FB19F6CCCA752C4088F3938AFDF660AC]]");
			newSEL.setQualifiedAttribute("customAttributes.name", "Clinical Trials standard rate");
			newSEL.setQualifiedAttribute("customAttributes.rate", 0.30);
			newSEL.setQualifiedAttribute("customAttributes.type", totalDirectType );
			newDE.setQualifiedAttribute("customAttributes.indirectRateScheduleSelection", newSEL);
			?'IndirectRateScheduleDataEntry.customAttributes.indirectRateScheduleSelection =>'+newSEL+'\n';
			
			var generalRateSchedule = EntityUtils.getObjectFromString("com.webridge.entity.Entity[OID[CBC0C0B697605447945F1E4ED578FB02]]");
			var grid = Grid.create(crmsQ);
						
			crmsQ.setQualifiedAttribute("customAttributes.grid", grid);
			?'set crmsQ.grid =>'+crmsQ.customAttributes.grid+'\n';
			
		/*
			3a. Create Budget
		*/
			var sponsorSet = Company.createEntitySet();
			var primarySponsor = crmsQ.getQualifiedAttribute("customAttributes.primarySponsor");
			var otherSponsors = crmsQ.getQualifiedAttribute("customAttributes.otherSponsors");
			var primaryBudget = crmsQ.getQualifiedAttribute("customAttributes.primaryBudget");

			if (primarySponsor && primaryBudget == null){
				sponsorSet.addElement(primarySponsor);
				?'Adding primary sponsor to sponsor set =>'+primarySponsor+'\n';
			}

			if (otherSponsors && otherSponsors.count() > 0 ) {
			  sponsorSet.addAll(otherSponsors);
			  ?'Adding other sponsor to sponsor set =>'+otherSponsors+'\n';
			}

			var projects = crmsQ.projects;
			if (projects == null) {
				projects = Project.createEntitySet();
				crmsQ.projects = projects;
				?'created crmsQ.projects =>'+crmsQ.projects+'\n';
			}

			var contracts = projects.filterBySubtypeAndCast("_ClinicalTrialContract");
			var contractsForSponsors = contracts.query("customAttributes.sponsor is not null");
			var contractsForOtherSponsors = contracts.query("customAttributes.sponsor is not null and customAttributes.isPrimarySponsor = false");
			var sponsorsToAdd = sponsorSet.difference(contractsForSponsors.dereference("customAttributes.sponsor")).elements();
			var contractsToRemove = contractsForOtherSponsors.difference(contractsForOtherSponsors.keyIntersection("customAttributes.sponsor", otherSponsors)).elements();

			var sponsorsToAddCount = sponsorsToAdd.count();
			var sponsor;
			var isPrimarySponsor;
			var sponsorAdded;

			for (var i = 1; i <= sponsorsToAddCount; i++) {
				sponsor = sponsorsToAdd.item(i);
				isPrimarySponsor = (sponsor==primarySponsor);
				?'sponsor name =>'+sponsor.name+'\n';
				sponsorAdded = _ClinicalTrialContract.create(sponsor, false, "Budget for " + sponsor.name, crmsQ,isPrimarySponsor);
				ProjectStateTransition.processProject(null, null, sponsorAdded, null);
		
			}

		/*
			4a. Create Default Arm
		*/
			_ClinicalTrialArm.create("Clinical Trial Arm 1", crmsQ);
			?'create ClinicalTrialArm =>'+crmsQ.customAttributes.arms+'\n';
			var arms = crmsQ.customAttributes.arms;
			for(var i = 1; i<=arms.count(); i++ ){
				var arms_1 = arms.elements().item(i);
				arms_1.setQualifiedAttribute('customAttributes.expectedEnrollment', {{studyDetails.subjectAnalysis.targetedAccrual}});
				?'set arms expectedEnrollment =>'+arms_1.customAttributes.expectedEnrollment+'\n';
			}
	}
	else{
		crmsQ = crmsQ.elements().item(1);
		?'CRMS Study found => '+crmsQ+'\n';
		?'CRMS Study ID => '+crmsQ.ID+'\n';

		crmsQ.dateModified = new Date();
		?'crmsQ.dateModified =>'+crmsQ.dateModified+'\n';
		
	}
}
else{
	?'Error: Status is not submitted\n';
	?'RN Study ID =>{{id}}\n';
	?'current status =>{{status}}\n';
}
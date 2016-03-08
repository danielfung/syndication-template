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

{{#if submissionType}}
//IRB UPDATE
	if(submissionStatus == "Approved"){
		if(rnumberQ.count() > 0){
			rnumberQ = rnumberQ.elements().item(1);
			?'RN Study Found => '+rnumberQ.ID+'\n';
			var studyDetails = rnumberQ.customAttributes.studyDetails;
			if(studyDetails != null){			
				/*
					1a. Update Locations From IRB => My Studies 
					 	- A. Create Eset if does not exist, else emtpy the esets -- done
					 	- B. Add back to eset based on what is in IRB -- not done yet
				*/
				var locationBellevue = studyDetails.customAttributes.bellevueLocations;
				var locationNyuFGP = studyDetails.customAttributes.nyufgpLocations;
				var locationNyuSchoolCollege = studyDetails.customAttributes.nyuSchoolCollegeLocations;
				var locationNyumc = studyDetails.customAttributes.nyumcLocations;
				var locationOther = studyDetails.customAttributes.otherLocations;
				var locationVaHospital = studyDetails.customAttributes.vaHospitalLocations;

				if(locationsBellevue == null){
					?'Bellevue Location Eset Not Found\n';
					var a = ApplicationEntity.createEntitySet('_NYULocations');
					studyDetails.setQualifiedAttribute('customAttributes.bellevueLocations', a);
					locationBellevue = studyDetails.customAttributes.bellevueLocations;
					?'create Bellevue Location Eset => '+locationBellevue+'\n';
				}
				else{
					?'Bellevue Location Eset Found => '+locationBellevue+'\n';
					locationBellevue.removeAllElements();
					locationBellevue = studyDetails.customAttributes.bellevueLocations;
				}

				if(locationNyuFGP == null){
					?'NYUFGP Location Eset Not Found\n';
					var a = ApplicationEntity.createEntitySet('_NYULocations');
					studyDetails.setQualifiedAttribute('customAttributes.nyufgpLocations', a);
					locationNyuFGP = studyDetails.customAttributes.nyufgpLocations;
					?'create FGP Location Eset => '+locationNyuFGP+'\n';
				}
				else{
					?'NYUFGP Location Eset Found => '+locationNyuFGP+'\n';
					locationNyuFGP.remoevAllElements();
					locationNyuFGP = studyDetails.customAttributes.nyufgpLocations;
				}

				if(locationNyuSchoolCollege == null){
					?'NYU School or College Location Eset not found\n';
					var a = ApplicationEntity.createEntitySet('_NYULocations');
					studyDetails.setQualifiedAttribute('customAttributes.nyuSchoolCollegeLocations', a);
					locationNyuSchoolCollege = studyDetails.customAttributes.nyuSchoolCollegeLocations;
					?'create NYU School or College Location Eset => '+locationNyuSchoolCollege+'\n';
				}
				else{
					?'NYU School or College Location Eset Found => '+locationNyuSchoolCollege+'\n';
					locationNyuSchoolCollege.removeAllElements();
					locationNyuSchoolCollege = studyDetails.customAttributes.nyuSchoolCollegeLocations;
				}

				if(locationNyumc == null){
					?'NYUMC Location Eset not found\n';
					var a = ApplicationEntity.createEntitySet('_NYULocations');
					studyDetails.setQualifiedAttribute('customAttributes.nyumcLocations', a);
					locationNyumc = studyDetails.customAttributes.nyumcLocations;
					?'create NYUMC Location Eset => '+locationNyumc+'\n';
				}
				else{
					?'NYUMC Location Eset Found => '+locationNyumc+'\n';
					locationNyumc.removeAllElements();
					locationNyumc = studyDetails.customAttributes.nyumcLocations;
				}

				if(locationOther == null){
					?'Other Location Eset not found\n';
					var a = ApplicationEntity.createEntitySet('_NYULocations');
					studyDetails.setQualifiedAttribute('customAttributes.otherLocations', a);
					locationOther = studyDetails.customAttributes.otherLocations;
					?'create Other Location Eset => '+locationOther+'\n';
				}
				else{
					?'Other Location Eset Found => '+locationOther+'\n';
					locationOther.removeAllElements();
					locationOther = studyDetails.customAttributes.otherLocations;
				}

				if(locationVaHospital == null){
					?'VA Hospital Location Eset not found\n';
					var a = ApplicationEntity.createEntitySet('_NYULocations');
					studyDetails.setQualifiedAttribute('customAttributes.vaHospitalLocations', a);
					locationVaHospital = studyDetails.customAttributes.vaHospitalLocations;
					?'create VA Hospital Location Eset => '+locationVaHospital+'\n';
				}
				else{
					?'VA Hospital Location Eset Found => '+locationVaHospital+'\n';
					locationVaHospital.removeAllElements();
					locationVaHospital = studyDetails.customAttributes.vaHospitalLocations;
				}

				/*
					1b. Update Study Teaam Members(Sub Investigator, Research Coordinator, Other Study Staff, Team Members with read Only Access, Volunteer Study Staff)
				*/

				var subInvestigatorEset = studyDetails.customAttributes.teamSubInvestigators;
				var researchCoordEset = studyDetails.customAttributes.researchCoordinators;
				var otherStudyTeamEset = studyDetails.customAttributes.otherStudyStaff;
				var teamMemberReadEset = studyDetails.customAttributes.teamCanNotEdit;
				var volunteerEset = studyDetails.customAttributes.teamVolunteers;

				//Team Sub Investigator
				if(subInvestigatorEset == null){
					?'Sub Investigator Eset not found => '+subInvestigatorEset+'\n';
					var a = ApplicationEntity.createEntitySet('Person');
					studyDetails.setQualifiedAttribute('customAttributes.teamSubInvestigators', a);
					subInvestigatorEset = studyDetails.customAttributes.teamSubInvestigators;
					?'created sub investigator eset => '+subInvestigatorEset+'\n';

				}
				else{
				    ?'Sub Investigator Eset found => '+subInvestigatorEset+'\n';
				    subInvestigatorEset.removeAllElements();
					subInvestigatorEset = studyDetails.customAttributes.teamSubInvestigators;
				}

				//Research Coordinator
				if(researchCoordEset == null){
					?'Sub Investigator Eset not found => '+researchCoordEset+'\n';
					var a = ApplicationEntity.createEntitySet('Person');
					studyDetails.setQualifiedAttribute('customAttributes.researchCoordinators', a);
					researchCoordEset = studyDetails.customAttributes.researchCoordinators;
					?'created sub investigator eset => '+researchCoordEset+'\n';

				}
				else{
				    ?'Sub Investigator Eset found => '+researchCoordEset+'\n';
				    researchCoordEset.removeAllElements();
					researchCoordEset = studyDetails.customAttributes.researchCoordinators;
				}

				//Other Study Team Member 
				if(otherStudyTeamEset == null){
					?'Sub Investigator Eset not found => '+otherStudyTeamEset+'\n';
					var a = ApplicationEntity.createEntitySet('Person');
					studyDetails.setQualifiedAttribute('customAttributes.otherStudyStaff', a);
					otherStudyTeamEset = studyDetails.customAttributes.otherStudyStaff;
					?'created sub investigator eset => '+otherStudyTeamEset+'\n';

				}
				else{
				    ?'Sub Investigator Eset found => '+otherStudyTeamEset+'\n';
				    otherStudyTeamEset.removeAllElements();
					otherStudyTeamEset = studyDetails.customAttributes.otherStudyStaff;
				}

				//Team Member - Read Only
				if(teamMemberReadEset == null){
					?'Sub Investigator Eset not found => '+teamMemberReadEset+'\n';
					var a = ApplicationEntity.createEntitySet('Person');
					studyDetails.setQualifiedAttribute('customAttributes.teamCanNotEdit', a);
					teamMemberReadEset = studyDetails.customAttributes.teamCanNotEdit;
					?'created sub investigator eset => '+teamMemberReadEset+'\n';

				}
				else{
				    ?'Sub Investigator Eset found => '+teamMemberReadEset+'\n';
				    teamMemberReadEset.removeAllElements();
					teamMemberReadEset = studyDetails.customAttributes.teamCanNotEdit;
				}


				//Volunteer
				if(volunteerEset == null){
					?'Sub Investigator Eset not found => '+volunteerEset+'\n';
					var a = ApplicationEntity.createEntitySet('Person');
					studyDetails.setQualifiedAttribute('customAttributes.teamVolunteers', a);
					volunteerEset = studyDetails.customAttributes.teamVolunteers;
					?'created sub investigator eset => '+volunteerEset+'\n';

				}
				else{
				    ?'Sub Investigator Eset found => '+volunteerEset+'\n';
				    volunteerEset.removeAllElements();
					volunteerEset = studyDetails.customAttributes.teamVolunteers;
				}
	 		}
			else{
				?'Error => {{id}} studyDetails is null \n';
			}
		}
		else{
			?'RN Study Not Found =>'+rnumber_id+'\n';
			?'IRB Study ID => {{id}}\n';
		}
	}
	else{
		?'IRB Status is not approved => {{id}}\n';
	}
{{/if}}
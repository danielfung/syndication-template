{{#if _uid}}
	var rnumber_id = "{{this._uid}}";
	rnumber_id = "s"+rnumber_id;
{{else}}
	var rnumber_id = "{{this.id}}";
	rnumber_id = rnumber_id.replace(/[^\d.-]/g, '');
	rnumber_id = "s"+rnumber_id;
{{/if}}

?'RN Study ID => '+rnumber_id+'\n';

var rnumber;
var rnumberQ = ApplicationEntity.getResultSet('_Research Project').query("ID='"+rnumber_id+"'");
?'rnumberQ.count() => '+rnumbeerQ.count()+'\n';

{{#if submissionType}}
//IRB UPDATE
	if(rnumberQ.count() > 0){
		rnumberQ = rnumberQ.elements().item(1);
		?'RN Study Found => '+rnumberQ.ID+'\n';
		var studyDetails = rnumberQ.customAttributes.studyDetails;
		if(studyDetails != null){			
			/*
				1a. Update Locations From IRB => My Studies
			*/
			var locationBellevue = studyDetails.customAttributes.bellevueLocations;
			var locationNyuFGP = studyDetails.customAttributes.nyufgpLocations;
			var locationNyuSchoolCollege = studyDetails.customAttributes.nyuSchoolCollegeLocations;
			var locationNyumc = studyDetails.customAttributes.nyumcLocations;
			var locationOther = studyDetails.customAttributes.otherLocations;
			var locationVaHospital = studyDetails.customAttributes.vaHospitalLocations;

			if(locationsBellevue == null){
				?'Bellevue Location Eset Not Found\n';
			}
			else{
				?'Bellevue Location Eset Found => '+locationBellevue+'\n';
			}

			if(locationNyuFGP == null){
				?'NYUFGP Location Eset Not Found\n';
			}
			else{
				?'NYUFGP Location Eset Found => '+locationNyuFGP+'\n';
			}

			if(locationNyuSchoolCollege == null){
				?'NYU School or College Location Eset not found\n';
			}
			else{
				?'NYU School or College Location Eset Found => '+locationNyuSchoolCollege+'\n';
			}

			if(locationNyumc == null){
				?'NYUMC Location Eset not found\n';
			}
			else{
				?'NYUMC Location Eset Found => '+locationNyumc+'\n';
			}

			if(locationOther == null){
				?'Other Location Eset not found\n';
			}
			else{
				?'Other Location Eset Found => '+locationOther+'\n';
			}

			if(locationVaHospital == null){
				?'VA Hospital Location Eset not found\n';
			}
			else{
				?'VA Hospital Location Eset Found => '+locationVaHospital+'\n';
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
{{/if}}

{{#if typeOfSubmission}}
//IACUC UPDATE
	if(rnumberQ.count() > 0){
		rnumberQ = rnumberQ.elements().item(1);
		?'RN Study Found => '+rnumberQ.ID+'\n';

	}
	else{
		?'RN Study Not Found =>'+rnumber_id+'\n';
		?'IACUC Study ID => {{id}}\n';
	}
{{/if}}
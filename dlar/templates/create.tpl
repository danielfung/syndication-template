{{#if protocolNumber}}
	var iacuc_id = "{{protocolNumber}}";
	var find = iacuc_id.split('-')[0];
	?'ID for syndication => '+iacuc_id+'\n';
{{else}}
	var iacuc_id ="{{this.id}}";
{{/if}}

var iacucStudyID = {{id}};
var index = iacucStudyID.indexOf("TZ:");
var iacucQ;
if(index > -1){
	iacuc_id = iacucStudyID;
	?'DATA MIGRATION STUDY USE ID INSTEAD OF PROTOCOL NUMBER\n';
	iacucQ = ApplicationEntity.getResultSet('_IACUC Study').query("ID = '"+iacuc_id+"%'");
}
else{
	iacucQ = ApplicationEntity.getResultSet('_IACUC Study').query("ID like '"+find+"%'");
}

var status = '{{status}}';

var submissionType = '{{typeOfSubmission.id}}';

var iacuc;
//var iacucQ = ApplicationEntity.getResultSet('_IACUC Study').query("ID='"+iacuc_id+"'");
//var iacucQ = ApplicationEntity.getResultSet('_IACUC Study').query("ID like '"+find+"%'");
if(submissionType == 'PROTOYYYY'){
	
	if(status == "Approved"){
		?'IACUC ID =>'+iacuc_id+'\n';
		?'iacucQ.count() =>'+iacucQ.count()+'\n';
		/*
			1. Create iacuc Submission if it doesn't exist.
		*/
		if(iacucQ.count() == 0){

			{{> integrationDlarOrigCreate}}

		}
		else{
			{{> integrationDlarOrigUpdate}}
		}

	}
	else{
		?'Error: Status is not Approved\n';
		?'IACUC Study ID: {{id}}\n';
		?'current status =>{{status}}\n';
	}	
}
else if(submissionType == 'AMENDYYYY'){
	if(status == "Approved"){
		if(iacucQ.count()> 0){
			iacucQ = iacucQ.elements().item(1);
			?'SubmissionType => Amendment\n';
			?'DLAR(IACUC Study) to update => '+iacucQ.ID+'\n';
		}
		else{
			?'Error: Cant Find Study =>{{protocolNumber}}';
		}
	}
	else{
		?'Error: Status is not Approved\n';
		?'IACUC Study ID: {{id}}\n';
		?'current status =>{{status}}\n';	
	}
}
else{
	?'Error: SubmissionType is not PROTOYYYY OR AMENDYYYY\n';
	?'IACUC Study ID: {{id}}\n';
	?'current status =>{{typeOfSubmission.id}}\n';
}
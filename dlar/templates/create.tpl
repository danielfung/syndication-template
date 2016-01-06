{{#if protocolNumber}}
	var iacuc_id = "{{protocolNumber}}";
	//var find = iacuc_id.split('-')[0];
	var itemToFind = iacuc_id.lastIndexOf("-");
    var find = iacuc_id.substring(0, itemToFind);
    ?'find => '+find+'\n';
	?'ID for syndication => '+iacuc_id+'\n';
	var find_1 = find+'-';

	//use to strip prefix/suffix - 12/07/2015  -- UNCOMMENT WHEN TIME TO USE
	
	var prefixID = iacuc_id.substring(0, itemToFind);;
	var suffixID = iacuc_id.substring(itemToFind+1);
	

{{else}}
	var iacuc_id ="{{this.id}}";
{{/if}}


var index = iacuc_id.indexOf("-");
var iacucQ;
if(index > -1){
	iacucQ = ApplicationEntity.getResultSet('_IACUC Study').query("ID like '"+find_1+"%'");
	?'protocolNumber contains - using id like => '+find_1+'\n';
	
}
else{
	iacucQ = ApplicationEntity.getResultSet('_IACUC Study').query("ID='"+iacuc_id+"'");
	?'protocolNumber does not contain - using id = => '+iacuc_id+'\n';
}

//use to strip prefix/suffix - 12/07/2015  -- UNCOMMENT WHEN TIME TO USE

	iacucQ = ApplicationEntity.getResultSet('_IACUC Study').query("ID='"+prefixID+"'");
	?'find protocolNumber - using id = => '+prefixID+'\n';


var status = '{{status}}';

var submissionType = '{{typeOfSubmission.id}}';

var currentItemID = '{{id}}';
var parentID = '{{parentProtocol.id}}';

var iacuc;
//var iacucQ = ApplicationEntity.getResultSet('_IACUC Study').query("ID='"+iacuc_id+"'");
//iacucQ = ApplicationEntity.getResultSet('_IACUC Study').query("ID like '"+find_1+"%'");
if(submissionType == 'PROTOYYYY' || (currentItemID == parentID)){
	
	if(status == "Approved"){
		?'IACUC ID =>'+iacuc_id+'\n';
		?'iacucQ.count() =>'+iacucQ.count()+'\n';
		/*
			1. Create iacuc Submission if it doesn't exist.
		*/
		if(iacucQ.count() == 0){

			{{> integrationDlarOrigCreate}}

		}
		else if(iacucQ.count() == 1){
			{{> integrationDlarOrigUpdate}}
		}
		else{
			?'More than one protocol found in DLAR => '+iacucQ.count()+'\n';
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
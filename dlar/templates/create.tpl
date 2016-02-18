{{#if protocolNumber}}
	var iacuc_id = "{{protocolNumber}}";
	//var find = iacuc_id.split('-')[0];
	var itemToFind = iacuc_id.lastIndexOf("-");
    var find = iacuc_id.substring(0, itemToFind);
    ?'find => '+find+'\n';
	?'ID for syndication => '+iacuc_id+'\n';
	var find_1 = find+'-';

	var prefixID;
	var suffixID;
	//use to strip prefix/suffix - 12/07/2015  -- UNCOMMENT WHEN TIME TO USE
	if(itemToFind > -1){
		prefixID = iacuc_id.substring(0, itemToFind);
		suffixID = iacuc_id.substring(itemToFind+1);
		?'prefixID => '+prefixID+'\n';
		?'suffixID => '+suffixID+'\n';
	}
	else{
		prefixID = iacuc_id;
		suffixID = '';
		?'prefixID => '+prefixID+'\n';
		?'suffixID => '+suffixID+'\n';
	}
	

{{else}}
	var iacuc_id ="{{this.id}}";
{{/if}}

/*
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
*/

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
	else if(status == "Suspended"){
		if(iacucQ.count() == 1){
			iacucQ = iacucQ.elements().item(1);
			var suspendedProtocolActivity = ActivityType.getActivityType("_IACUC Study_MarkSuspended", "_IACUC Study");
			if(createProtocolActivity != null){
				iacucQ.logActivity(sch, suspendedProtocolActivity, Person.getCurrentUser());
				?'Logging suspended activity => '+suspendedProtocolActivity+'\n';
			}
		}
	}
	else if(status == "Closed"){
		if(iacucQ.count() == 1){
			iacucQ = iacucQ.elements().item(1);
			var closedStatusDCM = entityUtils.getObjectFromString('com.webridge.entity.Entity[OID[E74C789848FF194D9508D08A248FB788]]');
			iacucQ.customAttributes.status = closedStatusDCM;
			?'IACUC Study Closed => Change DCM Status to Closed => '+iacucQ.status.ID+'\n';
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
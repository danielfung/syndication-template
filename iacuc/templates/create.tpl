{{#if _uid}}
	var iacuc_id = "{{this._uid}}";
	var iacucREALID = "{{this.id}}";
	var checkLegacyIndex = iacucREALID.indexOf('TZ:');
	if(checkLegacyIndex > -1){
		iacuc_id = iacucREALID;
		?'is legacy iacuc study use TZ: instead => '+iacuc_id+'\n';
	}else{
		//iacuc_id = iacuc_id.split('-')[1];
		//var currentYear = new Date().getFullYear();
		//iacuc_id = 'PROTO'+currentYear+iacuc_id;
		iacuc_id = "IA"+iacuc_id;
		?'is not leagcy study use IA instead => '+iacuc_id+'\n';
	}
{{else}}
	var iacuc_id ="{{this.id}}";
{{/if}}
?'IACUC ID =>'+iacuc_id+'\n';

{{#if assignNumber}}
//DCM Update
	var iacuc_id = "{{this.assignNumber}}";
	?'DCM UPDATE ---> iacuc_id => {{this.assignNumber}}\n';
{{/if}}

var iacuc;
var iacucQ = ApplicationEntity.getResultSet('_ClickIACUCSubmission').query("ID='"+iacuc_id+"'");
?'iacucQ.count() =>'+iacucQ.count()+'\n';

{{#if topaz.draftProtocol}}
/*
	DRAFT PROTOCOL IN JSON - LEGACY
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
			{{> dataMigrationIacucOrigAmendCreate}}
		}
		else{
			{{> dataMigrationIacucOrigAmendUpdate}}
		}
		{{else}}
			?'Error=> Missing protocolType\n';
			?'IACUC ID => {{ID}}\n';
			?'protocolType => {{topaz.protocolType.oid}}\n';
			?'submissionType => {{topaz.submissionType.oid}}\n';
		{{/if}}
	{{else}}
		?'Error=> Missing submissionType\n';
		?'IACUC ID => {{ID}}\n';
		?'protocolType => {{topaz.protocolType.oid}}\n';
		?'submissionType => {{topaz.submissionType.oid}}\n';
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
				{{> dataMigrationIacucOrigCreate}}

			}
			else{
				{{> dataMigrationIacucOrigUpdate}}
			}
		{{else}}
			?'Error=> Missing protocolType\n';
			?'IACUC ID => {{ID}}\n';
			?'protocolType => {{topaz.protocolType.oid}}\n';
			?'submissionType => {{topaz.submissionType.oid}}\n';
		{{/if}}
	{{else}}
		?'Error=> Missing submissionType\n';
		?'IACUC ID => {{ID}}\n';
		?'protocolType => {{topaz.protocolType.oid}}\n';
		?'submissionType => {{topaz.submissionType.oid}}\n';
	{{/if}}
{{/if}}

{{#if studyDetails}}
	{{#if studyDetails.iacucProtocol}}
	//copy IACUC protocol
	if(iacucQ.count() == 0){
		var subjectType = "{{studyDetails.subjectType.name}}";
		if(subjectType == "Animal"){
			var status = "{{status}}";
			if(status == "Submitted"){
				{{> integrationIacucOrigCreateExisting}}
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
				{{> integrationIacucOrigCreate}}

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
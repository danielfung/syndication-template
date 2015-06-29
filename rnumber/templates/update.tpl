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

{{#if }}
//IRB UPDATE
	if(rnumberQ.count() > 0){
		rnumberQ = rnumberQ.elements().item(1);
		?'RN Study Found => '+rnumberQ.ID+'\n';

	}
	else{
		?'RN Study Not Found =>'+rnumber_id+'\n';
		?'IRB Study ID => {{id}}\n';
	}
{{/if}}

{{#if investigator.studyTeamMember}}
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
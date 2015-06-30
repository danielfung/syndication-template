{{#if protocolNumber}}
	var iacuc_id = "{{protocolNumber}}";
{{else}}
	var iacuc_id ="{{this.id}}";
{{/if}}

?'DLAR ID =>'+iacuc_id+'\n';

var iacucQ = ApplicationEntity.getResultSet('_IACUC Study').query("ID='"+iacuc_id+"'");
?'iacucQ.count => '+iacucQ.count()+'\n';
if(iacucQ.count() > 0){
	iacucQ = iacucQ.elements().item(1);
	?'DLAR(IACUC Study) => '+iacucQ+'\n';

	/*
		1a. protocol team members => first clear the set, then re-add each study team member
	*/

	var protocolTeamMembers = iacucQ.customAttributes.protocolTeamMembers;

	if(protocolTeamMembers == null){
		var studyTeamMemberInfo = _StudyTeamMemberINfo.createEntitySet();
		iacucQ.setQualifiedAttribute('customAttributes.protocolTeamMembers', studyTeamMemberInfo);
		protocolTeamMembers = iacucQ.customAttributes.protocolTeamMembers;
		?'created iacucQ.customAttributes.protocolTeamMembers eset=>'+protocolTeamMembers+'\n';
	}
	else{
		?'DLAR(IACUC) protocolTeamMembers => '+protocolTeamMembers+'\n';
	}

	{{#each studyTeamMembers}}
		{{#if studyTeamMember.userId}}

		{{/if}}
	{{/each}}

	/*
		1b. check for isUsda(0 => if no animals isUSDA, else 1(a animal is usda))
	*/

	//check husbandary exceptions


}
else{
	?'DLAR(IACUC Study) Not Found => '+iacuc_id+'\n';
}
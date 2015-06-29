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
	
}
else{
	?'DLAR(IACUC Study) Not Found => '+iacuc_id+'\n';
}
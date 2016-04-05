var crms_id = "{{this._uid}}";
crms_id = 'c'+crms_id;
var crms;
var crmsQ = ApplicationEntity.getResultSet('_ClinicalTrial').query("ID='"+crms_id+"'");
?'crmsQ.count() =>'+crmsQ.count()+'\n';

var status = '{{status}}

function inArray(item,array)
{
    var count=array.length;
    for(var i=0;i<count;i++)
    {
        if(array[i]===item){return true;}
    }
    return false;
}

if(status == "Approved"){
	if(crmsQ.count() == 1){
		crmsQ = crmsQ.elements().item(1);
		?'CRMS Study found => '+crmsQ+'\n';



	}
	else{
		?'CRMS Study not found => do nothing since this is an IRB Update for this id => {{this._uid}}\n';
	}
}
else{
	?'IRB Status is not approved => {{status}} => for this ID => {{this._uid}}\n';
}
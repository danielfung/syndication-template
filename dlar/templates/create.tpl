{{#if _uid}}
	var iacuc_id = "{{this._uid}}";
	iacuc_id = iacuc_id.split('-')[1];
	var currentYear = new Date().getFullYear();
	iacuc_id = 'PROTO'+currentYear+iacuc_id;
{{else}}
	var iacuc_id ="{{this.id}}";
{{/if}}

?'IACUC ID =>'+iacuc_id+'\n';
var iacuc;
var iacucQ = ApplicationEntity.getResultSet('_IACUC Study').query("ID='"+iacuc_id+"'");
?'iacucQ.count() =>'+iacucQ.count()+'\n';

/*
	1. Create iacuc Submission if it doesn't exist.
*/
if(iacucQ.count() == 0){
	iacucQ = wom.createTransientEntity('_IACUC Study');
	?'DLAR.iacucQ =>'+iacucQ+'\n';

	/*
		1a. update ID of iacuc Submission
	*/

		iacucQ.ID = iacuc_id;
		?'iacucQ.ID =>'+iacucQ.ID+'\n';

	/*
		1b. Register and initalize iacuc Submission
	*/
		iacucQ.registerEntity();
		//iacucQ.initalize();
		//initalize
		var iacucQ = ApplicationEntity.getResultSet('_IACUC Study').query("ID='"+iacuc_id+"'").elements().item(1);

	/*
		1c. set required fields (owner, company, createdby, pi)
		if company not found --> default to MCIT
		if createdBy not found --> default to Sys Admin
		if PI not found --> leave empty
	*/
		{{#if company}}
			var company = iacucQ.company;
			if(company == null){
				var a = ApplicationEntity.getResultSet("Company").query("ID = '{{company.id}}'");
				if(a.count()>0){
					iacucQ.company = a.elements().item(1);
					?'iacucQ.company =>'+iacucQ.company+'\n';
				}
				else{
					?'Company Not Found =>{{company.id}}\n';
				}
			}
		{{else}}
			var company = ApplicationEntity.getResultSet("Company").query("NAME = 'MCIT'").elements().item(1);
			iacucQ.company = company;
			?'defaulting iacucQ.company => MCIT: '+company+'\n';

		{{/if}}

		//createdby - temporary
		{{#if createdBy.userId}}
			var create = iacucQ.createdBy;
			if(create == null){
				var person = ApplicationEntity.getResultSet("Person").query("userID = '{{createdBy.userId}}'");
				if(person.count() > 0){
					person = person.elements().item(1);
					iacucQ.createdBy = person;
					?'iacucQ.createdBy =>'+iacucQ.createdBy+'\n';
				}
				else{
					?'Person Not Found =>{{createdBy.userId}}\n';
					var person = ApplicationEntity.getResultSet("Person").query("userID = 'administrator'").elements().item(1);
					iacucQ.createdBy = person;
					?'defaulting iacucQ.createdBy => administrator: '+iacucQ.createdBy+'\n';
				}
			}
		{{else}}
			var person = ApplicationEntity.getResultSet("Person").query("userID = 'administrator'").elements().item(1);
			iacucQ.createdBy = person;
			?'defaulting iacucQ.createdBy => administrator: '+iacucQ.createdBy+'\n';

		{{/if}}

		//assigning PI to Study(IACUCQ)
		{{#if studyDetails.principalInvestigator.userId}}
			var investigator = iacucQ.getQualifiedAttribute("customAttributes._attribute7");

			var person = ApplicationEntity.getResultSet("Person").query("userID = '{{studyDetails.principalInvestigator.userId}}'").elements();
			
			if(investigator == null && person.count() > 0){
				person = person.item(1);
				iacucQ.setQualifiedAttribute("customAttributes._attribute7", person);
				?'person adding as PI =>'+person.userID+'\n';
			}
		{{/if}}


	/*
		1d. set irb status to Active
			set dateCreated/dateModified/date Approved(if avaliable);
	*/
		var status = iacucQ.status;
		if(status == null){
			var statusOID = ApplicationEntity.getResultSet('ProjectStatus').query("ID='Active'").elements().item(1);
			iacucQ.status = statusOID;
			?'iacucQ.status =>'+iacucQ.status.ID+'\n';
		}

		var dateCreate = iacucQ.dateCreated;
		if(dateCreate == null){
			iacucQ.dateCreated = new Date();
			?'iacucQ.dateCreated =>'+iacucQ.dateCreated+'\n';
		}

		var dateMod = iacucQ.dateModified;
		if(dateMod == null){
			iacucQ.dateModified = new Date();
			?'iacucQ.dateModified =>'+iacucQ.dateModified+'\n';
		}

		{{#if dateApproved}}
			var date = new Date('{{dateApproved}}');
			iacucQ.customAttributes._attribute6 = date;
			?'iacucQ.customAttributes._attribute6(dateApproved) =>'+date+'\n';
		{{/if}}
	
	/*
		1e. set resourceContainer.template
	*/
		var parentOID = "com.webridge.entity.Entity[OID[CBE99B3EEC5F2F4590DDF42629347777]]";
		theParent = EntityUtils.getObjectFromString(parentOID);
		var wsTemplate = EntityUtils.getObjectFromString("com.webridge.entity.Entity[OID[75AD149ED07BB7419E39441D9AFBC84B]]");
		var resourceContainer = iacucQ.resourceContainer;
		if(resourceContainer == null){
			if(wsTemplate != null && theParent != null){
				iacucQ.createWorkspace(theParent, wsTemplate);
				?'iacucQ.resourceContainer =>'+iacucQ.resourceContainer+'\n';
				?'iacucQ.resourceContainer.template =>'+iacucQ.resourceContainer.template+'\n';
			}
			else{
				?'Initial Template not found\n';
			}
		}

	/*
		1f. set name, shortDescription, longTitle
	*/
		iacucQ.name = "{{name}}";
		?'setting iacucQ name =>'+iacucQ.name+'\n';

		{{#if totalNumAnimal}}
		/*
			1g. set total study animals approved -- need attribute from iacuc->dlar(iacuc)
		*/
			iacucQ.customAttributes._attribute71 = {{totalNumAnimal}};
			?'setting total Number of animals for iacucQ=>'+{{totalNumAnimal}};
		{{/if}}


	/*
		2a. create departmentAdministrators(Person) Set
	*/
		var person = Person.createEntitySet();
		iacucQ.setQualifiedAttribute('customAttributes.departmentAdministrators',person)
		?'create iacucQ.customAttributes.departmentAdministrators=>'+person+'\n';
}
else{
	iacucQ = iacucQ.elements().item(1);
	?'DLAR.iacucQ protocol found =>'+iacucQ.ID+'\n';
	//update fields below total animal #.
}
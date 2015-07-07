{{#if id}}
	var animalOrder_id ="{{id}}";
	?'animal order ID for data migration => '+animalOrder_id+'\n';
{{else}}
	var animalOrder_id = _AnimalOrderTransfer.getID();
{{/if}}

?'IACUC ID =>'+animalOrder_id+'\n';
var iacuc;
var animalOrder = ApplicationEntity.getResultSet('_AnimalOrderTransfer').query("ID='"+animalOrder_id+"'");
?'animalOrder.count() =>'+animalOrder.count()+'\n';

var parentProtocol = ApplicationEntity.getResultSet('_IACUC Study').query("ID='{{topaz.parentProject.id}}'");

if(parentProtocol.count() > 0){
	/*
		1. Create Animal Order if it doesn't exist.
	*/
	if(animalOrder.count() == 0){
		animalOrder = wom.createTransientEntity('_AnimalOrderTransfer');
		?'DLAR.animalOrder =>'+animalOrder+'\n';

		/*
			1a. update ID of Animal Order
		*/

			animalOrder.ID = animalOrder_id;
			?'animalOrder.ID =>'+animalOrder.ID+'\n';

		/*
			1b. Register and initalize Animal Order
		*/
			animalOrder.registerEntity();
			//animalOrder.initalize();
			//initalize
			var animalOrder = ApplicationEntity.getResultSet('_AnimalOrderTransfer').query("ID='"+animalOrder_id+"'").elements().item(1);

		/*
			1c. set required fields (owner, company, createdby, pi)
			if createdBy not found --> default to Sys Admin
		*/
			{{#if createdBy.userId}}
				var create = animalOrder.createdBy;
				if(create == null){
					var person = ApplicationEntity.getResultSet("Person").query("userID = '{{createdBy.userId}}'");
					if(person.count() > 0){
						person = person.elements().item(1);
						animalOrder.createdBy = person;
						?'animalOrder.createdBy =>'+animalOrder.createdBy+'\n';
						var company = person.customAttributes.academicDepartment;
						if(company == null){
							company = ApplicationEntity.getResultSet("Company").query("name = 'MCIT'").elements().item(1);
							?'defaulting to MCIT, person's academicDepartment is null\n';
						}
						animalOrder.company = company;
						?'animalOrder.company =>'+animalOrder.company+'\n';
					}
					else{
						?'Person Not Found =>{{createdBy.userId}}\n';
						var person = ApplicationEntity.getResultSet("Person").query("userID = 'administrator'").elements().item(1);
						animalOrder.createdBy = person;
						?'defaulting animalOrder.createdBy => administrator: '+animalOrder.createdBy+'\n';
						var company = person.customAttributes.academicDepartment;
						if(company == null){
							company = ApplicationEntity.getResultSet("Company").query("name = 'MCIT'").elements().item(1);
						}
						animalOrder.company = company;
						?'animalOrder.company =>'+animalOrder.company+'\n';
					}
				}
			{{else}}
				var person = ApplicationEntity.getResultSet("Person").query("userID = 'administrator'").elements().item(1);
				animalOrder.createdBy = person;
				?'defaulting animalOrder.createdBy => administrator: '+animalOrder.createdBy+'\n';
				var company = person.customAttributes.academicDepartment;
				if(company == null){
					company = ApplicationEntity.getResultSet("Company").query("name = 'MCIT'").elements().item(1);
				}
				animalOrder.company = company;
				?'animalOrder.company =>'+animalOrder.company+'\n';
			{{/if}}


		/*
			1d. set irb status to Active
				set dateCreated/dateModified/date Approved(if avaliable);
				set customAttributes;
		*/
			{{#if topaz.status}}
				var status = animalOrder.status;
				if(status == null){
					var status = entityUtils.getObjectFromString('{{topaz.status.oid}}');
					animalOrder.status = status;
					?'animalOrder.status =>'+animalOrder.status+'\n';
				}
			{{/if}}

			var dateCreate = animalOrder.dateCreated;
			if(dateCreate == null){
				animalOrder.dateCreated = new Date();
				?'animalOrder.dateCreated =>'+animalOrder.dateCreated+'\n';
			}

			var dateMod = animalOrder.dateModified;
			if(dateMod == null){
				animalOrder.dateModified = new Date();
				?'animalOrder.dateModified =>'+animalOrder.dateModified+'\n';
			}
		/*
			1e. set resourceContainer.template (need to find current templates/containers for _AnimalOrderTransfer)
		*/

			var wsTemplate;
			var parent = ApplicationEntity.getResultSet('_IACUC Study').query("ID='{{topaz.parentProject.id}}'");
			var parentContainer;
			var status = animalOrder.status;
			var resourceContainer = animalOrder.resourceContainer;
			var defaultContainer = "com.webridge.entity.Entity[OID[CBE99B3EEC5F2F4590DDF42629347777]]";

			if(parent.count() > 0){
				parent = parent.elements().item(1);
				parentContainer = parent.resourceContainer;
				?'parentContainer => '+parentContainer+'\n';
			}
			else{
				parentContainer = EntityUtils.getObjectFromString(defaultContainer);
				?'default container => '+parentContainer+'\n';
			}

			if(status != null){
				if(status.ID == "Pre-Submission" || status.ID == "Cancel" || status.ID == "Fiscal Review"){
					wsTemplate = ContainerTemplate.getElements("ContainerTemplateForID", "ID", "TMPL4896DF6E19400").item(1);
				}
				else{
					wsTemplate = ContainerTemplate.getElements("ContainerTemplateForID", "ID", "TMPL4CFAD5EAE5C00").item(1);
				}

			}

			if(resourceContainer == null){
				if(wsTemplate != null && parentContainer != null){
					animalOrder.createWorkspace(parentContainer, wsTemplate);
					?'animalOrder.resourceContainer =>'+animalOrder.resourceContainer+'\n';
					?'animalOrder.resourceContainer.template =>'+animalOrder.resourceContainer.template+'\n';
				}
				else{
					?'Initial Template not found\n';
				}
			}

		/*
			1f. set name, shortDescription, longTitle
		*/
			animalOrder.name = "{{name}}";
			?'setting animalOrder name =>'+animalOrder.name+'\n';

		{{#if topaz.parentProject}}
			/*
				1g. set parentProject to IACUC Study, or else line item smart form won't work
			*/
				var parentIACUC = ApplicationEntity.getResultSet('_IACUC Study').query("ID='{{topaz.parentProject.id}}'");
				if(parentIACUC.count() > 0){
					parentIACUC = parentIACUC.elements().item(1);
					animalOrder.parentProject = parentIACUC;
					?'animalOrder.parentProject =>'+animalOrder.parentProject+'\n';

				}
		{{/if}}

		{{#if vendor}}
			/*
				1h. set vendor
			*/

			var ven = ApplicationEntity.getResultSet('_Vendor').query("name='{{vendor.name}}'");
			if(ven.count() > 0){
				ven = ven.elements().item(1);
				animalOrder.customAttributes.animalVendor = ven;
				?'animalOrder.customAttributes.animalVendor =>'+animalOrder.customAttributes.animalVendor+'\n';
			}

		{{/if}}

		{{#if requestType}}
			/*
				1i. set requestType example: Export, Transfer, Animal Order
			*/
			var result = entityUtils.getObjectFromString('{{requestType.oid}}');
			animalOrder.customAttributes.requestType = result;
			?'animalOrder.customAttributes.requestType =>'+animalOrder.customAttributes.requestType+'\n';

		{{/if}}

	}
	else{
		animalOrder = animalOrder.elements().item(1);
		?'DLAR.animalOrder protocol found =>'+animalOrder.ID+'\n';
		//update fields below total animal #.
	}
}
else{
	?'ERROR: Animal Order Transfer, Parent Protocol Missing => {{topaz.parentProject.id}}\n';
}
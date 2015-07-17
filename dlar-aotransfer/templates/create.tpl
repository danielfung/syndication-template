{{#if id}}
	var animalOrder_id ="{{id}}";
	?'animal order ID for data migration => '+animalOrder_id+'\n';
	var parentProtocolID = animalOrder_id.substr(0, animalOrder_id.lastIndexOf(":"));
	?'parentProtocolID => '+parentOrderID+'\n';
{{else}}
	var animalOrder_id = _AnimalOrderTransfer.getID();
{{/if}}

?'IACUC ID =>'+animalOrder_id+'\n';
var iacuc;
var animalOrder = ApplicationEntity.getResultSet('_AnimalOrderTransfer').query("ID='"+animalOrder_id+"'");
?'animalOrder.count() =>'+animalOrder.count()+'\n';

var parentProtocol = ApplicationEntity.getResultSet('_IACUC Study').query("ID='"+parentProtocolID+"'");

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
							?'defaulting to MCIT, persons academicDepartment is null\n';
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
			{{#if status.oid}}
				var status = animalOrder.status;
				if(status == null){
					var status = entityUtils.getObjectFromString('{{status.oid}}');
					animalOrder.status = status;
					?'animalOrder.status =>'+animalOrder.status+'\n';
				}
			{{else}}
				var status = entityUtils.getObjectFromString('com.webridge.entity.Entity[OID[9AAD1CB03DAD994F8B2FAA891378047C]]');
				animalOrder.status = status;
				?'defaulting animalOrder.status =>'+animalOrder.status+'\n';
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
			var parent = ApplicationEntity.getResultSet('_IACUC Study').query("ID='"+parentProtocolID+"'");
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

		
		/*
			1g. set parentProject to IACUC Study, or else line item smart form won't work
			    set customAttributes.iacucStudy to IACUC Study
		*/
			var parentIACUC = ApplicationEntity.getResultSet('_IACUC Study').query("ID='"+parentProtocolID+"'");
			if(parentIACUC.count() > 0){
				parentIACUC = parentIACUC.elements().item(1);
				animalOrder.parentProject = parentIACUC;
				?'animalOrder.parentProject =>'+animalOrder.parentProject+'\n';
				animalOrder.setQualifiedAttribute("customAttributes.iacucStudy", parentIACUC);
				?'setting animalOrder.customAttributes.iacucStudy => '+animalOrder.customAttributes.iacucStudy+'\n';
			}
	

		{{#if animalVendor.oid}}
			/*
				1h. set vendor
			*/
			var ven = entityUtils.getObjectFromString('{{animalVendor.oid}}');
			if(ven){
				animalOrder.customAttributes.animalVendor = ven;
				?'animalOrder.customAttributes.animalVendor =>'+animalOrder.customAttributes.animalVendor+'\n';
			}

		{{/if}}

		{{#if requestType.oid}}
			/*
				1i. set requestType example: Export, Transfer, Animal Order
			*/
			var result = entityUtils.getObjectFromString('{{requestType.oid}}');
			animalOrder.customAttributes.requestType = result;
			?'animalOrder.customAttributes.requestType =>'+animalOrder.customAttributes.requestType+'\n';

		{{/if}}

		{{#if approvedDate}}
			/*
				2a. set approved date
			*/
				var date = "{{approvedDate}}";
				var dateArray = date.split('-');
				var day = dateArray[2].substring(0,2);
				var month = dateArray[1] - 1;
				var year = dateArray[0];
				var a = new Date(year, month, day);
				animalOrder.customAttributes.approvedDate = a;
				?'setting approvedDate => '+animalOrder.customAttributes.approvedDate+'\n';
		{{/if}}

		{{#if dateSentToVendor}}
			/*
				2b. set date sent to vendor
			*/
				var date = "{{dateSentToVendor}}";
				var dateArray = date.split('-');
				var day = dateArray[2].substring(0,2);
				var month = dateArray[1] - 1;
				var year = dateArray[0];
				var a = new Date(year, month, day);
				animalOrder.customAttributes.dateSentToVendor = a;
				?'setting dateSentToVendor => '+animalOrder.customAttributes.dateSentToVendor+'\n';
		{{/if}}

		{{#if orderContact}}
			/*
				2c. set order contact
			*/

			var person = ApplicationEntity.getResultSet("Person").query("userID = '{{orderContact}}'");
			if(person.count() > 0){
				person = person.elements().item(1);
				animalOrder.customAttributes.orderContact = person;
				?'setting order contact => '+person+'\n';
			}
		{{/if}}

		/*
			2d. create esets => species, orderLineItem, facilityReviewers
		*/

		var animalSet = animalOrder.customAttributes.species;
		var orderLineItemSet = animalOrder.customAttributes.orderLineItems;
		var facReviewerSet = animalOrder.customAttributes.facilityReviewers;

		if(animalSet == null){
			animalOrder.customAttributes.species = _IACUC-Species.createEntitySet();
			animalSet = animalOrder.customAttributes.species;
			?'animalOrder.customAttributes.species eset created => '+animalSet+'\n';
		}

		if(orderLineItemSet == null){
			animalOrder.customAttributes.orderLineItems = _OrderLineItem.createEntitySet();
			orderLineItemSet = animalOrder.customAttributes.orderLineItems;
			?'animalOrder.customAttributes.orderLineItems eset created => '+orderLineItemSet+'\n';
		}

		if(facReviewerSet == null){
			animalOrder.customAttributes.facilityReviewers = Person.createEntitySet();
			facReviewerSet = animalOrder.customAttributes.facilityReviewers;
			?'animalOrder.customAttributes.facilityReviewers eset created => '+facReviewerSet+'\n';
		}

		/*
			2d. set species
		*/
		{{#each species}}
			var animal = entityUtils.getObjectFromString('{{oid}}');
			animalSet.addElement(animal);
		{{/each}}

		{{#if standingOrderQuantity}}
			/*
				2e. set standingOrderQuantity
			*/
			animalOrder.customAttributes.standingOrderQuantity = {{standingOrderQuantity}};
			?'setting animalOrder.customAttributes.standingOrderQuantity => '+animalOrder.customAttributes.standingOrderQuantity+'\n';
		{{/if}}

		{{#if totalAnimals}}
			/*
				2f. set totalAnimals
			*/
			animalOrder.customAttributes.totalAnimals = {{totalAnimals}};
			?'setting animalOrder.customAttributes.totalAnimals => '+animalOrder.customAttributes.totalAnimals+'\n';
		{{/if}}

		/*
			3a. set legacy info 
		*/
		var legacy = animalOrder.customAttributes.legacyAnimalOrderInfo;
		if(legacy == null){
			animalOrder.customAttributes.legacyAnimalOrderInfo = _AO_AnimalOrderLegacyInfo.createEntitySet();
			?'setting animalOrder.customAttributes.legacyAnimalOrderInfo => '+animalOrder.customAttributes.legacyAnimalOrderInfo+'\n';
		}

		{{#if legacyAnimalOrderInfo.createDate}}
			/*
				3b. set legacyInfo.createDate
			*/
			var date = "{{legacyAnimalOrderInfo.createDate}}";
			var dateArray = date.split('-');
			var day = dateArray[2].substring(0,2);
			var month = dateArray[1] - 1;
			var year = dateArray[0];
			var a = new Date(year, month, day);
			animalOrder.customAttributes.legacyAnimalOrderInfo.setQualifiedAttribute("customAttributes.createDate", a);
			?'setting legacyAnimalOrderInfo.createDate => '+animalOrder.customAttributes.dateSentToVendor+'\n';
		{{/if}}


		{{#if legacyAnimalOrderInfo.legacyOrderNumber}}
			/*
				3c. set legacyInfo.legacyOrderNumber
			*/
			var legacyOrderNum = "{{legacyAnimalOrderInfo.legacyOrderNumber}}";
			animalOrder.customAttributes.legacyAnimalOrderInfo.customAttributes.legacyOrderNumber = legacyOrderNum;
			?'setting legacyOrderNumber => '+animalOrder.customAttributes.legacyAnimalOrderInfo.customAttributes.legacyOrderNumber+'\n';
		{{/if}}

		{{#if legacyAnimalOrderInfo.order}}
			/*
				3d. set legacyInfo.order
			*/
			var legacyOrder = "{{legacyAnimalOrderInfo.order}}";
			animalOrder.customAttributes.legacyAnimalOrderInfo.customAttributes.order = legacyOrder;
			?'setting order => '+animalOrder.customAttributes.legacyAnimalOrderInfo.customAttributes.order+'\n';
		{{/if}}

		{{#if legacyAnimalOrderInfo.orderContact}}
			/*
				3e. set legacyInfo.orderContact
			*/
			var legacyOrderContact = "{{legacyAnimalOrderInfo.orderContact}}";
			animalOrder.customAttributes.legacyAnimalOrderInfo.customAttributes.orderContact = legacyOrderContact;
			?'setting orderContact => '+animalOrder.customAttributes.legacyAnimalOrderInfo.customAttributes.orderContact+'\n';
		{{/if}}

		{{#if legacyAnimalOrderInfo.protocol}}
			/*
				3f. set legacyInfo.protocol
			*/
			var legacyProtocol = "{{legacyAnimalOrderInfo.protocol}}";
			animalOrder.customAttributes.legacyAnimalOrderInfo.customAttributes.protocol = legacyProtocol;
			?'setting protocol => '+animalOrder.customAttributes.legacyAnimalOrderInfo.customAttributes.protocol+'\n';
		{{/if}}

		{{#if legacyAnimalOrderInfo.requisition}}
			/*
				3g. set legacyInfo.requisition
			*/
			var legacyRequisition = "{{legacyAnimalOrderInfo.requisition}}";
			animalOrder.customAttributes.legacyAnimalOrderInfo.customAttributes.requisition = legacyRequisition;
			?'setting requisition => '+animalOrder.customAttributes.legacyAnimalOrderInfo.customAttributes.requisition+'\n';
		{{/if}}

		{{#if legacyAnimalOrderInfo.species}}
			/*
				3h. set legacyInfo.species
			*/
			var legacySpecies = "{{legacyAnimalOrderInfo.species}}";
			animalOrder.customAttributes.legacyAnimalOrderInfo.customAttributes.species = legacySpecies;
			?'setting species => '+animalOrder.customAttributes.legacyAnimalOrderInfo.customAttributes.species+'\n';
		{{/if}}

		{{#if legacyAnimalOrderInfo.status}}
			/*
				3i. set legacyInfo.status
			*/
			var legacyStatus = "{{legacyAnimalOrderInfo.status}}";
			animalOrder.customAttributes.legacyAnimalOrderInfo.customAttributes.status = legacyStatus;
			?'setting status => '+animalOrder.customAttributes.legacyAnimalOrderInfo.customAttributes.status+'\n';
		{{/if}}

		{{#if legacyAnimalOrderInfo.vendor}}
			/*
				3j. set legacyInfo.vendor
			*/
			var legacyVendor = "{{legacyAnimalOrderInfo.vendor}}";
			animalOrder.customAttributes.legacyAnimalOrderInfo.customAttributes.vendor = legacyVendor;
			?'setting vendor => '+animalOrder.customAttributes.legacyAnimalOrderInfo.customAttributes.vendor+'\n';
		{{/if}}




	}
	else{
		animalOrder = animalOrder.elements().item(1);
		?'DLAR.animalOrder protocol found =>'+animalOrder.ID+'\n';
		//update fields below total animal #.
	}
}
else{
	?'ERROR: Animal Order Transfer, Parent Protocol Missing => '+parentProtocolID+'\n';
	?'Current ID => {{id}}\n';
}
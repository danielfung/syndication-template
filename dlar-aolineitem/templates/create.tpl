{{#if id}}
	var order_id ="{{id}}";
	?'animal order line item ID for data migration => '+order_id+'\n';
	var parentOrderID = animalOrder_id.substr(0, animalOrder_id.lastIndexOf(":"));
	?'parentOrderID => '+parentOrderID+'\n';
{{else}}
	var order_id = _OrderLineItem.getID();
{{/if}}

?'IACUC ID =>'+order_id+'\n';
var iacuc;
var order = ApplicationEntity.getResultSet('_OrderLineItem').query("ID='"+order_id+"'");
?'order.count() =>'+order.count()+'\n';

var parentOrder = ApplicationEntity.getResultSet('_AnimalOrderTransfer').query("ID='"+parentOrderID+"'");

/*
	Check: If parent order does not exist, then return ERROR message
*/
if(parentOrder.count() > 0){

	/*
		1. Create Animal Order Line Item if it doesn't exist.
	*/
	if(order.count() == 0){
		var order =_OrderLineItem.createEntity();
		?'DLAR.animal order line item =>'+order+'\n';

		/*
			1a. update ID of Animal Order Line Item
		*/

			order.ID = order_id;
			?'order.ID =>'+order.ID+'\n';
	    
		/*
			1b. set order name
		*/

			{{#if name}}
				var name = '{{name}}';
				order.name = name;
				?'set order.name =>'+order.name+'\n';
			{{/if}}

		/*
			1c. set required fields (company, createdby, owner)
			if createdBy not found --> default to Sys Admin
		*/
			//createdby
			{{#if createdBy.userId}}
				var create = order.createdBy;
				if(create == null){
					var person = ApplicationEntity.getResultSet("Person").query("userID = '{{createdBy.userId}}'");
					if(person.count() > 0){
						person = person.elements().item(1);
						order.createdBy = person;
						?'order.createdBy =>'+order.createdBy+'\n';
						var company = person.customAttributes.academicDepartment;
						if(company == null){
							company = ApplicationEntity.getResultSet("Company").query("name = 'MCIT'").elements().item(1);
							?'defaulting to MCIT, persons academicDepartment is null\n';
						}
						order.company = company;
						?'setting company =>'+order.company+'\n';
						order.owner = person;
						?'setting order.owner =>'+person+'\n';
					}
					else{
						?'Person Not Found =>{{createdBy.userId}}\n';
						var person = ApplicationEntity.getResultSet("Person").query("userID = 'administrator'").elements().item(1);
						order.createdBy = person;
						?'defaulting order.createdBy => administrator: '+order.createdBy+'\n';
						var company = person.customAttributes.academicDepartment;
						if(company == null){
							company = ApplicationEntity.getResultSet("Company").query("name = 'MCIT'").elements().item(1);
							?'defaulting to MCIT, persons academicDepartment is null\n';
						}
						order.company = company;
						?'setting company =>'+order.company+'\n';
						order.owner = person;
						?'setting order.owner =>'+person+'\n';

					}
				}
			{{else}}
				var person = ApplicationEntity.getResultSet("Person").query("userID = 'administrator'").elements().item(1);
				order.createdBy = person;
				?'defaulting order.createdBy => administrator: '+order.createdBy+'\n';
				var company = person.customAttributes.academicDepartment;
				if(company == null){
					company = ApplicationEntity.getResultSet("Company").query("name = 'MCIT'").elements().item(1);
					?'defaulting to MCIT, persons academicDepartment is null\n';
				}
				order.company = company;
				?'setting company =>'+order.company+'\n';
				order.owner = person;
				?'setting order.owner =>'+person+'\n';
			{{/if}}



		/*
			1d. set dates(created/modified)
		*/
			var currentDate = new Date();
			order.dateCreated=currentDate;
			?'dateCreated =>'+order.dateCreated+'\n';
			order.dateModified=currentDate;
			?'dateModified =>'+order.dateModified+'\n';
		

		/*
			1e. set parentProject and order to the _AnimalOrderTransfer that owns it
		*/
			var aot = ApplicationEntity.getResultSet('_AnimalOrderTransfer').query("ID='"+parentOrderID+"'");
			if(aot.count() > 0){
				?'AOT Found =>{{topaz.parentProject.id}}\n';
				aot = aot.elements().item(1);
				order.setQualifiedAttribute("customAttributes.order", aot );
				?'order.customAttributes.order=>'+order.customAttributes.order+'\n';
				order.parentProject = aot;
				?'order.parentProject =>'+order.parentProject+'\n';
				var parentOrderSet = aot.customAttributes.orderLineItems;
				if(parentOrderSet == null){
					var c = ApplicationEntity.createEntitySet("_OrderLineItem");
					aot.customAttributes.orderLineItems = c;
					?'setting animal order line item eset => '+c+'\n';
					aot.customAttributes.orderLineItems.addElement(order);
					?'add to animal order transfer set=>'+aot.ID+'\n';
				}
				else{
					aot.customAttributes.orderLineItems.addElement(order);
					?'add to animal order transfer set=>'+aot.ID+'\n';
				}
			}
			else{
			 	?'AOT =>{{topaz.parentProject.id}} not found\n';
			}
	

		/*
			1e. set quantityRequested = 0;
		*/

			order.customAttributes.quantityRequested=0;
			?'order.quantityRequested => 0\n';

		/*
			1f. set resourceContainer
		*/

			var template = entityUtils.getObjectFromString('com.webridge.entity.Entity[OID[901FCED9C7F29F4D9E5C32F80A586943]]');
			var theParent;
			var aot = ApplicationEntity.getResultSet('_AnimalOrderTransfer').query("ID='{{topaz.parentProject.id}}'");
			if(aot.count() > 0){
				aot = aot.elements().item(1);
				theParent = aot.resourceContainer;
			}
			if(theParent != null){
				order.createWorkspace(theParent, template);
				?'create order.resourceContainer => '+order.resourceContainer+'\n';
			}

		/*
			1g. set status
		*/
		{{#if topaz.status.oid}}
			var status = entityUtils.getObjectFromString('{{topaz.status.oid}}');
			topaz.status = status;
		{{/if}}


	}
	else{
		order = order.elements().item(1);
		?'DLAR.animal order line item found =>'+order.ID+'\n';
		//update fields below total animal #.
	}
}
else{
	?'ERROR: Animal Order Line Item, animal order transfer not found => '+parentOrderID+'\n';
	?'Current ID => {{id}}\n';
}
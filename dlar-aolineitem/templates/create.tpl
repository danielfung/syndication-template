{{#if id}}
	var order_id ="{{id}}";
	?'animal order line item ID for data migration => '+order_id+'\n';
{{else}}
	var order_id = _OrderLineItem.getID();
{{/if}}

?'IACUC ID =>'+order_id+'\n';
var iacuc;
var order = ApplicationEntity.getResultSet('_OrderLineItem').query("ID='"+order_id+"'");
?'order.count() =>'+order.count()+'\n';

var parentOrder = ApplicationEntity.getResultSet('_AnimalOrderTransfer').query("ID='{{topaz.parentProject.id}}'");

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
						var company = person.employer;
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
						var company = person.employer;
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
				var company = person.employer;
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
		
		{{#if topaz.parentProject.id}}
			/*
				1e. set parentProject and order to the _AnimalOrderTransfer that owns it
			*/
				var aot = ApplicationEntity.getResultSet('_AnimalOrderTransfer').query("ID='{{topaz.parentProject.id}}'");
				if(aot.count() > 0){
					?'AOT Found =>{{topaz.parentProject.id}}\n';
					aot = aot.elements().item(1);
					order.setQualifiedAttribute("customAttributes.order", aot );
					?'order.customAttributes.order=>'+order.customAttributes.order+'\n';
					order.parentProject = aot;
					?'order.parentProject =>'+order.parentProject+'\n';
					var order = aot.customAttributes.orderLineItems;
					if(order == null){
						var c = ApplicationEntity.createEntitySet("_OrderLineItem");

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
		{{/if}}

	}
	else{
		order = order.elements().item(1);
		?'DLAR.animal order line item found =>'+order.ID+'\n';
		//update fields below total animal #.
	}
}
else{
	?'ERROR: Animal Order Line Item, animal order transfer not found => {{topaz.parentOrder.id}}\n';
}
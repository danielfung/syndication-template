{{#if _uid}}
	var order_id = _OrderLineItem.getID();
{{else}}
	var order_id ="{{this.id}}";
{{/if}}

?'IACUC ID =>'+order_id+'\n';
var iacuc;
var order = ApplicationEntity.getResultSet('_OrderLineItem').query("ID='"+order_id+"'");
?'order.count() =>'+order.count()+'\n';

var parentOrder = ApplicationEntity.getResultSet('_AnimalOrderTransfer').query("ID='{{parentProject.id}}'");

/*
	Check: If parent order does not exist, then return ERROR message
*/
if(parentProtocol.count() > 0){

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
				var create = cageCard.createdBy;
				if(create == null){
					var person = ApplicationEntity.getResultSet("Person").query("userID = '{{createdBy.userId}}'");
					if(person.count() > 0){
						person = person.elements().item(1);
						cageCard.createdBy = person;
						?'cageCard.createdBy =>'+cageCard.createdBy+'\n';
						var company = person.employer;
						cageCard.company = company;
						?'setting company =>'+cageCard.company+'\n';
						cageCard.owner = person;
						?'setting cageCard.owner =>'+person+'\n';
					}
					else{
						?'Person Not Found =>{{createdBy.userId}}\n';
						var person = ApplicationEntity.getResultSet("Person").query("userID = 'administrator'").elements().item(1);
						cageCard.createdBy = person;
						?'defaulting cageCard.createdBy => administrator: '+cageCard.createdBy+'\n';
						var company = person.employer;
						cageCard.company = company;
						?'setting company =>'+cageCard.company+'\n';
						cageCard.owner = person;
						?'setting cageCard.owner =>'+person+'\n';

					}
				}
			{{else}}
				var person = ApplicationEntity.getResultSet("Person").query("userID = 'administrator'").elements().item(1);
				cageCard.createdBy = person;
				?'defaulting cageCard.createdBy => administrator: '+cageCard.createdBy+'\n';
				var company = person.employer;
				cageCard.company = company;
				?'setting company =>'+cageCard.company+'\n';
				cageCard.owner = person;
				?'setting cageCard.owner =>'+person+'\n';

			{{/if}}



		/*
			1d. set dates(created/modified)
		*/
			var currentDate = new Date();
			cageCard.dateCreated=currentDate;
			?'dateCreated =>'+cageCard.dateCreated+'\n';
			cageCard.dateModified=currentDate;
			?'dateModified =>'+cageCard.dateModified+'\n';
		
		{{#if parentProject}}
			/*
				1e. set parentProject and order to the _AnimalOrderTransfer that owns it
			*/
				var aot = ApplicationEntity.getResultSet('_AnimalOrderTransfer').query("ID='{{parentProject.id}}'");
				if(aot.count() > 0){
					?'AOT Found =>{{parentProject.id}}\n';
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
				 	?'AOT =>{{parentProject.id}} not found\n';
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
	?'ERROR: Animal Order Line Item, parentProtocol not found => {{parentOrder.id}}\n';
}
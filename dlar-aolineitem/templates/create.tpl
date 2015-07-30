{{#if id}}
	var order_id ="{{id}}";
	?'animal order line item ID for data migration => '+order_id+'\n';
	var parentOrderID = order_id.substr(0, order_id.lastIndexOf(":"));
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
			{{else}}
				var name = 'AOL - '+order_id;
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
				aot = aot.elements().item(1);
				?'AOT Found =>'+aot.ID+'\n';
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
			 	?'AOT => '+parentOrderID+' not found\n';
			}
	

		/*
			1e. set quantityRequested = 0 if not given;, set quantityReceived = 0 if not given
		*/
			{{#if quantityRequested}}
				order.customAttributes.quantityRequested= {{quantityRequested}};
				?'order.quantityRequested =>'+order.customAttributes.quantityRequested+'\n';
			{{else}}
				order.customAttributes.quantityRequested=0;
				?'order.quantityRequested => 0\n';
			{{/if}}

			{{#if quantityReceived}}
				order.customAttributes.quantityReceived= {{quantityReceived}};
				?'order.quantityReceived =>'+order.customAttributes.quantityReceived+'\n';
			{{else}}
				order.customAttributes.quantityReceived=0;
				?'order.quantityReceived => 0\n';
			{{/if}}

		/*
			1f. set resourceContainer
		*/

			var template = entityUtils.getObjectFromString('com.webridge.entity.Entity[OID[901FCED9C7F29F4D9E5C32F80A586943]]');
			var theParent;
			var aot = ApplicationEntity.getResultSet('_AnimalOrderTransfer').query("ID='"+parentOrderID+"'");
			if(aot.count() > 0){
				aot = aot.elements().item(1);
				theParent = aot.resourceContainer;
			}
			if(theParent != null){
				order.createWorkspace(theParent, template);
				?'create order.resourceContainer => '+order.resourceContainer+'\n';
			}
			else{
				?'resourceContainer not found for parent => '+parentOrderID+'\n';
			}

		/*
			1g. set status
		*/
		{{#if status.oid}}
			var status = entityUtils.getObjectFromString('{{status.oid}}');
			order.status = status;
			?'setting order.status => '+order.status+'\n';
		{{/if}}


		/*
			2a. set age
		*/

		{{#if age}}
			order.customAttributes.age = "{{age}}";
			?'setting orderLineItem.age => '+order.customAttributes.age+'\n';
		{{/if}}

		/*
			2b. set confirmation code
		*/

		{{#if confirmationCode}}
			order.customAttributes.confirmationCode = "{{confirmationCode}}";
			?'setting order.customAttributes.confirmationCode => '+order.customAttributes.confirmationCode+'\n';
		{{/if}}

		/*
			2c. set dates(deliveryDate/orderDate)
		*/

		{{#if deliveryDate}}
			var date = "{{deliveryDate}}";
			var dateArray = date.split('-');
			var day = dateArray[2].substring(0,2);
			var month = dateArray[1] - 1;
			var year = dateArray[0];
			var a = new Date(year, month, day);
			order.customAttributes.deliveryDate = a;
			?'setting deliveryDate => '+order.customAttributes.deliveryDate+'\n';
		{{/if}}

		{{#if orderDate}}
			var date = "{{orderDate}}";
			var dateArray = date.split('-');
			var day = dateArray[2].substring(0,2);
			var month = dateArray[1] - 1;
			var year = dateArray[0];
			var a = new Date(year, month, day);
			order.customAttributes.orderDate = a;
			?'setting orderDate => '+order.customAttributes.orderDate+'\n';
		{{/if}}

		/*
			2d. set po number
		*/
		{{#if poNumber}}
			order.customAttributes.poNumber = "{{poNumber}}";
			?'setting order.customAttributes.poNumber => '+order.customAttributes.poNumber+'\n';
		{{/if}}

		/*
			2e. set weight
		*/
		{{#if weight}}
			order.customAttributes.weight = "{{weight}}";
			?'setting order.customAttributes.weight => '+order.customAttributes.weight+'\n';
		{{/if}}

		/*
			2f. set surcharge
		*/
		{{#if surcharge}}
			order.customAttributes.surcharge = "{{surcharge}}";
			?'setting order.customAttributes.surcharge => '+order.customAttributes.surcharge+'\n';
		{{/if}}		

		/*
			2g. set animalsPerCage	
		*/
		{{#if animalsPerCage}}
			 var numAnimalPerCage = ApplicationEntity.getResultSet('_animalsPerCage').query("customAttributes.value={{animalsPerCage}}");
			 if(numAnimalPerCage.count() > 0){
			 	numAnimalPerCage= numAnimalPerCage.elements().item(1);
				order.customAttributes.animalsPerCage = numAnimalPerCage;
				?'setting order.customAttributes.animalsPerCage => '+order.customAttributes.animalsPerCage+'\n';			 	
			 }
			 else{
			 	?'numAnimalPerCage not found => {{animalsPerCage}}\n';
			 }
		{{/if}}

		/*
			2h. set sex of animal
		*/
		{{#if sex.oid}}
			var sex = entityUtils.getObjectFromString('{{sex.oid}}');
			order.customAttributes.sex = sex;
			?'setting animal sex => '+sex+'\n';
		{{/if}}

		/*
			2i. set procurementAccount
		*/
		{{#if procurementAccount}}
			var accountInfo = ApplicationEntity.getResultSet('_GLAccount_SE').query("ID='{{procurementAccount}}'");
			if(accountInfo.count() > 0){
				var accountInfo_1 = accountInfo.elements().item(1);
				order.customAttributes.procurementAccount = accountInfo_1;
				?'setting procurementAccount => '+order.customAttributes.procurementAccount+'\n';
			}
			else{
				?'procurementAccount not found => {{procurementAccount}}\n';
			}
		{{/if}}

		/*
			2j. set perDiemBillingAccount
		*/
		{{#if perDiemBillingAccount}}
			var accountInfo = ApplicationEntity.getResultSet('_GLAccount_SE').query("ID='{{perDiemBillingAccount}}'");
			if(accountInfo.count() > 0){
				var accountInfo_1 = accountInfo.elements().item(1);
				order.customAttributes.perDiemBillingAccount = accountInfo_1;
				?'setting perDiemBillingAccount => '+order.customAttributes.perDiemBillingAccount+'\n';
			}
			else{
				?'perDiemBillingAccount not found => {{perDiemBillingAccount}}\n';
			}
		{{/if}}

		/*
			3a. create animalorderlineitemlegacyinfo
		*/

		var legacyInfo = _AO_AnimalOrderLineItemLegacyInfo.createEntity();
		?'created legacyInfo entity => '+legacyInfo+'\n';
		legacyInfo.ID = order_id;
		?'setting legacyInfoLineItem.id => '+legacyInfo.ID+'\n';


	}
	else{
		order = order.elements().item(1);
		?'DLAR.animal order line item found =>'+order.ID+'\n';
		//update fields below total animal #.

		/*
			1e. set quantityRequested = 0 if not given;, set quantityReceived = 0 if not given
		*/
			{{#if quantityRequested}}
				order.customAttributes.quantityRequested= {{quantityRequested}};
				?'order.quantityRequested =>'+order.customAttributes.quantityRequested+'\n';
			{{else}}
				order.customAttributes.quantityRequested=0;
				?'order.quantityRequested => 0\n';
			{{/if}}

			{{#if quantityReceived}}
				order.customAttributes.quantityReceived= {{quantityReceived}};
				?'order.quantityReceived =>'+order.customAttributes.quantityReceived+'\n';
			{{else}}
				order.customAttributes.quantityReceived=0;
				?'order.quantityReceived => 0\n';
			{{/if}}

		/*
			1g. set status
		*/
		{{#if status.oid}}
			var status = entityUtils.getObjectFromString('{{status.oid}}');
			order.status = status;
			?'setting order.status => '+order.status+'\n';
		{{/if}}


		/*
			2a. set age
		*/

		{{#if age}}
			order.customAttributes.age = "{{age}}";
			?'setting orderLineItem.age => '+order.customAttributes.age+'\n';
		{{/if}}

		/*
			2b. set confirmation code
		*/

		{{#if confirmationCode}}
			order.customAttributes.confirmationCode = "{{confirmationCode}}";
			?'setting order.customAttributes.confirmationCode => '+order.customAttributes.confirmationCode+'\n';
		{{/if}}

		/*
			2c. set dates(deliveryDate/orderDate)
		*/

		{{#if deliveryDate}}
			var date = "{{deliveryDate}}";
			var dateArray = date.split('-');
			var day = dateArray[2].substring(0,2);
			var month = dateArray[1] - 1;
			var year = dateArray[0];
			var a = new Date(year, month, day);
			order.customAttributes.deliveryDate = a;
			?'setting deliveryDate => '+order.customAttributes.deliveryDate+'\n';
		{{/if}}

		{{#if orderDate}}
			var date = "{{orderDate}}";
			var dateArray = date.split('-');
			var day = dateArray[2].substring(0,2);
			var month = dateArray[1] - 1;
			var year = dateArray[0];
			var a = new Date(year, month, day);
			order.customAttributes.orderDate = a;
			?'setting orderDate => '+order.customAttributes.orderDate+'\n';
		{{/if}}

		/*
			2d. set po number
		*/
		{{#if poNumber}}
			order.customAttributes.poNumber = "{{poNumber}}";
			?'setting order.customAttributes.poNumber => '+order.customAttributes.poNumber+'\n';
		{{/if}}

		/*
			2e. set weight
		*/
		{{#if weight}}
			order.customAttributes.weight = "{{weight}}";
			?'setting order.customAttributes.weight => '+order.customAttributes.weight+'\n';
		{{/if}}

		/*
			2f. set surcharge
		*/
		{{#if surcharge}}
			order.customAttributes.surcharge = "{{surcharge}}";
			?'setting order.customAttributes.surcharge => '+order.customAttributes.surcharge+'\n';
		{{/if}}		

		/*
			2g. set animalsPerCage	
		*/
		{{#if animalsPerCage}}
			 var numAnimalPerCage = ApplicationEntity.getResultSet('_animalsPerCage').query("customAttributes.value={{animalsPerCage}}");
			 if(numAnimalPerCage.count() > 0){
			 	numAnimalPerCage= numAnimalPerCage.elements().item(1);
				order.customAttributes.animalsPerCage = numAnimalPerCage;
				?'setting order.customAttributes.animalsPerCage => '+order.customAttributes.animalsPerCage+'\n';			 	
			 }
			 else{
			 	?'numAnimalPerCage not found => {{animalsPerCage}}\n';
			 }
		{{/if}}

		/*
			2h. set sex of animal
		*/
		{{#if sex.oid}}
			var sex = entityUtils.getObjectFromString('{{sex.oid}}');
			order.customAttributes.sex = sex;
			?'setting animal sex => '+sex+'\n';
		{{/if}}

		/*
			2i. set procurementAccount
		*/
		{{#if procurementAccount}}
			var accountInfo = ApplicationEntity.getResultSet('_GLAccount_SE').query("ID='{{procurementAccount}}'");
			if(accountInfo.count() > 0){
				var accountInfo_1 = accountInfo.elements().item(1);
				order.customAttributes.procurementAccount = accountInfo_1;
				?'setting procurementAccount => '+order.customAttributes.procurementAccount+'\n';
			}
			else{
				?'procurementAccount not found => {{procurementAccount}}\n';
			}
		{{/if}}

		/*
			2j. set perDiemBillingAccount
		*/
		{{#if perDiemBillingAccount}}
			var accountInfo = ApplicationEntity.getResultSet('_GLAccount_SE').query("ID='{{perDiemBillingAccount}}'");
			if(accountInfo.count() > 0){
				var accountInfo_1 = accountInfo.elements().item(1);
				order.customAttributes.perDiemBillingAccount = accountInfo_1;
				?'setting perDiemBillingAccount => '+order.customAttributes.perDiemBillingAccount+'\n';
			}
			else{
				?'perDiemBillingAccount not found => {{perDiemBillingAccount}}\n';
			}
		{{/if}}

		var findLegacyLineItem = ApplicationEntity.getResultSet('_AO_AnimalOrderLineItemLegacyInfo').query("ID='"+order_id+"'");
		if(findLegacyLineItem.count() == 0){
			var createLegacyLineItem = _AO_AnimalOrderLineItemLegacyInfo.createEntity();
			?'created legacy line item entity => '+createLegacyLineItem+'\n';
			createLegacyLineItem.ID = order_id;
			?'setting ID to legacy line item  => '+createLegacyLineItem.ID+'\n';
		}
		else{
			findLegacyLineItem = findLegacyLineItem.elements().item(1);
			?'legacy line item found => '+findLegacyLineItem.ID+'\n';
		}


	}
}
else{
	?'ERROR: Animal Order Line Item, animal order transfer not found => '+parentOrderID+'\n';
	?'Current ID => {{id}}\n';
}
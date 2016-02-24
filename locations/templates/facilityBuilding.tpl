var facBuilding = ApplicationEntity.getResultSet('_ClickFacilityBuilding').query("ID='{{id}}'").elements();
if(facBuilding.count() == 1){
	//Facility Building
	var facBuildingItem = facBuilding.item(1);
	?'Facility Building Found => '+facBuildingItem.ID+'\n';
	
	var date = new Date();

	//update Status
	var status = "{{status}}";
	if(status == "Active Animal Location"){
		var iacucFacBuildingApprovedStatus = EntityUtils.getObjectFromString("com.webridge.entity.Entity[OID[D07767DE99AA0B40A0B8AE90F3A6BB81]]");
		facBuildingItem.status = iacucFacBuildingApprovedStatus;
	}
	else{
		var iacucFacBuildingInactiveStatus = EntityUtils.getObjectFromString("com.webridge.entity.Entity[OID[D9D36E183E1F2B44AF971B29178F12CD]]");
		facBuildingItem.status = iacucFacBuildingInactiveStatus;
	}

	facBuildingItem.dateModified = date;
	?'facBuildingItem.dateModified => '+facBuildingItem.dateModified+'\n';

	//Check if project eset exist
	var projectSet = facBuildingItem.projects;
	if(projectSet == null){
		var pSet = Project.createEntitySet();
		facBuildingItem.projects = pSet;
	}

	//Update Name
	var facName = "{{name}}";
	facBuildingItem.setQualifiedAttribute("name", facName);
	?'Facility Building name => '+facBuildingItem.name+'\n';

	var fullName = "{{name}}";
	facility.setQualifiedAttribute("customAttributes.fullName", fullName);
	?'setting fullName => '+facility.customAttributes.fullName+'\n';

	//Update Campus - Create if does not exist
	var campusFound = ApplicationEntity.getResultSet('_ClickCampus').query("ID='{{site.name}}'").elements();
	if(campusFound.count() == 1){
		var campusItem = campusFound.item(1);
		facility.setQualifiedAttribute("customAttributes.campus", campusItem);
		?'setting facility campus => '+facility.customAttributes.campus+'\n';
	}
	else{
		?'Click Campus not found => {{site.name}}\n';
		
		var createCampus = wom.createTransientEntity('_ClickCampus');
		createCampus.ID = "{{site.name}}";
		var dateNow = new Date();
		createCampus.dateCreated = dateNow;
		createCampus.dateModified = dateNow;
		?'campus created => '+createCampus.ID+'\n';

		facility.setQualifiedAttribute("customAttributes.campus", createCampus);
		?'setting newly created facility campus => '+facility.customAttributes.campus+'\n';
	}
}
else if(facBuilding.count() > 1){
	?'More than one fac Building found by id {{id}}\n';
}
else{
	/*
		1A. Create Facility Building
	*/
	var facility = _ClickFacilityBuilding.createEntity();
	?'Creating Facility Building => '+facility+'\n';

	facility.ID = "{{id}}";
	?'Facility Building ID => '+facility.ID+'\n';

	facility.name = "{{name}}";
	?'Facility Building name => '+facility.name+'\n';

	{{#if createdBy}}
		var personCreated = ApplicationEntity.getResultSet('Person').query("userID='{{createdBy.userID}}'").elements();
		if(personCreated.count() == 1){
			var perItem = personCreated.item(1);
			facility.createdBy = perItem;
			?'Facility Created by => '+facility.createdBy.userID;
		}
		else{
			?'Person not found by kerboros => {{userID}}\n';
			var personCreated = ApplicationEntity.getResultSet('Person').query("userID='Administrator'").elements();
			if(personCreated.count() == 1){
				var perItem = personCreated.item(1);
				facility.createdBy = perItem;
				?'Facility Created by(DEFAULT) => '+facility.createdBy.userID;
			}
		}
	{{else}}
		var personCreated = ApplicationEntity.getResultSet('Person').query("userID='Administrator'").elements();
		if(personCreated.count() == 1){
			var perItem = personCreated.item(1);
			facility.createdBy = perItem;
			?'Facility Created by(DEFAULT) => '+facility.createdBy.userID;
		}
	{{/if}}

	{{#if company}}
		var company = facility.company;
		if(company == null){
			var a = ApplicationEntity.getResultSet("Company").query("ID = '{{company.id}}'");
			if(a.count()>0){
				facility.company = a.elements().item(1);
				?'facility.company =>'+facility.company+'\n';
			}
			else{
				?'Company Not Found =>{{company.id}}\n';
			}
		}
	{{else}}
		var company = ApplicationEntity.getResultSet("Company").query("NAME = 'MCIT'").elements().item(1);
		facility.company = company;
		?'defaulting facility.company => MCIT: '+company+'\n';

	{{/if}}

	var date = new Date();
	facility.dateCreated = date;
	?'facility.dateCreated => '+facility.dateCreated+'\n';
	facility.dateModified = date;
	?'facility.dateModified => '+facility.dateModified+'\n';

	var fullName = "{{name}}";
	facility.setQualifiedAttribute("customAttributes.fullName", fullName);
	?'setting fullName => '+facility.customAttributes.fullName+'\n';

	var projectSet = facility.projects;
	if(projectSet == null){
		var pSet = Project.createEntitySet();
		facility.projects = pSet;
	}

	var status = "{{status}}";
	if(status == "Active Animal Location"){
		var iacucFacBuildingApprovedStatus = EntityUtils.getObjectFromString("com.webridge.entity.Entity[OID[D07767DE99AA0B40A0B8AE90F3A6BB81]]");
		facility.status = iacucFacBuildingApprovedStatus;
		?'Set status to active => '+facility.status+'\n';
	}
	else{
		var iacucFacBuildingInactiveStatus = EntityUtils.getObjectFromString("com.webridge.entity.Entity[OID[D9D36E183E1F2B44AF971B29178F12CD]]");
		facility.status = iacucFacBuildingInactiveStatus;
		?'Set status to inactive => '+facility.status+'\n';
	}

	/*
		1B. Set Resource Container/Create Workspace
	*/

	var parentOID = "com.webridge.entity.Entity[OID[C23727395378E940ADE256DC6EE3ABC1]]";
	theParent = EntityUtils.getObjectFromString(parentOID);
	var wsTemplate = wsTemplate = ContainerTemplate.getElements("ContainerTemplateForID", "ID", "TMPL8D185444818AE07");

	var resourceContainer = facility.resourceContainer;
	if(resourceContainer == null){
		if(wsTemplate != null && theParent != null){
			wsTemplate = wsTemplate.item(1);
			facility.createWorkspace(theParent, wsTemplate);
			?'facility.resourceContainer =>'+facility.resourceContainer+'\n';
			?'facility.resourceContainer.template =>'+facility.resourceContainer.template+'\n';
		}
		else{
			?'Initial Template not found\n';
		}
	}

	/*
		1C. Set Facility Building Campus
	*/
	var campusFound = ApplicationEntity.getResultSet('_ClickCampus').query("ID='{{site.name}}'").elements();
	if(campusFound.count() == 1){
		var campusItem = campusFound.item(1);
		facility.setQualifiedAttribute("customAttributes.campus", campusItem);
		?'setting facility campus => '+facility.customAttributes.campus+'\n';
	}else{
		?'Click Campus not found => {{site.name}}\n';
		/*
			var createCampus = wom.createTransientEntity('_ClickCampus'):
			createCampus.ID = "{{site.name}}";
			var dateNow = new Date();
			createCampus.dateCreated = dateNow;
			createCampus.dateModified = dateNow;
			?'campus created => '+createCampus.ID+'\n';

			facility.setQualifiedAttribute("customAttributes.campus", createCampus);
			?'setting newly created facility campus => '+facility.customAttributes.campus+'\n';
		*/
	}

	/*
		1D. Set Facility Building Custom Extension
	*/

	var facCustomExt = facility.customAttributes.facilityBuildingCustomExtension;
	if(facCustomExt == null){
		var createCustomExt = wom.createTransientEntity('_FacilityBuildingCustomExtension');
		facility.setQualifiedAttribute("customAttributes.facilityBuildingCustomExtension", createCustomExt);
		?'create facility building custom extension => '+facility.customAttributes.facilityBuildingCustomExtension+'\n';
	}


}
var currentBuilding = ApplicationEntity.getResultSet('_ClickFacilityBuilding').query("ID='{{building.id}}'").elements();

if(currentBuilding.count() == 1){
	//Facility Room
	var facRoom = ApplicationEntity.getResultSet('_ClickFacilityRoom').query("ID='{{id}}'").elements();

	if(facRoom.count() == 1){

		var facRoomItem = facRoom.item(1);
		?'Facility Room Found => '+facRoomItem.ID+'\n';
		var checkCurrentBuilding = currentBuilding.item(1);

		//Remove existing usage list
		var facUsageEset = facRoomItem.customAttributes.usageList;
		if(facUsageEset == null){
			var usageEset = _ClickFacilityUsage.createEntitySet();
			facRoomItem.setQualifiedAttribute("customAttributes.usageList", usageEset);
			facUsageEset = facRoomItem.customAttributes.usageList;
			?'setting usuage eset => '+facUsageEset+'\n';
		}
		else{
			facUsageEset.removeAllElements();
		}

		facUsageEset = facRoomItem.customAttributes.usageList;

		//Update Usage List
		{{#each _attribute0}}
			var usageName = "{{_attribute0}}";
			var usageFound = ApplicationEntity.getResultSet('_ClickFacilityUsage').query("ID='"+usageName+"'");
			if(usageFound.count() == 1){
				var item = usageFound.elements().item(1);
				?'Usuage found => '+item.ID+'\n';
				facUsageEset.addElement(item);
			}
			else{
				?'usage not found by id {{_attribute0}}\n';
			}
		{{/each}}


		//Update Building if necessary
		var lookUpBuilding = facRoomItem.customAttributes.building;
		var lookUpBuildingID = lookUpBuilding.ID;
		if(lookUpBuildingID == "{{building.id}}"){
			?'building is the same do nothing\n';
		}
		else{
			?'Building is different => old building ID => '+lookUpBuildingID+' => new building ID => {{building.id}}\n';
			var oldBuildingProject = lookUpBuilding.projects;
			oldBuildingProject.removeElement(facRoomItem);
			?'remove facility from old building project\n';
			facRoomItem.setQualifiedAttribute("customAttributes.building", checkCurrentBuilding);
			?'setting currentBuilding to => '+checkCurrentBuilding+'\n';
			var currentBuildingProjects = checkCurrentBuilding.projects;
			if(currentBuildingProjects == null){
				var pSet = Project.createEntitySet();
				checkCurrentBuilding.projects = pSet;
				?'created projects eset for building => '+checkCurrentBuilding.ID+'\n';
				currentBuildingProjects = checkCurrentBuilding.projects;
			}

			currentBuildingProjects.addElement(facRoomItem);
			?'Adding facility to building eset => '+facRoomItem+'\n';


		}

		facRoomItem.parentProject = facRoomItem.customAttributes.building;
		?'Setting parent project of room to => '+facRoomItem.parentProject.ID+'\n';

		//update Floor
		var facRoomCustomExtension = facRoomItem.customAttributes.facilityRoomCustomExtension;
		if(facRoomCustomExtension == null){
			var facRoomExt = _FacilityRoomCustomExtension.createEntity();
			facRoomItem.setQualifiedAttribute("customAttributes.facilityRoomCustomExtension", facRoomExt);
			facRoomCustomExtension = facRoomItem.customAttributes.facilityRoomCustomExtension;
			?'Created facility room custom extension => '+facRoomCustomExtension+'\n';
		}

		{{#if floor.name}}
			var floorName = "{{floor.name}}";
			facRoomCustomExtension.setQualifiedAttribute("customAttributes.floor", floorName);
			?'Setting floor name => '+facRoomCustomExtension.customAttributes.floor+'\n';
		{{/if}}

		//Update Status
		var status = "{{status}}";
		if(status == "Active Animal Location"){
			var iacucFacRoomApprovedStatus = EntityUtils.getObjectFromString("com.webridge.entity.Entity[OID[D4697F365E0110479C706BA0B7C45A14]]");
			facRoomItem.status = iacucFacRoomApprovedStatus;
			?'Set status to active => '+facRoomItem.status+'\n';
		}
		else{
			var iacucFacRoomInactiveStatus = EntityUtils.getObjectFromString("com.webridge.entity.Entity[OID[69B8F67A4BB0FE4581E807E227593D57]]");
			facRoomItem.status = iacucFacRoomInactiveStatus;
			?'Set status to inactive => '+facRoomItem.status+'\n';
		}


	}
	else if(facRoom.count() > 1){

		?'More than one fac room found by id {{id}}\n';

	}
	else{

		?'Facility Room Not Found, Need to create one\n';
		/*
			1A. Create Facility Room
		*/

		var facility = _ClickFacilityRoom.createEntity();
		?'Creating Facility Room => '+facility+'\n';

		facility.ID = "{{id}}";
		?'Facility Room ID => '+facility.ID+'\n';

		facility.name = "{{name}}";
		?'Facility Room name => '+facility.name+'\n';

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

		var facilityContactSet = Person.createEntitySet();
		facility.setQualifiedAttribute('customAttributes.roomContacts', facilityContactSet);
		?'set facility roomContacts eSet => '+facility.customAttributes.roomContacts+'\n';

		var projectSet = facility.projects;
		if(projectSet == null){
			var pSet = Project.createEntitySet();
			facility.projects = pSet;
		}

		var status = "{{status}}";
		if(status == "Active Animal Location"){
			var iacucFacRoomApprovedStatus = EntityUtils.getObjectFromString("com.webridge.entity.Entity[OID[D4697F365E0110479C706BA0B7C45A14]]");
			facility.status = iacucFacRoomApprovedStatus;
			?'Set status to active => '+facility.status+'\n';
		}
		else{
			var iacucFacRoomInactiveStatus = EntityUtils.getObjectFromString("com.webridge.entity.Entity[OID[69B8F67A4BB0FE4581E807E227593D57]]");
			facility.status = iacucFacRoomInactiveStatus;
			?'Set status to inactive => '+facility.status+'\n';
		}

		/*
			1B. Set Building
		*/
		var buildingFound = currentBuilding.item(1);
		facility.setQualifiedAttribute("customAttributes.building", buildingFound)
		?'set facility building => '+facility.customAttributes.building+'\n';

		/*
			1C. Create workspace
		*/

		theParent = buildingFound.resourceContainer;
		var wsTemplate = wsTemplate = ContainerTemplate.getElements("ContainerTemplateForID", "ID", "TMPL8D185444818AE08");

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
			1D. Add to building's project
		*/
		var buildingProject = buildingFound.projects;
		buildingProject.addElement(facility);
		?'added room to buildings project\n';

		/*
			1E. Create Facility Usage Eset
		*/
		var facUsageEset = facility.customAttributes.usageList;
		if(facUsageEset == null){
			var usageEset = _ClickFacilityUsage.createEntitySet();
			facility.setQualifiedAttribute("customAttributes.usageList", usageEset);
			facUsageEset = facility.customAttributes.usageList;
			?'setting usuage eset => '+facUsageEset+'\n';
		}

		/*
			1F. Update usuage list eset
		*/
		{{#each _attribute0}}
			var usageName = "{{_attribute0}}";
			var usageFound = ApplicationEntity.getResultSet('_ClickFacilityUsage').query("ID='"+usageName+"'");
			if(usageFound.count() == 1){
				var item = usageFound.elements().item(1);
				?'Usuage found => '+item.ID+'\n';
				facUsageEset.addElement(item);
			}
			else{
				?'usage not found by id {{_attribute0}}\n';
			}
		{{/each}}


		/*
			1G. Create Facility Room Custom Extension
		*/
		var facRoomCustomExtension = facility.customAttributes.facilityRoomCustomExtension;
		if(facRoomCustomExtension == null){
			var facRoomExt = _FacilityRoomCustomExtension.createEntity();
			facility.setQualifiedAttribute("customAttributes.facilityRoomCustomExtension", facRoomExt);
			facRoomCustomExtension = facility.customAttributes.facilityRoomCustomExtension;
			?'Created facility room custom extension => '+facRoomCustomExtension+'\n';
		}

		{{#if floor.name}}
			var floorName = "{{floor.name}}";
			facRoomCustomExtension.setQualifiedAttribute("customAttributes.floor", floorName);
			?'Setting floor name => '+facRoomCustomExtension.customAttributes.floor+'\n';
		{{/if}}

		/*
			1H. Create Room Contact
		*/
		var facContactSet = facility.customAttributes.roomContacts;
		if(facContactSet == null){
			var personSet = Person.createEntitySet();
			facility.setQualifiedAttribute("customAttributes.roomContacts", personSet);
			?'Create facility room contacts eset => '+facility.customAttributes.roomContacts+'\n';
		}

		/*
			1J. Set Parent Project
		*/
		facility.parentProject = buildingFound;
		?'Setting parent project of room to => '+facility.parentProject.ID+'\n';

	}
}
else{
	?'Building not found by {{building.id}}\n';
	?'Did not check to see if room exist {{id}}\n';
}
{{#if _attribute2}}
	{{#if id}}
		var id = "{{this.id}}";
		var typeOfBuilding = "{{_attribute2}}";
		if(typeOfBuilding == "Building"){
			{{> integrationIacucBuildingCreate}}
		}
		else if(typeOfBuilding == "Room" || typeOfBuilding == "Floor"){
			{{> integrationIacucRoomCreate}}
		}
		else if(typeOfBuilding == "Site"){
			{{> integrationIacucCampusCreate}}
		}
		else{
			?'Not a room/building\n';
		}
	{{else}}
		?'ID for this facility not filled in\n';
	{{/if}}
{{else}}
		?'attribute2(facility class) in DCM not filled in for ID => {{this.id}}\n';
{{/if}}
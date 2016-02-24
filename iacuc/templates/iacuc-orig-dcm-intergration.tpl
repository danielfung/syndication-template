	iacucQ = iacucQ.elements().item(1);
	?'iacucQ submission found =>'+iacucQ.ID+'\n';
	var draftProtocol = iacucQ.customAttributes.draftProtocol;
	var iacucUsedAnimalCount = iacucQ.customAttributes.usedAnimalCounts;
	var iacucDraftUsedAnimalCount = draftProtocol.customAttributes.usedAnimalCounts;


	if(iacucUsedAnimalCount){
	{{#each groups}}
		//get used count and update - Original
		var speciesName = "{{_Species._attribute0}}";
		var painCategory = "Pain Category "+"{{usdaPainCategory.Category}}";
		var usda = "{{_Species.usdaCovered}}";
		var usedCount = {{used}};
		var findUsedAnimal = iacucUsedAnimalCount.query("customAttributes.species.customAttributes.commonName='"+speciesName+"'");
		if(usda == "1"){
			findUsedAnimal = findUsedAnimal.query("customAttributes.species.customAttributes.isUSDASpecies=true");
		}
		else{
			findUsedAnimal = findUsedAnimal.query("customAttributes.species.customAttributes.isUSDASpecies=false");
		}
		findUsedAnimal = findUsedAnimal.query("customAttributes.painCategory.customAttributes.category='"+painCategory+"'");
		for(var i = 1; i<=findUsedAnimal.count(); i++){
			var item = findUsedAnimal.elements().item(i);
			item.customAttributes.usedNumberOfAnimals = usedCount;
			?'update {{_Species._attribute0}} Pain Category {{usdaPainCategory.Category}} used count => '+item.customAttributes.usedNumberOfAnimals+'\n';
		}
	{{/each}}
	}
	else{
		?'iacucUsedAnimalCount does not exist => '+iacucUsedAnimalCount+'\n';
	}

	if(iacucDraftUsedAnimalCount){
	{{#each groups}}
		//get used count and update - Draft
		var speciesName = "{{_Species._attribute0}}";
		var painCategory = "Pain Category "+"{{usdaPainCategory.Category}}";
		var usda = "{{_Species.usdaCovered}}";
		var usedCount = {{used}};
		var findUsedAnimalDraft = iacucDraftUsedAnimalCount.query("customAttributes.species.customAttributes.commonName='"+speciesName+"'");
		if(usda == "1"){
			findUsedAnimalDraft = findUsedAnimalDraft.query("customAttributes.species.customAttributes.isUSDASpecies=true");
		}
		else{
			findUsedAnimalDraft = findUsedAnimalDraft.query("customAttributes.species.customAttributes.isUSDASpecies=false");
		}
		findUsedAnimalDraft = findUsedAnimalDraft.query("customAttributes.painCategory.customAttributes.category='"+painCategory+"'");
		for(var i = 1; i<=findUsedAnimalDraft.count(); i++){
			var item = findUsedAnimalDraft.elements().item(i);
			item.customAttributes.usedNumberOfAnimals = usedCount;
			?'update {{_Species._attribute0}} Pain Category {{usdaPainCategory.Category}} used count => '+item.customAttributes.usedNumberOfAnimals+'\n';
		}
	{{/each}}
	}
	else{
		?'iacucDraftUsedAnimalCount does not exist => '+iacucDraftUsedAnimalCount+'\n';
	}





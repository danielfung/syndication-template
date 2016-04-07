			var iacucStudy = '{{studyDetails.iacucProtocol}}';
			var iacucStudyExist = ApplicationEntity.getResultSet('_ClickIACUCSubmission').query("ID='"+iacucStudy+"'");
			if(iacucStudyExist.count() > 0){
				iacucStudyExist = iacucStudyExist.elements().item(1);
				?'IACUC Study(Exist) Found =>'+iacucStudyExist+'\n';
				var name = '{{name}}';
				var id = iacuc_id;
				var date = new Date();
				var activity = _ClickIACUCSubmission_CopySubmission.createEntity();
				?'_ClickIACUCSubmission_CopySubmission created =>'+activity+'\n';
				activity.setQualifiedAttribute('customAttributes.newStudyName', name);
				?'activity set newStudyName =>'+activity.customAttributes.newStudyName+'\n';
				activity.setQualifiedAttribute('customAttributes.newStudyID', id);
				?'activity set newstudyID =>'+activity.customAttributes.newStudyID+'\n';
				activity.dateCreated = date;
				?'activity set dateCreated =>'+activity.dateCreated+'\n';
				activity.dateModified = date;
				?'activity.dateModified =>'+activity.dateModified+'\n';
				activity.loggedFor = iacucStudyExist;
				?'activity.loggedFor =>'+activity.loggedFor+'\n';
				activity.notesAsStr = "Copy in progress...Refresh the new page and repeat until copy completes.";
				?'activity.notesAsStr =>'+activity.notesAsStr+'\n';

				var activityPersonEditable = Person.createEntitySet();
				activity.setQualifiedAttribute("customAttributes.studyTeamMemberEdit", activityPersonEditable);
				activityPersonEditable = activity.customAttributes.studyTeamMemberEdit;

				var activityPersonNonEditable = Person.createEntitySet();
				activity.setQualifiedAttribute("customAttributes.studyTeamMemberNonEdit", activityPersonNonEditable);
				activityPersonNonEditable = activity.customAttributes.studyTeamMemberNonEdit;

				{{#if studyDetails.studyDepartmentalAdmin.userId}}
					var person = ApplicationEntity.getResultSet("Person").query("userID = '{{studyDetails.studyDepartmentalAdmin.userId}}'").elements();
					if(person.count() == 1){
						person = person.item(1);
						activity.setQualifiedAttribute('customAttributes.departmentAdministrator', person);
						?'set person to department administrator => {{studyDetails.studyDepartmentalAdmin.userId}}\n';
					}
					else{
						?'department administrator(person) not found by userID => {{studyDetails.studyDepartmentalAdmin.userId}}\n';
					}
				{{/if}}

				{{#each studyDetails.otherStudyStaff}}
					var person = ApplicationEntity.getResultSet("Person").query("userID = '{{userId}}'").elements();
					if(person.count() == 1){
						person = person.item(1);
						activityPersonEditable.addElement(person);
						?'added person to edit list => {{userId}}\n';
					}
					else{
						?'study team can edit(person) not found by userID => {{userId}}\n';
					}
				{{/each}}				


				{{#each studyDetails.teamCanNotEdit}}
					var person = ApplicationEntity.getResultSet("Person").query("userID = '{{userId}}'").elements();
					if(person.count() == 1){
						person = person.item(1);
						activityPersonNonEditable.addElement(person);
						?'added person to non edit list => {{userId}}\n';
					}
					else{
						?'study team cant edit(person) not found by userID => {{userId}}\n';
					}
				{{/each}}

				var thisRequest = EntityCloner.createRequest(activity, iacucStudyExist, "Copied submission.");
				?'create request =>'+thisRequest+'\n';
				if (thisRequest==null) {
		        	?"The clone request could not be created.\n";
		    	}
		    	else{
		    		thisRequest.startRequest();
		    		?'starting copy\n';
		    	}
			}
			else{
				?'IACUC Protocol To Copy From Does Not Exist =>{{studyDetails.iacucProtocol}}\n';
				?'RN Study ID =>{{id}}\n';
				?'RN Current Status =>{{status}}\n';
			}
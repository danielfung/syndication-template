var invoiceId = "{{this.id}}";
var parentProtocol = "{{parentProtocol}}";
var billingPeriod = "{{billingPeriod}}";

var existParent = ApplicationEntity.getResultSet("_IACUC Study").query("ID='"+parentProtocol+"'");
var existInvoice = ApplicationEntity.getResultSet("_Invoice").query("ID='"+invoiceId+"'");
var existingCensus = ApplicationEntity.getResultSet("_AnimalCensus").query("ID = '" + billingPeriod + "'");
if(existParent.count() > 0){
	if(existingCensus.count() > 0){
		if(existInvoice.count()  == 0){
			existParent = existParent.elements().item(1);
			?'parentProtocol => '+existParent.id+'\n';
			var pi = existParent.customAttributes._attribute7;
			?'pi from parentProtocol => '+pi+'\n';

			existingCensus = existingCensus.elements().item(1);
			?'existing billing period found => '+existingCensus+'\n';
			var censusStartDate = existingCensus.getQualifiedAttribute("customAttributes.periodStart");
			?'billing period start date => '+censusStartDate+'\n';
			var censusEndDate = existingCensus.getQualifiedAttribute("customAttributes.periodEnd");
			?'billing period end date => '+censusEndDate+'\n';
			var activitySheets = existingCensus.getQualifiedAttribute("customAttributes.censusActivitySheets");
			?'billing period activitySheets => '+activitySheets+'\n';
			var activitySheetsForThisStudy = activitySheets.query("customAttributes.protocol.ID = '" + this.ID + "'");
			var activitySheetsForThisStudyElements = activitySheetsForThisStudy.elements();
			var activitySheetsForThisStudyCount = activitySheetsForThisStudyElements.count();
			
			var invoice;
			var clickOrg = EntityUtils.getObjectFromString("com.webridge.account.Party[OID[370065601E37D94DB1A2AF6261A90264]]");

			invoice = Project.CreateProject("_Invoice", Person.getCurrentUser(), clickOrg, Person.getCurrentUser(), null);
			?'created invoice => '+invoice+'\n';
			invoice.id = invoiceId;
			?'setting invoice id => '+invoiceId+'\n';

			invoice.setQualifiedAttribute("customAttributes.forProject", existParent);
			?'setting forProject =>'+invoice.custoMAttributes.forProject+'\n';

			invoice.setQualifiedAttribute("customAttributes.census", existingCensus);
			?'setting existing census => '+existingCensus.id+'\n';

			invoice.setQualifiedAttribute("customAttributes.billingPeriodStartDate", censusStartDate);
			?'set invoice billingPeriod start date => '+invoice.customAttributes.billingPeriodStartDate+'\n';

			invoice.setQualifiedAttribute("customAttributes.billingPeriodEndDate", censusEndDate);
			?'set invoice billingPeriod end date => '+invoice.customAttributes.billingPeriodEndDate+'\n';
			
			invoice.name="Invoice for "+pi.fullName()+"-" + existParent.id;
			?'set name => '+invoice.name+'\n';

			invoice.customAttributes.forIACUCProtocol=existParent;
			?'setting forIACUCProtocol => ' +invoice.customAttributes.forIACUCProtocol+'\n';

			invoice.customAttributes.pi=pi;
			?'setting pi => '+invoice.customAttributes.pi+'\n';

			for(var i = 1; i <= activitySheetsForThisStudyCount; i++){
				existingCensus.addChargeItems(invoice, activitySheetsForThisStudyElements.item(i));
			}

			var parentResourceContainer = existParent.resourceContainer;
			?'parentResourceContainer => '+parentResourceContainer+'\n';

			invoice.createWorkspace(parentResourceContainer,null);
			?'created invoice workspace => '+invoice.resourceContainer+'\n';

			{{#if status.oid}}
				var status =  entityUtils.getObjectFromString('{{status.oid}}');
				invoice.status = status;
				?'setting status => '+invoice.status+'\n';
			{{/if}}

		}
		else{
			existInvoice = existInvoice.elements().item(1);
			?'invoice found => '+existInvoice+'\n';
		}
	}
	else{
		?'billing period not found => '+existingCensus+'\n';
	}

}
else{
	?'parentProtocol not found => '+parentProtocol+'\n';
}
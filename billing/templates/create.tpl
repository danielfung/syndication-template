
var monthString = "{{month}}";
var censusYear = "{{year}}";

var censusName = monthString + " " + censusYear;

var census;
var existingCensus = ApplicationEntity.getResultSet("_AnimalCensus").query("name = '" + censusName + "'").elements();
var ClickOrg = EntityUtils.getObjectFromString("com.webridge.account.Party[OID[370065601E37D94DB1A2AF6261A90264]]");

if(existingCensus.count() == 0){
	census = Project.CreateProject("_AnimalCensus", Person.getCurrentUser(), ClickOrg, Person.getCurrentUser(), null);
	?'created _AnimalCensus Project => '+census+'\n';
 	census.setQualifiedAttribute("name", censusName);
 	?'setting animal census name => '+censusName+'\n';
 	var parentContainer=EntityUtils.getObjectFromString("com.webridge.entity.Entity[OID[98C1BE5039023940BF40B8E15866784A]]");
	census.createWorkspace(parentContainer, null);
	?'creating animal census workspace with parentContainer => '+parentContainer+'\n';

	var lastDate = LastDayOfMonth(censusYear, (censusMonth+1));
	var periodEndDate = new Date(censusYear, censusMonth, lastDate);
	var periodStartDate = new Date(cenusYear, monthString, 1);
		
	census.setQualifiedAttribute("customAttributes.periodStart", periodStartDate);
	?'setting period start => '+periodStartDate+'\n';
	census.setQualifiedAttribute("customAttributes.periodEnd", periodEndDate);
	?"setting period End => " + periodEndDate+'\n';

	var CAS = census.getQualifiedAttribute("customAttributes.censusActivitySheets");
	if(CAS == null){
		census.setQualifiedAttribute("customAttributes.censusActivitySheets", ApplicationEntity.createEntitySet("_CensusActivitySheet"));
	}
}
else{
	census = existingCensus.item(1);
	?'cesus already exists => '+census+'\n';
}
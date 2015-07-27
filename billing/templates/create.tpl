
var monthString = {{month}}; //#
var year = "{{year}}"; //#
var censusID = {{id}};

var month=new Array(12);
month[0]="January";
month[1]="February";
month[2]="March";
month[3]="April";
month[4]="May";
month[5]="June";
month[6]="July";
month[7]="August";
month[8]="September";
month[9]="October";
month[10]="November";
month[11]="December";

var monthStringName = month[monthString - 1];
var censusName = monthStringName + " " + year;

var census;
var existingCensus = ApplicationEntity.getResultSet("_AnimalCensus").query("name = '" + censusName + "'").elements();
var ClickOrg = EntityUtils.getObjectFromString("com.webridge.account.Party[OID[370065601E37D94DB1A2AF6261A90264]]");

if(existingCensus.count() == 0){
	census = Project.CreateProject("_AnimalCensus", Person.getCurrentUser(), ClickOrg, Person.getCurrentUser(), null);
	?'created _AnimalCensus Project => '+census+'\n';
	census.id = censusID;
	?'setting census id => '+census.id+'\n';
 	census.setQualifiedAttribute("name", censusName);
 	?'setting animal census name => '+censusName+'\n';
 	var parentContainer=EntityUtils.getObjectFromString("com.webridge.entity.Entity[OID[98C1BE5039023940BF40B8E15866784A]]");
	census.createWorkspace(parentContainer, null);
	?'creating animal census workspace with parentContainer => '+parentContainer+'\n';

	var periodStartDate = new Date(year, monthString-1, 1);
	var censusMonth = periodStartDate.getMonth();
	var censusYear = periodStartDate.getFullYear();
	var lastDate = LastDayOfMonth(censusYear, (censusMonth+1));
	var periodEndDate = new Date(censusYear, censusMonth, lastDate);

	function LastDayOfMonth(Year, Month)
	{
		return(new Date((new Date(Year, Month,1))-1)).getDate();
	}
			
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
1. Installation:
	- git clone https://github.com/danielfung/syndication-template
	- cd /syndication-template
	- npm install

2. Usage to create studies in IRB/CRMS/IACUC/DLAR

example to create IACUC Submission: 
curl -d '{
"id":"Test12345",
"name":"Test Name",
"topaz":{"protocolNumber":{"id":"1"},
"principalInvestigator":{"userId":"Doe02"},
"projectStatus":{"oid":"com.webridge.entity.Entity[OID[123123]]"},
"protocolType":{"oid":"com.webridge.entity.Entity[asdasd95C0A]]"},
"submissionType":{"oid":"com.webridge.entity.Entity[OID[123123123]]"}}
}' -H "Content-Type: application/json" http://10.137.100.55:4441/iacuc

- To Create IRB/CRMS _uid is expected
- To Create IACUC/DLAR either _uid or id is expected

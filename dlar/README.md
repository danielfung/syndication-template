#DLAR

1. Species will be match by name and usda.

 ```
Example: Name: Rat, USDA: No(false)

 ```
2. Locations will be matched depending on type:example) Building
 ```
facilityRoom => Room - will be found by Room #, and Building Name
facilityBuilding => Building - will be found by Building Name
 ```

3. ID used in DLAR.IACUC

 ```
protocolNumber => ID
 ```

4a. DATA MIGRATION: IACUC STUDY ORIGINAL Sample JSON Format:
 ```
{
 "id":"TEST12345:ORIGINAL",
 "name":"TESTING IACUC STUDY",
 "topaz":{"protocolNumber":{"id":"1234156"},
 		  "principalInvestigator":{"userId":"test01"},
 		  "projectStatus":{"oid":"com.webridge.entity.Entity[OID[123456789qwerty]]"},
 		  "protocolType":{"oid":"com.webridge.entity.Entity[OID[123456789qwerty]]"},
 		  "submissionType":{"oid":"com.webridge.entity.Entity[OID[123456789qwerty]]"}
 		  }
 }

 ```
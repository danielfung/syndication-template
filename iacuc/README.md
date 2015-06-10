#IACUC

1. RN -> IACUC ORIGINAL Sample JSON Format:
 ```
{
 "id":"s18-00001",
 "name":"TESTING IACUC STUDY",
 "company":"{"id":"8120391809231AFAFA"}",
 "studyDetails":{"longTitle":"TEST LONG TITTLE",
 		         "principalInvestigator":{"userId":"test01"},
 		         "protocolType":{"type":"New Animal Protocol"},
 		         "subjectType":"{"type":"Animal"}"
 		         ....
 		        }
 "_uid":"18-00001"
 }

 ```

2a. DATA MIGRATION: IACUC ORIGINAL Sample JSON Format:
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

 2b. DATA MIGRATION: IACUC AMENDMENT/RENEWEL Sample JSON Format:
 ```
{
 "id":"TEST12345:AMEND",
 "name":"TESTING IACUC STUDY",
 "topaz":{"protocolNumber":{"id":"1234156"},
 		  "principalInvestigator":{"userId":"test01"},
 		  "projectStatus":{"oid":"com.webridge.entity.Entity[OID[123456789qwerty]]"},
 		  "protocolType":{"oid":"com.webridge.entity.Entity[OID[123456789qwerty]]"},
 		  "submissionType":{"oid":"com.webridge.entity.Entity[OID[123456789qwerty]]"}
 		  "draftProtocol":{"id":"TEST12345:ORIGINAL"}
 		  }
 }

 ```
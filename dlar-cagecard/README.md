#DLAR - CAGE CARD

1a. DATA MIGRATION: DLAR Cage Card Sample JSON Format:
 ```
 ID Format: ProtocolNumber:CageCardID
 ParentProtocol: Protocol Number
 CreatedBy: If null => default to administrator

{
 "id":"1235-01:CAGEId",
 "name":"TESTING CAGE CARD",
 "topaz":{
 		  "createdBy":{"userId":"test01"},
 		  "status":{"id":"com.entity[OID[123132123]"}
 		 }
 }

 ```
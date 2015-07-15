#DLAR - Animal Order Line Item

1a. DATA MIGRATION: DLAR Animal Order Line Item Sample JSON Format:
 ```
 ID Format: ProtocolNumber:AOTID:AOLID
 ParentProtocol: Protocol Number
 CreatedBy: If null => default to administrator

{
 "id":"12345-01:12345:AOLID",
 "name":"TESTING ANIMAL ORDER LINE ITEM",
 "topaz":{
 		  "createdBy":{"userId":"test01"},
 		  "status":{"oid":"com.webridge[OID[1839208109238]]"}
 		 }
 }

 ```
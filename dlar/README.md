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

 4. DATA MIGRATION(DLAR)

 ```
Items Needed To Be Added To JSON:
topaz.status.id -> will use this as the status otherwise default to Pending Account Status
topaz.id -> will use this as ID
 ```

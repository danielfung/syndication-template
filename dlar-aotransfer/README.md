#DLAR - Animal Order Transfer

1a. DATA MIGRATION: DLAR Animal Order Transfer Sample JSON Format:
 ```
{
 ID Format: ProtocolNumber:AOTID
 ParentProtocol: Protocol Number
 CreatedBy: If null => default to administrator

 {
    id: String,
    animalOrderId: String,
    protocolId: String,
    approvedDate: String, 
    dateSentToVendor: String,
    requestType: { oid: String },
    status: { oid: String },
    orderContact: String,
    standingOrderQuantity: Number
    totalAnimals: Number,
    species: [{oid: String}],
    animalVendor: {oid: String},
    legacyAnimalOrderInfo: {
      createDate: String,  
      legacyOrderNumber: String,
      order: String,
      orderContact: String,
      requisition: String
      species: String,
      status: String,
      animalVendor: String 
    }


 ```
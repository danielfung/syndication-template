#Syndication-Template using Handlebars:

1. Installation:
 ```
    $ git clone https://github.com/danielfung/syndication-template
    $ cd /syndication-template
    $ npm install
 ```

2. Setup as Service: Linux
 ```
    # Copy service scripts
    $ sudo cp node_modules/syndication-template/setup/syndication-template /etc/init.d

    # Optionally restart when server reboots
    $ sudo chkconfig syndication-template on

    # Grant execute rights to the scripts
    $ sudo chmod +x /etc/init.d/syndication-template

    # Start the services
    $ sudo service syndication-template start
   
    # Stop the services
    $ sudo service syndication-template stop
 ```

3a. Usage to create studies in IRB/CRMS/IACUC/DLAR
  - To Create IRB/CRMS _uid is expected
  - To Create IACUC either _uid or id is expected
  - To Create DLAR protocolNumber is expected
  - Example to create IACUC Submission: 
 ```
    $ curl -d '{
      "id":"Test12345",
      "name":"Test Name",
      "topaz":{"protocolNumber":{"id":"1"},
      "principalInvestigator":{"userId":"Doe02"},
      "projectStatus":{"oid":"com.webridge.entity.Entity[OID[123123]]"},
      "protocolType":{"oid":"com.webridge.entity.Entity[asdasd95C0A]]"},
      "submissionType":{"oid":"com.webridge.entity.Entity[OID[123123123]]"}}
      }' -H "Content-Type: application/json" http://10.137.100.55:4441/iacuc
 ```

3b. Animal Order/Animal Order Line Item/Cage Card/Billing/Invoices
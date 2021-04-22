public with sharing class MyController {
    @AuraEnabled(cacheable=true)
    public static List<Contact> findContacts(String searchKey) {
        String key = '%' + searchKey + '%';
        return [
            SELECT Id, Name, Title, Phone, Email
            FROM Contact
            WHERE Name LIKE :key
            WITH SECURITY_ENFORCED
            LIMIT 10
        ];
    }
    @AuraEnabled(cacheable=true)
    public static List<SObject> getRecords(String objectApiName, String[] recordIds, String[] fields){
        if (objectApiName == null){
            throw new AuraHandledException('ObjectApiName must be specified');
        }
        if (recordIds == null){
            throw new AuraHandledException('recordIds must be specified');
        }
        if (fields == null){
            fields = new String[]{'Id','Name'};
        }
        String fieldSelector = String.join(fields, ',');
        return Database.query(
            String.format('SELECT {0} FROM {1} WHERE Id IN: recordIds', new String[]{
                fieldSelector,
                objectApiName
            }));
    }
}
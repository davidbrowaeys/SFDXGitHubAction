@IsTest(SeeAllData=false)
private class MyControllerTest {

    // Helper method to create test Contacts
    private static List<Contact> createTestContacts() {
        // Create an Account to associate Contacts with (best practice)
        Account testAccount = new Account(Name = 'Test Account for Contacts');
        insert testAccount;

        // Create a list of Contacts
        List<Contact> contacts = new List<Contact>();
        contacts.add(new Contact(FirstName = 'John', LastName = 'Doe', Title = 'Sales Rep', Phone = '555-1234', Email = 'john.doe@example.com', AccountId = testAccount.Id));
        contacts.add(new Contact(FirstName = 'Jane', LastName = 'Smith', Title = 'Marketing Mgr', Phone = '555-5678', Email = 'jane.smith@example.com', AccountId = testAccount.Id));
        contacts.add(new Contact(FirstName = 'Peter', LastName = 'Jones', Title = 'Engineer', AccountId = testAccount.Id));

        insert contacts;
        return contacts;
    }

    /**
     * @description Test case for findContacts with a successful search.
     */
    @IsTest
    static void findContacts_Success_FoundRecords() {
        // Setup: Create test data
        List<Contact> insertedContacts = createTestContacts();

        // Test: Call the method with a search key that matches one record (e.g., 'Doe')
        Test.startTest();
        List<Contact> results = MyController.findContacts('Doe');
        Test.stopTest();

        // Assertions
        System.assertEquals(1, results.size(), 'Should find exactly one contact matching "Doe".');
        System.assertEquals('John Doe', results[0].Name, 'The found contact name should match.');
        System.assertNotEquals(null, results[0].Email, 'Email field should not be null.');
    }

    /**
     * @description Test case for findContacts when no records are found.
     */
    @IsTest
    static void findContacts_Success_NoRecordsFound() {
        // Setup: Create test data (but search for something that doesn't exist)
        createTestContacts();

        // Test: Call the method with a search key that won't match any record
        Test.startTest();
        List<Contact> results = MyController.findContacts('ZZZ_NoMatch');
        Test.stopTest();

        // Assertions
        System.assertEquals(0, results.size(), 'Should find zero contacts for a non-matching search key.');
    }
    
    // --- Tests for getRecords ---

    /**
     * @description Test case for getRecords with valid input and default fields.
     */
    @IsTest
    static void getRecords_Success_DefaultFields() {
        // Setup: Create a test Account
        Account acc = new Account(Name = 'Test Account for Query');
        insert acc;

        // Create input parameters
        String objectName = 'Account';
        String[] recordIds = new String[]{acc.Id};
        String[] fields = null; // Test the case where fields is null, defaulting to Id, Name

        // Test
        Test.startTest();
        List<SObject> results = MyController.getRecords(objectName, recordIds, fields);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, results, 'Results list should not be null.');
        System.assertEquals(1, results.size(), 'Should return exactly one record.');
        System.assertEquals(acc.Id, results[0].get('Id'), 'The returned record Id should match.');
        System.assertEquals(acc.Name, results[0].get('Name'), 'The returned record Name should match.');
        // Verify only Id and Name are returned (default fields)
        System.assert(results[0].get('CreatedDate') == null, 'Field not requested (CreatedDate) should be null.');
    }

    /**
     * @description Test case for getRecords with valid input and specific fields.
     */
    @IsTest
    static void getRecords_Success_SpecificFields() {
        // Setup: Create a test Account
        Account acc = new Account(Name = 'Test Account With Revenue', Industry = 'Energy', AnnualRevenue = 1000000.00);
        insert acc;

        // Create input parameters
        String objectName = 'Account';
        String[] recordIds = new String[]{acc.Id};
        String[] fields = new String[]{'Id', 'Name', 'Industry', 'AnnualRevenue'};

        // Test
        Test.startTest();
        List<SObject> results = MyController.getRecords(objectName, recordIds, fields);
        Test.stopTest();

        // Assertions
        System.assertNotEquals(null, results, 'Results list should not be null.');
        System.assertEquals(1, results.size(), 'Should return exactly one record.');
        System.assertEquals(acc.Industry, results[0].get('Industry'), 'The returned record Industry should match.');
        System.assertEquals(acc.AnnualRevenue, results[0].get('AnnualRevenue'), 'The returned record AnnualRevenue should match.');
    }

    /**
     * @description Test case for getRecords when objectApiName is null.
     */
    @IsTest
    static void getRecords_Failure_ObjectApiNameNull() {
        // Setup: Input parameters causing the exception
        String[] recordIds = new String[]{'003000000000000'}; // Dummy ID
        String[] fields = new String[]{'Id'};

        // Test: Check that the AuraHandledException is thrown
        Boolean exceptionCaught = false;
        Test.startTest();
        try {
            MyController.getRecords(null, recordIds, fields);
        } catch (AuraHandledException e) {
            System.assertEquals('ObjectApiName must be specified', e.getMessage(), 'Exception message should indicate missing ObjectApiName.');
            exceptionCaught = true;
        }
        Test.stopTest();

        // Assertion
        System.assert(exceptionCaught, 'An AuraHandledException should have been thrown for null objectApiName.');
    }
    
    /**
     * @description Test case for getRecords when recordIds is null.
     */
    @IsTest
    static void getRecords_Failure_RecordIdsNull() {
        // Setup: Input parameters causing the exception
        String objectName = 'Account';
        String[] fields = new String[]{'Id'};

        // Test: Check that the AuraHandledException is thrown
        Boolean exceptionCaught = false;
        Test.startTest();
        try {
            MyController.getRecords(objectName, null, fields);
        } catch (AuraHandledException e) {
            System.assertEquals('recordIds must be specified', e.getMessage(), 'Exception message should indicate missing recordIds.');
            exceptionCaught = true;
        }
        Test.stopTest();

        // Assertion
        System.assert(exceptionCaught, 'An AuraHandledException should have been thrown for null recordIds.');
    }
}

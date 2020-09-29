public inherited sharing class SyncWithOtherOrg {
    
    @TestVisible
	private static final String CALLOUT_FAIL_MESSAGE = 'Callout Failed';
    
    @TestVisible
    private static Boolean skipSyncing = false;

    private Set<Id> contactIds;
    private static Set<String> relevantFields = relevantFields();

    // CONSTRUCTOR

    public SyncWithOtherOrg(List<Contact> contacts) {
        this(contacts, null);
    }

    
    public SyncWithOtherOrg(List<Contact> contacts, Map<Id, Contact> oldContacts) {
        this.contactIds = filterRelevantRecords(contacts, oldContacts);
    }
    

    // PUBLIC

    public void execute() {
        if(!contactIds.isEmpty() && !skipSyncing) {
            sync(contactIds);
        }
    }


    // PRIVATE
    
    @future(callout=true)
    private static void sync(Set<Id> contactIds) {
        List<Contact> externalContacts = new List<Contact>();
        
        for(Contact contact : new ContactsSelector().byIds(contactIds)) {
            contact.ExternalId__c = contact.Id;
            contact.Id = null;
            externalContacts.add(contact);
        }
        
        try {
            List<SalesforceApi.Response> responses = new SalesforceApi().sendToOrg1(externalContacts); 
            persistSyncState(externalContacts, responses);           
        }
        catch(CalloutException ex) {
            persistSyncState(externalContacts, null);
        }
    }


    private static void persistSyncState(List<Contact> contacts, List<SalesforceApi.Response> responses) {

        for(Integer i = 0; i < contacts.size(); i++) {
            contacts[i].Id = contacts[i].ExternalId__c;
            contacts[i].SyncMessage__c = responses != null ? responses[i].message() : CALLOUT_FAIL_MESSAGE;
            contacts[i].ExternalId__c = responses != null ? responses[i].id : null;
        }
        
        // Note: Disable domain logic to avoid infinite loop
        fflib_SObjectDomain.getTriggerEvent(Contacts.class).disableAll();

        DMLManager.updateAsUser(contacts);
    }


    private Set<Id> filterRelevantRecords(List<Contact> contacts, Map<Id, Contact> oldContacts) {
        Set<Id> result = new Set<Id>();

        for(Contact contact : contacts) {
            Contact oldContact = oldContacts != null ? oldContacts.get(contact.Id) : null;

            if(oldContact == null || isChanged(contact, oldContact)) {
                result.add(contact.Id);
            }
        }

        return result;
    }


    public static Boolean isChanged(Contact contact, Contact oldContact) {
        Boolean result = false;

        for(String field : relevantFields) {
            if(contact.get(field) != oldContact.get(field)) {
                result = true;
                break;
            }
        }

        return result;
    }


    private static Set<String> relevantFields() {
        Set<String> result = new Set<String>();

        for(Schema.FieldSetMember field : SObjectType.Contact.FieldSets.RelevantFields.getFields()) {
            result.add(field.getFieldPath());
        }

        return result;
    }
}
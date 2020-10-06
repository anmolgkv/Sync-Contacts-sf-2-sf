public with sharing class SetPendingStatus {
    private List<Contact> contacts;

    // CONSTRUCTOR

    public SetPendingStatus(List<Contact> contacts) {
        this.contacts = contacts;
    }


    // PUBLIC
    
    public void execute() {
        for(Contact contact : contacts) {
            contact.SyncMessage__c = 'Pending';
        }
    }
}

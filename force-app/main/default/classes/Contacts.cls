public with sharing class Contacts extends fflib_SObjectDomain {

    // CONSTRUCTOR

    public Contacts(List<Contact> sObjectList) {
        super(sObjectList);
    }


    // PUBLIC

    public override void onBeforeInsert() {
        new SetPendingStatus(records).execute();
    }


    public override void onBeforeUpdate(Map<Id, SObject> old) {
        List<Contact> changedContacts = changed( cast(old) );

        new SetPendingStatus(changedContacts).execute();
    }


    public override void onAfterInsert() {
        new SyncWithOtherOrg(records).execute();
    }


    public override void onAfterUpdate(Map<Id, SObject> old) {
        List<Contact> changedContacts = changed( cast(old) );

        new SyncWithOtherOrg(changedContacts).execute();
    }


    // PRIVATE

    private List<Contact> changed(Map<Id, Contact> oldContacts) {
        List<Contact> result = new List<Contact>();

        for(Contact contact : cast(records)) {
            Contact oldContact = oldContacts.get(contact.Id);

            if(isChanged(contact, oldContact)) {
                result.add(contact);
            }
        }

        return result;
    }   


    private static Boolean isChanged(Contact contact, Contact oldContact) {
        Boolean result = false;

        for(String field : relevantFields()) {
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


    private List<Contact> cast(List<SObject> uncasted) {
        return (List<Contact>) uncasted;
    }


    private Map<Id, Contact> cast(Map<Id, SObject> uncasted) {
        return (Map<Id, Contact>) uncasted;
    }


    // INNER

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new Contacts(sObjectList);
        }
    }
}
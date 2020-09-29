public with sharing class Contacts extends fflib_SObjectDomain {

    // CONSTRUCTOR

    public Contacts(List<Contact> sObjectList) {
        super(sObjectList);
    }


    // PUBLIC

    public override void onBeforeInsert() {
        new SetPendingStatus(cast(records)).execute();
    }


    public override void onBeforeUpdate(Map<Id, SObject> old) {
        new SetPendingStatus(cast(records), cast(old)).execute();
    }


    public override void onAfterInsert() {
        new SyncWithOtherOrg(cast(records)).execute();
    }


    public override void onAfterUpdate(Map<Id, SObject> old) {
        new SyncWithOtherOrg(cast(records), cast(old)).execute();
    }


    // PRIVATE

    private List<Contact> cast(List<SObject> records) {
        return (List<Contact>) records;
    }


    private Map<Id, Contact> cast(Map<Id, SObject> records) {
        return (Map<Id, Contact>) records;
    }


    // INNER

    public class Constructor implements fflib_SObjectDomain.IConstructable {
        public fflib_SObjectDomain construct(List<SObject> sObjectList) {
            return new Contacts(sObjectList);
        }
    }
}
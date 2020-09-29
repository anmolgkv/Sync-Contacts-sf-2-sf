public inherited sharing class ContactsSelector extends fflib_SObjectSelector {

    // CONSTRUCTOR

    public ContactsSelector() {
        super(true);
    }


    // PUBLIC

    public Schema.SObjectType getSObjectType() {
        return Contact.SObjectType;
    }


    public List<Schema.SObjectField> getSObjectFieldList() {
        return new List<Schema.SObjectField> { Contact.Id };
    }


    public override List<Schema.FieldSet> getSObjectFieldSetList() {
        return new List<Schema.FieldSet> {
            SObjectType.Contact.FieldSets.RelevantFields
        };
    }


    public List<Contact> byIds(Set<Id> ids) {
        return (List<Contact>) selectSObjectsById(ids);
    }
}
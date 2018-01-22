module directors.profile;

import std.stdio;
import std.variant;

import eventmanager.all;
import relationaldb.all;
import helpers.helperfactory;
import helpers.emailHelper;
import container;

import commands.updateuser;
import projections.profile.updateuser;

import commands.changeemail;
import projections.profile.changeemail;

import commands.changepassword;
import projections.profile.changepassword;

class ProfileDirector : EventListenerInterface
{
    private RelationalDBInterface relationalDb;
    private HelperFactory helperFactory;
    
    this(Container container) @safe
    {
        this.relationalDb = container.getRelationalDb();
        this.helperFactory = container.getHelperFactory();
    }
    
    public TypeInfo[] getInterestedEvents() {
        return [
            typeid(ChangeEmailCommand),
            typeid(UpdateUserCommand),
            typeid(ChangePasswordCommand),
        ];
    }

    public EventListInterface handleEvent(EventInterface event, TypeInfo eventType) @trusted
    {
        const string eventTypeStr = eventType.toString();

        debug {
            writeln("DataDirector received event: ", eventTypeStr);
        }

        auto eventList = new EventList();
        auto metaVariant = event.getMetadata();

        if (eventType == typeid(UpdateUserCommand)) {
            auto meta = *metaVariant.peek!(UpdateUserMeta);
            auto handler = new UpdateUserProjection(this.relationalDb, meta);
            handler.handleEvent();
        } else if (eventType == typeid(ChangeEmailCommand)) {
            auto meta = *metaVariant.peek!(ChangeEmailMeta);
            auto handler = new ChangeEmailProjection(this.relationalDb, meta);
            handler.handleEvent();
        } else if (eventType == typeid(ChangePasswordCommand)) {
            auto meta = *metaVariant.peek!(ChangePasswordMeta);
            auto handler = new ChangePasswordProjection(this.relationalDb, this.helperFactory, meta);
            handler.handleEvent();
        } else {
            debug {
                writeln("ProfileDirector::handleEvent - Unhandled event type: ", eventType);
            }
        }   

        return eventList;
    }
}
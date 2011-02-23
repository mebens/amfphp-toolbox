### Version 2.1.1 - February 23, 2011

A small fix to CallQueue and a change of license to zlib/libpng. This means that AMFPHP Toolbox is now totally open source.

### Version 2.1 - October 22, 2010

This update adds a number of conveniences, fixes a few bugs, and decreases the chances of conflicting with other libraries.

**Changes**

* To reduce the chance of confliction with other libraries, the Connection class is now named AmfphpGateway. It's still referred to as "the connection object" in the documentation.
* The ConnectionBase class has been merged into the Connection class, as it was unneeded.
* The Call, CallSet, and CallQueue classes now return themselves in a number of methods (see documentation). This allows for things like inline adding of listeners: new Call("service.method").addListeners(rl, fl);
* A few bug fixes.

### Version 2.0 - August 6, 2010

The final release of version 2.0. This version has re-worked internal data structures (using the as3ds library) for more efficiency, some adjustments to the listening system, and a new class CallQueue.

**Changes**

* More efficient internal data structures
* The new CallQueue class, which adds the ability to call services in a queue like manner
* Adjustments to the listening system, listeners are now added directly on Call objects (the Connection object still has it's methods though)
* No more AMFPHPEvent class. Event constants moved to CallEvent, and the TIMER_CALL event has been replaced by TimerEvent.TIMER
* A few other fixes here and there

### Version 2.0 Beta

This was a huge change, a number of new classes were introduced and just about everything was re-worked. There was still support for the old way of doing things (in AMFPHPConnection), in two classes. However, there were a number of bugs in this release (therefore a beta version), and the internal data structures weren't great.

### Version 1.0 - 1.1

You might be wondering why the version number is 2.0 when it seems like this package is just starting off. The answer the that, lies in where the package comes from. Not too long ago, I made a class called AMFPHPConnection; it was single class that did a fair bit of what the package currently does (not as well however). That class has expanded into a multi-class package, that has a number of classes, does things more effectively, and does more. The last version of AMFPHPConnection was 1.1, and since the change to the AMFPHP Toolbox package was so big (major re-working of how the system works) I decided to move the version number up to 2.0.
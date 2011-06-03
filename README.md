Do you use AMFPHP for remoting? If so, you might find AMFPHP Toolbox of some interest. This ActionScript library takes care of laying the groundwork for you (you know, all the boring bits of setting up connections, responders, etc.), and then helping you along the way with some extra tools.

# Quick Example

**Normal Code**

``` actionscript3
var nc:NetConnection = new NetConnection;
var resp:Responder   = new Responder(onResult, onFault);
nc.connect("http://localhost/amfphp/gateway.php");

function onResult(result:Object):void
{
    trace(String(result));
}

function onFault(fault:Object):void
{
    trace(fault.description);
}

nc.call("SomePackage.SomeClass.someMethod", resp, "param1", "param2");
nc.call("SomePackage.SomeClass.anotherMethod", resp, "param3", "param4");
```

**Code with AMFPHP Toolbox**

``` actionscript3
var nc:AmfphpGateway = new AmfphpGateway("http://localhost/amfphp/gateway.php", "SomePackage.SomeClass");
nc.talk("$1.someMethod", "param1", "param2");
nc.talk("$1.anotherMethod", "param3", "param4");
```

It turns out that both these examples do pretty much the same thing, the main difference is that the first uses just the Flash classes (the traditional way to do it) and the second uses AMFPHP Toolbox. To get started please take a look at the list of tutorials. Then take a look at the ASDoc documentation (included in the download).

By the way, the library was [recommended](http://twitter.com/#!/amfphp/status/19239004297) by the developers of AMFPHP. Thanks guys!

A quick note of thanks to the developer of [as3ds](http://lab.polygonal.de/ds/), an ActionScript library with some great data structures, which is used in AMFPHP toolbox.

# Main Features

* Manages the setup of connection
* Manages Responders
* Easy setup of result/fault listeners
* Cut typing time of common service names with Quick Service Referencing
* Call many calls with one command with CallSets
* CallSets also allow those calls to be called on a timed basis
* Call your services in a queue with CallQueues

/**
 * Package information:
 * A set of classes to make using AMFPHP quicker, 
 * easier, and more productive.
 * Version 2.1
 * 
 * Library information:
 * The NovaFusion AS3 library is licensed under the 
 * Simplified BSD License. See LICENSE.txt.
 *
 * GitHub repository currently located at
 * http://github.com/BlackBulletIV/NovaFusion-AS3-Library
 * Visit repository for the latest source code.
 *
 * Made by NovaFusion (www.nova-fusion.com)
 */
package com.novafusion.net.amfphp 
{
    import de.polygonal.ds.Iterator;
    import de.polygonal.ds.HashMap;
    import flash.net.NetConnection;
    import flash.net.Responder;
    
    /**
     * <p>This is the main connection class, through which you will
     * connect to the AMFPHP gateway. It inherits from NetConnection, 
     * and therefore provides access to all it's features.</p>
     * <p>This class holds Call objects, the object which holds the
     * data necessary to make calls to AMFPHP. You can add call
     * objects via the addCall() method. You can make calls via the
     * talk() method.</p>
     * <p>This class can also hold references to CallSets and
     * CallQueues. See their documentation for more information.</p>
     *
     * @author  NovaFusion
     * @since   2.0 beta
     * @see     Call
     * @see     CallSet
     * @see     CallQueue
     * @example Here's some example code of how to setup your connection.
     * <code>var nc:AmfphpGateway = new AmfphpGateway("http://localhost/amfphp/gateway.php");
     * nc.talk(new Call("Somewhere.noWhere", 
     *                  "param1", 2, "and 3").addListeners(onResult, onFault));
     * 
     * function onResult(event:CallEvent):void
     * {
     *     // do some stuff...
     *     trace(String(event.result));
     * }
     * 
     * function onFault(event:CallEvent):void
     * {
     *     // do some stuff...
     *     trace(event.description);
     * }
     * </code>
     */
    public class AmfphpGateway extends NetConnection
    {
        private var _resultListener:Function; // the function to call when a result is encountered
        private var _faultListener:Function;  // the function to call when a fault is encountered
        private var _gateway:String;          // the string to the AMFPHP gateway
        
        private var _services:Array = new Array();   // and array of the service references stored within this object
        private var _calls:HashMap = new HashMap();  // hash map of call objects
        private var _sets:HashMap = new HashMap();   // hash map of call sets
        private var _queues:HashMap = new HashMap(); // hash map of call queues
        
        /**
         * Whether or not to enable quick service referencing.
         * @default true
         */
        public var serviceStoring:Boolean = true;
        
        /**
         * Sets up the properties and connects to the gateway with the string provided.
         * @param gateway The url of the AMFPHP gateway to connect to. If this is nothing, a connection won't be made.
         */
        public function AmfphpGateway(gateway:String = "http://localhost/amfphp/gateway.php", ...services) 
        {
            _gateway = gateway;
            _services.push.apply(this, services); // using the apply method to use an array as a comma seperated list of parameters
            
            if (_gateway != "")
            {
                connect(this._gateway);
            }
        }
        
        //------ CALLING FUNCTIONS ------//
        /**
         * The overridden version of the call function, which 
         * allows support for quick service referencing and passing
         * in null as the responder for ease of use. This function
         * does not support the use of objects, and is the core way
         * to call a service through AMFPHP. (apart from the original
         * NetConnection's call function)
         * 
         * @param service The service to call.
         * @param responder The responder object. Can be null, and if so the default responder will be used.
         * @param params The parameters to pass to the service
         */
        override public function call(service:String, responder:Responder, ...params):void
        {
            // if service storing is on and the user has provided a service number (i.e. $2)
            if (serviceStoring && (service.search(/^\$\d/)) > -1)
            {
                var searchIndex:Number = service.search(/\d/); // the index of the number
                var serviceIndex:Number = Number(service.substr(searchIndex, searchIndex)) - 1; // Get the number itself by using the index returned 
                service = service.replace(/^\$\d/, _services[serviceIndex]); // replace the service identifier with the proper name out of the services array
            }
            
            params.unshift(service, responder); // add these parameters to the front of the array, to be used as parameters when call the call() function
            super.call.apply(this, params); // call the original call function, using the apply method and passing in the parameters
        }

        /**
         * This function is a gateway to the call sending
         * function, allowing the use of the new objects.
         * It can take a call object, or a service string 
         * and the parameters (out of which will be made a
         * call object) in a comma seperated parameters list.
         * If the call doesn't exist it will be added to the
         * object's array of call objects. If your custom
         * listener functions have not been added to this call
         * object, they will be added to make sure they get
         * called when a result or fault occurs.
         *
         * @param params The restParam to hold the parameters for this function. It works the same way as addCall()'s restParam.
         */
        public function talk(...params):void 
        {
            var callObj:Call = this.addCall.apply(this, params); // this will get the call object and take the appropriate actions for this call object. The reason we have to use apply is the user may provide more than one parameter (if they just provide the service name and parameters to be passed to the service.
            var listeners:Array = [null, null]; // array to hold the listeners to add to the call object (if any)
            
            // we want to make sure that the user has their event listeners added before calling
            if (callObj.hasEventListener(CallEvent.RESULT) === false && _resultListener != null)
            {
                listeners[0] = _resultListener; // we want to add a result listener
                callObj.autoTraceResults = false; // we won't need this anymore. If we didn't do this, there would be two methods called on a result
            }
            
            if (callObj.hasEventListener(CallEvent.FAULT) === false && _faultListener != null)
            {
                listeners[1] = _faultListener; // we want to add a fault listener
                callObj.autoTraceFaults = false; // we won't need this anymore. If we didn't do this, there would be two methods called on a fault
            }
            
            // add the listeners (if any). [0] is the result listener, and [1] is the fault listener
            callObj.addListeners(listeners[0], listeners[1]);
            
            var callParams:Array = [callObj.service, callObj.responder];
            callParams.push.apply(this, callObj.params); // adding the parameters to the parameters array
            call.apply(this, callParams);
        }

        //------ CALL OBJECT FUNCTIONS ------//
        /**
         * Adds a call object to this connection's call array.
         * You can specify the service string as the first
         * parameter, and the arguments/parameters to be passed
         * to AMFPHP after that; or you can create the call
         * object with new Call() and pass in the parameters
         * there, exactly the same way. If the call object
         * already exists (based on whether the parameters and
         * service string are the same) the object that already
         * exists will be returned. If not, the object will be
         * created if needed and added in. The call id will be
         * generated and then the object will be returned.
         *
         * @param params The restParam to represent the parameters needed. Can either be a call object, or the service string, and then parameters/arguments to be passed to AMFPHP in a comma seperated list of parameters.
         * @return Either the object that was added in (with it's id), or the object that exists within this connection.
         */
        public function addCall(...params):Call
        {
            var callObj:Call = null; // The call object to be used
            var listeners:Array = [null, null];
            
            if (params[0] is Call) // if the first parameter is an already made call object
            {
                callObj = params[0];
                
                // loop through all the call objects we have...
                for (var i:Iterator = _calls.getIterator(); i.hasNext(); i.next())
                {
                    // they want the same thing as we already have...
                    if (i.data.service === callObj.service && i.data.params == callObj.params)
                    {
                        return i.data;
                    }
                }
            }
            else if (params[0] is String) // if a string is the first parameter (meaning a service string)
            {
                callObj = new Call(params[0]); // that passes in the service string
                params.shift(); // that gets rid of the service string...
                callObj.addParams.apply(callObj, params); // so we can just supply the parameters to be added in to the call object
            }
            
            // if we get down here, we didn't find an already existing match
            
            var id:uint = _calls.size; // the current size of the hash map is the call's id
            callObj.callId = id;
            
            // add default listeners
            if (callObj.hasEventListener(CallEvent.RESULT) === false && _resultListener != null)
            {
                listeners[0] = _resultListener; // we want to add a result listener
                callObj.autoTraceResults = false; // we won't need this anymore. If we didn't do this, there would be two methods called on a result
            }
            
            if (callObj.hasEventListener(CallEvent.FAULT) === false && _faultListener != null)
            {
                listeners[1] = _faultListener; // we want to add a fault listener
                callObj.autoTraceFaults = false; // we won't need this anymore. If we didn't do this, there would be two methods called on a fault
            }
            
            callObj.addListeners(listeners[0], listeners[1]);
            _calls.insert(id, callObj); // insert the call object with it's id
            return callObj;
        }
        
        /**
         * Adds a call set the connection object.
         * @return The CallSet object that was added (with it's id).
         */
        public function addCallSet(setObj:CallSet):CallSet 
        {
            setObj.setId = _sets.size;
            _sets.insert(setObj.setId, setObj);
            return setObj;
        }
        
        public function addCallQueue(queueObj:CallQueue):CallQueue
        {
            queueObj.queueId = _queues.size;
            _queues.insert(queueObj.queueId, queueObj);
            return queueObj;
        }

        /**
         * A function thats gets a call id. You can specify how many calls back you want to go in the stepsBack parameter.
         * @param stepsBack How many steps back in the history of call object assignments you want to go. The default is 0, which is the last call assigned. If you used 2 in the parameter it would get the id of the third call object back.
         */
        public function getCallId(stepsBack:uint = 0):uint 
        {
            return _calls.size - stepsBack;
        }

        /**
         * Works exactly in the same manner as getCallId() except for call sets.
         * 
         * @param   stepsBack   See the steps back parameter of getCallId()
         * @see     getCallId()
         * @see     getQueueId()
         */
        public function getSetId(stepsBack:uint = 0):uint 
        {
            return _sets.size - stepsBack;
        }
        
        /**
         * Works exactly in the manner as getSetId() and getCallId() except for call queues.
         * 
         * @param   stepsBack   See the steps back parameter of getCallId() or getSetId()
         * @see     getCallId()
         * @see     getSetId()
         */
        public function getQueueId(stepsBack:uint = 0):uint
        {
            return _queues.size - stepsBack;
        }
        
        //------ QUICK SERVICE REFERENCING FUNCTIONS ------//
        /**
         * Adds in a list of strings representing quick paths to services to the services array
         *
         * @param services Comma seperated individual strings of quick paths to services
         */
        public function addServices(...services):void
        {
            for each (var service:String in services)
            {
                _services.push(service); // add the item into the array
            }
        }
        
        /**
         * Removes a list of strings representing quick paths to services from the services array
         *
         * @param services Comma seperated individual strings of quick paths to services
         */
        public function removeServices(...services):void
        {
            for each (var service:String in services)
            {
                _services.splice(_services.indexOf(service), 1); // delete the item from the array
            }
        }

        //------ LISTENER/HANDLER FUNCTIONS ------//
        /**
         * Sets up listeners to be called on result and/or fault.
         *
         * @param resultListener The function to be called when there is a result
         * @param faultListener The function to be called when there is a fault
         * @param callId If you want to set the listeners to one specific call object, provide it's id here. If set to -1 (default) the setting of listeners will be applied to all calls.
         */
        public function setListeners(resultListener:Function = null, faultListener:Function = null, callId:int = -1):void 
        {
            removeListeners(callId); // remove the listeners passing in the callId

            if (callId < 0)
            {
                _resultListener = resultListener;
                _faultListener  = faultListener;
                
                for (var i:Iterator = _calls.getIterator(); i.hasNext(); i.next())
                {
                    (i.data as Call).addListeners(_resultListener, _faultListener);
                }
            }
            else
            {
                var call:Call = _calls.find(callId) as Call;
                if (call != null)
                {
                    call.addListeners(resultListener, faultListener);
                }
            }
        }

        /**
         * Removes the currently set listeners.
         *
         * @param callId If you want you want the removal of listeners to be performed on only one call object, provide it's id here. If the value is -1 (default) the removal will be performed on all calls.
         */
        public function removeListeners(callId:int = -1):void 
        {
            if (callId < 0)
            {
                for (var i:Iterator = _calls.getIterator(); i.hasNext(); i.next())
                {
                    (i.data as Call).removeListeners(_resultListener, _faultListener);
                }
            }
            else
            {
                var call:Call = _calls.find(callId) as Call;
                if (call != null)
                {
                    call.removeListeners(_resultListener, _faultListener);
                }
            }
        }
        
        //------ GETTERS/SETTERS ------//
        /**
         * The string that points to the AMFPHP gateway.php file.
         * When you set the gateway it will reconnect to the new 
         * gateway file. If you set the gateway to nothing, the
         * connection will close.
         */
        public function get gateway():String
        {
            return _gateway;
        }
        
        public function set gateway(value:String):void
        {
            _gateway = value;
            
            if (gateway != "")
            {
                close();
                connect(_gateway);
            }
            else
            {
                close();
            }
        }
    }
}
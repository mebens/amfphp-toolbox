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
    import flash.events.EventDispatcher;
    import flash.net.Responder;
    
    /**
     * This object represents a unique call to AMFPHP.
     * It holds it's service string and an array of
     * parameters to send to AMFPHP. This object also
     * has a responder of it's own, and holds it's own
     * results and faults. This allows for no overlapping
     * confusion with multiple calls.
     * 
     * @author  NovaFusion
     * @since   2.0 beta
     * @see     CallEvent
     */
    public class Call extends EventDispatcher
    {
        /**
         * The responder object for this call.
         */
        public var responder:Responder;
        
        /**
         * The id of this call, assigned by the connection object and is it's position in the call array of the connection object.
         */
        public var callId:uint;
        
        /**
         * The last result from this call.
         */
        public var result:Object;
        
        /**
         * The last fault from this call.
         */
        public var fault:Object;
        
        /**
         * The string representing the service that this call is calling
         */
        public var service:String;
        
        /**
         * An array of the parameters to be passed to the service.
         */
        public var params:Array;
        
        /**
         * Whether or not to automatically trace out call results as Strings
         */
        public var autoTraceResults:Boolean;
        
        /**
         * Whether or not to automatically trace out the descriptions of call faults
         */
        public var autoTraceFaults:Boolean;
        
        /**
         * Sets up the properties of the object, with parameters given.
         * @param service   The string representing the service this object will be calling
         * @param params    A comma seperated list of the paramaters to be passed to the service
         */
        public function Call(service:String, ...params)
        {
            responder = new Responder(this.onResult, this.onFault);
            this.service = service;
            this.params = params;
        }
        
        /**
         * Adds parameters to the list of parameters to be
         * sent to the AMFPHP service.
         * 
         * @param   params  A comma-separated list of parameter values to be added.
         * @return  This call object.
         */
        public function addParams(...params):Call
        {
            params.push.apply(this, params); // using the method of a function object because the push method needs a comma seperated parameter list rather than an array
            return this;
        }
        
        /**
         * Adds listeners for the result and fault events
         * when this call is called. You can add multiple
         * listeners if you want. If you leave one of the 
         * parameters as null, it won't be added.
         * 
         * @param   resultListener  A function that you want to be called when a result is received.
         * @param   faultListener   A funciton that you want to be called when a fault is received.
         * @return  This call object.
         */
        public function addListeners(resultListener:Function = null, faultListener:Function = null):Call
        {
            if (resultListener != null)
            {
                addEventListener(CallEvent.RESULT, resultListener);
            }
            
            if (faultListener != null)
            {
                addEventListener(CallEvent.FAULT, faultListener);
            }
            
            return this;
        }
        
        /**
         * Does the opposite of addListeners(). If one of
         * the parameters is null, the removal of the
         * listener won't go ahead.
         * 
         * @param   resultListener  A function that you added before as a listener for results and now want to remove.
         * @param   faultListener   A function that you added before as a listener for faults and now want to remove.
         * @return  This call object.
         */
        public function removeListeners(resultListener:Function = null, faultListener:Function = null):Call
        {   
            if (resultListener != null)
            {
                removeEventListener(CallEvent.RESULT, resultListener);
            }
            
            if (faultListener != null)
            {
                removeEventListener(CallEvent.FAULT, faultListener);
            }
            
            return this;
        }
        
        //------ RESULT/FAULT HANDLERS ------//
        /**
         * The function called when a result is returned.
         * It will dispatch the result event and remove listeners
         * if one call listeners is set. If a custom result handler
         * function is not set, it will automatically trace out the
         * result as a string.
         */
        private function onResult(result:Object):void
        {
            this.result = result;
            dispatchEvent(new CallEvent(CallEvent.RESULT, callId, result));
            
            if (autoTraceResults === true)
            {
                trace(String("--- Call " + callId + " AUTO RESULT TRACE ---\n" +
                             result + "\n" +
                             "--------------------------------"));
            }
        }
        
        /**
         * The function called when a fault is returned.
         * It will dispatch the fault event and remove listeners
         * if one call listeners is set. If a custom result handler
         * function is not set, it will automatically trace out the
         * fault's description.
         */
        private function onFault(fault:Object):void
        {
            this.fault = fault;
            dispatchEvent(new CallEvent(CallEvent.FAULT, callId, fault));
            
            if (autoTraceFaults === true)
            {
                trace(String("--- Call " + callId + " AUTO FAULT TRACE ---\n" +
                             fault.description + "\n" +
                             "-------------------------------"));
            }
        }
    }
}

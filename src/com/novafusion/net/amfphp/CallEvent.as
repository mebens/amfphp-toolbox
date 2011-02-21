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
    import flash.events.Event;
    
    /**
     * A custom event class for calls (results or faults).
     * This is needed so that extra information about the
     * call that triggered it is available. Like the callId
     * and the result object. This class also stores the
     * constants for the triggering of the custom events.
     * 
     * @author  NovaFusion
     * @since   2.0 beta
     * @see     Call
     */
    public class CallEvent extends Event
    {
        /**
         * The event to reference for results
         */
        static public const RESULT:String = "amfphpResult";
        
        /**
         * The event to reference for faults
         */
        static public const FAULT:String = "amfphpFault";
        
        /**
         * The type of call event. Either "result" or "fault".
         */
        public var resultType:String;
        
        /**
         * The id of the call object that triggered this event.
         */
        public var callId:uint;
        
        /**
         * The full result object (only if the type is result) from the call.
         */
        public var result:Object;
        
        /**
         * The full fault object (only if the type is fault) from the call.
         */
        public var fault:Object;
        
        /**
         * The fault description (only if the type is fault) from the call.
         */
        public var description:String;
        
        /**
         * Sets up the event and it's data.
         *
         * @param type The type of call event. Either "result" or "fault".
         * @param callId The id of the call that triggered this event.
         * @param result The full result (or fault) object that came from this call event
         */
        public function CallEvent(type:String, callId:uint, result:Object)
        {
            super(type);
            
            if (type == CallEvent.RESULT)
            {
                this.result = result;
            }
            else if (type == CallEvent.FAULT)
            {
                fault = result;
                description = fault.description;
            }
            
            resultType = type;
            this.callId = callId;
        }
    }
}
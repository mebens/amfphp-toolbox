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
    import flash.events.EventDispatcher;
    import flash.events.TimerEvent;
    import flash.utils.Timer;
    
    /**
     * A class to help with making a multiple calls at once.
     * You can add calls to the class, and call them all at
     * once, or setup a timer to call them all on a recurring
     * basis.
     * 
     * @author  NovaFusion
     * @since   2.0 beta
     * @see     Call
     */
    public class CallSet extends EventDispatcher
    {
        private var _connection:AmfphpGateway;      // the connection object being used
        private var _calls:HashMap = new HashMap(); // hash map of call objects
        private var _timer:Timer;                   // variable for the Timer object that may be used
        private var _timerListener:Function;        // the custom function to call each time the timer calls the specified services
        private var _waitDuration:uint;             // the amount of time in milliseconds that the call set should wait before making the next call (only when using the timer)
        private var _timerCalls:uint;               // the number of calls made so far by the timer
        
        /**
         * The id of this call set inside of the connection object. This property is set automatically by the connection object when created.
         */
        public var setId:uint;
        
        /**
         * The constructer of the set, which sets up the needed properties 
         * for the object to operate. You can specify the call objects 
         * right here after the connection object; they need to be of type Call.
         *
         * @param connection This is the AmfphpGateway object you are using
         * @param calls This is where you will your comma seperated call objects
         * @see Call
         */
        public function CallSet(connection:AmfphpGateway, ...calls)
        {
            _connection = connection;
            _connection.addCallSet(this);
            addCalls.apply(this, calls);
        }
        
        /**
         * The function that calls all the services specified.
         * 
         * @param   event   The event object given when the timer calls this function.
         * @return  This CallSet object.
         */
        public function call(event:TimerEvent = null):CallSet
        {
            // meaning this was called by the timer
            if (event != null)
            {
                _timerCalls++;
                dispatchEvent(event);
            }
            
            var i:Iterator = _calls.getIterator();
            while (i.hasNext())
            {
                _connection.talk(i.next()); // Iterator.next() returns the current object, and then advances to the next
            }
            
            return this;
        }
        
        /**
         * This function adds call objects to the calls array. It works the same way as specifying calls in the constructer.
         * 
         * @param   calls   The restParam where you provide the call objects to be added to this set.
         * @return  This CallSet object.
         */
        public function addCalls(...calls):CallSet
        {
            // add in the call objects to the array
            for each (var call:Call in calls)
            {
                var callObj:Call = _connection.addCall(call);
                _calls.insert(callObj.callId, callObj);
            }
            
            return this;
        }
        
        /**
         * Sets up the necessary things for the timer functionality 
         * to operate. If the timer has already been setup before,
         * it will be "set-down".
         *
         * @param   waitDuration    The length of time (in milliseconds) between when the timer calls all the specified services. The default is 1000 (a second).
         * @param   startNow        Whether or not to start the timer right after setup. Default is false
         * @return  This CallSet object.
         */
        public function setupTimer(waitDuration:uint = 1000, startNow:Boolean = false):CallSet
        {
            if (_timer != null)
            {
                _timer = null;
            }
            
            _waitDuration = waitDuration;
            _timer = new Timer(_waitDuration);
            _timer.addEventListener(TimerEvent.TIMER, call);
            
            if (startNow)
            {
                _timer.start();
            }
            
            return this;
        }
        
        /**
         * This function starts the timer.
         * @return This CallSet object.
         */
        public function startTimer():CallSet
        {
            _timer.start();
            return this;
        }
        
        /**
         * This function stops the timer.
         * @return This CallSet object.
         */
        public function stopTimer():CallSet
        {
            _timer.stop();
            return this;
        }
        
        /**
         * Sets up a listener to call the function specified whenever the timer calls the services.
         * 
         * @param   listener    The function to be added to the listener.
         * @return  This CallSet object.
         */
        public function setTimerListener(listener:Function):CallSet
        {
            _timerListener = listener;
            addEventListener(TimerEvent.TIMER, _timerListener);
            return this;
        }
        
        /**
         * Removes the listener function specified for the timer call event.
         * @return This CallSet object.
         */
        public function removeTimerListener():CallSet
        {
            if (_timerListener != null)
            {
                _timerListener = null;
                removeEventListener(TimerEvent.TIMER, _timerListener);
            }
            
            return this;
        }
    }
}
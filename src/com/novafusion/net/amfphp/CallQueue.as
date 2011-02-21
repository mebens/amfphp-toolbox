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
    import de.polygonal.ds.HashMap;
    import de.polygonal.ds.LinkedQueue;
    
    /**
     * A class that acts a queue for calls. The queues
     * form in a line, and each time a call receives a
     * result or fault, the queue moves up one. You can
     * change the number of calls that can be in the
     * "hanging" state (meaning they are waiting for a
     * result or fault) at one time by changing the
     * concurrentCalls property.
     * 
     * @author  NovaFusion
     * @since   2.0
     * @see     CallSet
     */
    public class CallQueue
    {
        private var _nc:AmfphpGateway;                        // the connection object
        private var _waiting:LinkedQueue = new LinkedQueue(); // the queue of calls waiting
        private var _hanging:HashMap = new HashMap();         // the calls that have been called and are waiting for results
        private var _done:HashMap = new HashMap();            // the calls that have been called and have received their results
        private var _paused:Boolean = true;                   // to keep track of whether or not the queue is paused
        private var _started:Boolean = false;                 // to keep track of whether this queue has been started once before.
        
        /**
         * Whether or not to keep the calls that
         * have already passed through the queue.
         * @default true
         */
        public var keepDoneCalls:Boolean;
        
        /**
         * The number of calls that can be called on each
         * check. In other words, how many calls can fit
         * through the tube at once?
         * @default 1
         */
        public var concurrentCalls:uint = 1;
        
        /**
         * Thd id of this CallQueue. This is assigned when
         * the queue is added to the connection object.
         */
        public var queueId:uint;
        
        /**
         * Sets up properties and adds this queue to the
         * connection object. From the constructor you can
         * also add call objects. Just specify the call
         * objects after the connection object.
         * 
         * @param   nc      The connection object you want this call queue to use.
         * @param   calls   An optional comma-separated list of call objects you want added to this queue.
         */
        public function CallQueue(nc:AmfphpGateway, ...calls)
        {
            _nc = nc;
            _nc.addCallQueue(this); // add this queue to the connection object
            addCalls.apply(this, calls); // add the calls
        }
        
        /**
         * The main method of the object. This method will
         * check to see if it can move anymore call objects
         * out of the waiting line and call them. Generally
         * you won't have to deal with this method, as it is
         * called by whenever a call receives a result/fault
         * (meaning the queue has moved up one). But if you
         * want to force a re-check, then you can call it.
         * 
         * @return This CallQueue object.
         */
        public function call():CallQueue
        {
            var callsToMake:uint = concurrentCalls - _hanging.size; // the number of calls to make is the number of concurrent calls allows, minus how many are still waiting for their result
            for (var i:uint = 0; i < callsToMake; i++) // this won't run if there are no calls to make
            { 
                if (_waiting.size < 1)
                {
                    break;
                }
                
                var call:Call = _waiting.dequeue(); // dequeue the call
                _nc.talk(call); // call the call
                _hanging.insert(call.callId, call); // and insert the call into the hanging hash map
            }
            
            return this;
        }
        
        /**
         * This method forces the queue to call all waiting
         * calls. This method also pauses the queue in the
         * process.
         * 
         * @return This CallQueue object.
         */
        public function callAll():CallQueue
        {
            _paused = true;
            
            for (var i:uint = 0; i < _waiting.size; i++)
            {
                var call:Call = _waiting.dequeue();
                _nc.talk(call);
                _hanging.insert(call.callId, call);
            }
            
            return this;
        }
        
        /**
         * Allows you to add call objects to the queue.
         * 
         * @param   calls   A comma-separated list of the call objects you want to add to the queue.
         * @return  This CallQueue object.
         */
        public function addCalls(...calls):CallQueue
        {
            for each (var call:Call in calls)
            {
                call = _nc.addCall(call); // add the call to the connection object
                call.addListeners(callResult, callResult); // add the listeners
                _waiting.enqueue(call);   // and enqueue it in the waiting list
            }
            
            return this;
        }
        
        /**
         * Unpauses the queue.
         * @return This CallQueue object.
         */
        public function start():CallQueue
        {
            _paused = false;
            
            if (!_started)
            {
                _started = true;
                call();
            }
            
            return this;
        }
        
        /**
         * Pauses the queue.
         * @return This CallQueue object.
         */
        public function stop():CallQueue
        {
            _paused = true;
            return this;
        }
        
        private function callResult(event:CallEvent):void 
        {
            var c:Call = _hanging.remove(event.callId);
            
            if (keepDoneCalls)
            {
                _done.insert(c.callId, c);
            }
            
            if (!_paused)
            {
                call();
            }
        }
    }
}
package com.etherdream.webworker
{
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.system.MessageChannel;
	import flash.system.Worker;
	import flash.system.WorkerDomain;
	import flash.utils.ByteArray;
	
	
	public class WebWorker extends EventDispatcher {
		
		private var worker: Worker;
		private var mainToBack: MessageChannel;
		private var backToMain: MessageChannel;
		
		private var ready: Boolean = false;
		private var queue: Array = [];
		
		
		private function msgHandler(e: Event) : void {
			if (!backToMain.messageAvailable) {
				return;
			}
			
			var msg: * = backToMain.receive();
			if (ready) {
				dispatchEvent(new WebWorkerEvent('message', msg));
				return;
			}

			// flush queue
			if (msg === '__connected') {
				ready = true;
				for (var i: uint = 0; i < queue.length; i++) {
					postMessage(queue[i]);
				}
				queue = null;
			}
		}
		
		
		public var tag: *;
		
		public function WebWorker(blob: ByteArray) {
			super();
			worker = WorkerDomain.current.createWorker(blob);
			mainToBack = Worker.current.createMessageChannel(worker);

			backToMain = worker.createMessageChannel(Worker.current);
			backToMain.addEventListener(Event.CHANNEL_MESSAGE, msgHandler);
			worker.setSharedProperty('__main_to_back', mainToBack);
			worker.setSharedProperty('__back_to_main', backToMain);
			worker.start();
		}
		
		public function postMessage(msg: *) : void {
			if (ready) {
				mainToBack.send(msg);
			} else {
				queue.push(msg);
			}
		}
		
		public function terminate() : void {
			worker.terminate();
		}
		
		public function setSharedObject(key: String, val: *) : void {
			worker.setSharedProperty(key, val);
		}
		
		public function getSharedObject(key: String) : * {
			worker.getSharedProperty(key);
		}
		
		static public function isMainThread() : Boolean {
			return Worker.current.isPrimordial;
		}
	}
}
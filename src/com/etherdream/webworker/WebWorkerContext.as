package com.etherdream.webworker
{
	import flash.system.*;
	import flash.events.*;
	
	
	public class WebWorkerContext extends EventDispatcher {
		private var mainToBack: MessageChannel;
		private var backToMain: MessageChannel;
		private var worker: Worker;
		
		
		public function WebWorkerContext() {
			super();
			worker = Worker.current;
			mainToBack = worker.getSharedProperty('__main_to_back');
			backToMain = worker.getSharedProperty('__back_to_main');
			
			mainToBack.addEventListener(Event.CHANNEL_MESSAGE, msgHandler);
			postMessage('__connected');
		}
		
		public function postMessage(msg: *) : void {
			backToMain.send(msg);
		}
		
		public function setSharedObject(key: String, val: *) : void {
			worker.setSharedProperty(key, val);
		}
		
		public function getSharedObject(key: String) : * {
			return worker.getSharedProperty(key);
		}
		
		private function msgHandler(e: Event) : void {
			if (mainToBack.messageAvailable) {
				var msg: * = mainToBack.receive();
				dispatchEvent(new WebWorkerEvent('message', msg));
			}
		}
	}
}
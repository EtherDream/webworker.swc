package com.etherdream.webworker
{
	import flash.events.Event;

	public class WebWorkerEvent extends Event {
		public var data: *;
		
		public function WebWorkerEvent(type: String, data: *) {
			super(type);
			this.data = data;
		}
	}
}
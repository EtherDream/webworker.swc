
# webworker.swc

模仿 HTML5 风格的 Flash Worker，方便 JS 程序移植到 AS，用于低版本浏览器的密集计算。


## 使用

主程序通过 `WebWorker` 创建子程序。（传入子程序 SWF 文件的 ByteArray）

子程序通过继承 `WebWorkerContext` 可获得 `message` 事件、`postMessage` 方法等特性。

注意：SDK 版本需 11.5 或更高。


## 细节

* `postMessage` 方法没有 HTML5 中 [Transferable objects](https://developer.mozilla.org/en-US/docs/Web/API/Transferable) 的概念。`可共享变量`通过 `setSharedObject`、`getSharedObject` 方法传递。

* `WebWorker` 类增加了一个 `tag` 属性，方便关联一些信息。（Flash 的类是密闭的，无法添加额外属性，只能通过子类或者 Dictionary 关联信息，比较麻烦）

* `WebWorker` 创建后就可以 `postMessage`，程序会暂时将消息记录在队列里，子程序初始化完成后会收到。

* 增加了 `isMainThread` 静态方法，可判断当前是否为主程序，方便主程序和子程序共用一个 SWF 文件。


## 演示

```as3
// Startup.as
public class Startup extends Sprite {
	...
	public function Startup() {
		if (WebWorker.isMainThread()) {
			new Main(loaderInfo.bytes);
		} else {
			new Child();
		}
	}
}

// Main.as
public class Main {
	...
	public function Main(workerBytes: ByteArray) {
		var worker: WebWorker = new WebWorker(workerBytes);
		worker.addEventListener('message', msgHander);
		worker.postMessage('hello');
	}

	private function msgHander(e: WebWorkerEvent) : void {
		var msg: * = e.data;
		trace('msg from worker:', msg);
	}
}

// Child.as
public class Child extends WebWorkerContext {
	public function Child() {
		addEventListener('message', msgHander);
	}

	private function msgHander(e: WebWorkerEvent) : void {
		var msg: * = e.data;
		trace('msg from main:', msg);
		postMessage(msg + ' world');
	}
}
```

## 案例

https://github.com/EtherDream/WebScrypt/tree/master/src/mod_flash/src

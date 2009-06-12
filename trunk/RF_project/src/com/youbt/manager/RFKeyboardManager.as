package com.youbt.manager{
	
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import com.youbt.utils.*;
	import com.youbt.manager.keyboardClasses.IKeyType;
	import com.youbt.manager.keyboardClasses.KeyMap;
	import flash.display.Stage;
	import flash.events.FocusEvent;
	import flash.display.DisplayObject;
	import flash.events.MouseEvent;
	
	/**
	 * Dispatched when key is down.
	 * @eventType flash.events.KeyboardEvent.KEY_DOWN
	 */
	[Event(name="keyDown", type="flash.events.KeyboardEvent")]
	
	/**
	 * Dispatched when key is up.
	 * @eventType flash.events.KeyboardEvent.KEY_UP
	 */
	[Event(name="keyUp", type="flash.events.KeyboardEvent")]
	
	public class RFKeyboardManager extends EventDispatcher{
		
		protected static var defaultMnemonicModifier:Array = [Keyboard.CONTROL, Keyboard.SHIFT];
		
		protected var keySequence:ArrayList;
		protected var keymap:KeyMap;
		protected var inited:Boolean;
		protected var mnemonicModifier:Array;
		protected var keyJustActed:Boolean;
		protected var enabled:Boolean;
		
		private var stage:Stage;
		
		
		private var hasfocus:Boolean=false;
		
		/**
		 * Singleton class, 
		 * Don't create instance directly, in stead you should call <code>getInstance()</code>.
		 */
		public function RFKeyboardManager(){
			enabled = true;
			inited = false;
			keyJustActed = false;
			keySequence = new ArrayList();
			keymap = new KeyMap();
			mnemonicModifier = null;
		}
		
		/**
		 * Init the keyboad manager, it will only start works when it is inited.
		 * @param root the key trigger root of this keyboard manager.
		 * @throws Error if it is already inited.
		 */
		public function init(root:DisplayObjectContainer):void{
			if(!inited){
				
				inited = true;
				
				root.addEventListener(MouseEvent.MOUSE_OVER,mouseHandler,false,0,true);
				root.addEventListener(MouseEvent.MOUSE_OUT,mouseHandler,false,0,true);
				
				root.addEventListener(FocusEvent.FOCUS_IN,focusHandler,false,0,true);
				root.addEventListener(FocusEvent.FOCUS_OUT,focusHandler,false,0,true);
				
				root.addEventListener(Event.DEACTIVATE, __deactived, false, 0, true);
			}else{
				throw new Error("This KeyboardManager was already inited!");
			}
		}
		
		/**
		 *  
		 * @param event
		 * 
		 */		
		private function mouseHandler(event:Event):void{
			var root:DisplayObject=event.currentTarget as DisplayObject;
			if(root.stage==null)return;
			
			var stage:Stage=root.stage;
			if(event.type ==MouseEvent.MOUSE_OVER){
				stage.addEventListener(KeyboardEvent.KEY_DOWN, __onKeyDown, false, 0, true);
				stage.addEventListener(KeyboardEvent.KEY_UP, __onKeyUp, false, 0, true);
			}else{
				if(hasfocus)return;
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, __onKeyDown);
				stage.removeEventListener(KeyboardEvent.KEY_UP, __onKeyUp);
			}
		}
		
		private function focusHandler(event:FocusEvent):void{
			var root:DisplayObject=event.currentTarget as DisplayObject;
			if(root.stage==null)return;
			
			var stage:Stage=root.stage;
			if(event.type ==FocusEvent.FOCUS_IN){
				hasfocus=true;
				stage.addEventListener(KeyboardEvent.KEY_DOWN, __onKeyDown, false, 0, true);
				stage.addEventListener(KeyboardEvent.KEY_UP, __onKeyUp, false, 0, true);
			}else{
				hasfocus=false;
				stage.removeEventListener(KeyboardEvent.KEY_DOWN, __onKeyDown);
				stage.removeEventListener(KeyboardEvent.KEY_UP, __onKeyUp);
			}
		}
		
			
		/**
		 * Registers a key action to the default key map of this controller.
		 * @param key the key type
		 * @param action the action
		 * @see KeyMap#registerKeyAction()
		 */
		public function registerKeyAction(key:IKeyType, action:Function):void{
			keymap.registerKeyAction(key, action);
		}
		
		/**
		 * Unregisters a key action to the default key map of this controller.
		 * @param key the key type
		 * @see KeyMap#unregisterKeyAction()
		 */
		public function unregisterKeyAction(key:IKeyType):void{
			keymap.unregisterKeyAction(key);
		}
		
		public function getKeyMap():KeyMap{
			return keymap;
		}
		
		/**
		 * Returns whether or not the key is down.
		 * @param the key code
		 * @return true if the specified key is down, false if not.
		 */
		public function isKeyDown(keyCode:uint):Boolean{
			return keySequence.contains(keyCode);
		}
		
		/**
		 * Sets the mnemonic modifier key codes, the default is [Ctrl, Shift], however 
		 * for normal UI frameworks, it is [Alt], but because the flashplayer or explorer will 
		 * eat [Alt] for thier own mnemonic modifier, so we set our default to [Ctrl, Shift].
		 * <p>
		 * Sets null to make it allways keep same to <code>getDefaultMnemonicModifier</code>
		 * </p>
		 * @param keyCodes the array of key codes to be the mnemoic modifier.
		 */
		public function setMnemonicModifier(keyCodes:Array):void{
			if(keyCodes == null){
				keyCodes = null;
			}else{
				mnemonicModifier = keyCodes.concat();
			}
		}
		
		public static function getDefaultMnemonicModifier():Array{
			return defaultMnemonicModifier.concat();
		}
		
		public static function setDefaultMnemonicModifier(keyCodes:Array):void{
			defaultMnemonicModifier = keyCodes.concat();
		}
		
		public function setEnabled(b:Boolean):void{
			enabled = b;
			if(!b){
				keySequence.clear();
			}
		}
		
		public function isEnabled():Boolean{
			return enabled;
		}
		
		public function getMnemonicModifier():Array{
			if(mnemonicModifier == null){
				return getDefaultMnemonicModifier();
			}else{
				return mnemonicModifier.concat();
			}
		}
		
		/**
		 * Returns whether or not the mnemonic modifier keys is down.
		 * @return whether or not the mnemonic modifier keys is down.
		 */
		public function isMnemonicModifierDown():Boolean{
			var mm:Array = getMnemonicModifier();
			for(var i:int=0; i<mm.length; i++){
				if(!isKeyDown(mm[i])){
					return false;
				}
			}
			return mm.length > 0;
		}
		
		/**
		 * Returns whether or not just a key action acted when the last key down.
		 * @return true if there's key actions acted at last key down, false not.
		 */
		public function isKeyJustActed():Boolean{
			return keyJustActed;
		}
			
		private function __onKeyDown(e:KeyboardEvent) : void {
			
			//trace("key down:"+e.keyCode)
			
			if(!enabled){
				return;
			}
			dispatchEvent(e);
			var code:uint = e.keyCode;
			
			if(!keySequence.contains(code)){
				keySequence.append(code);
			}
			keyJustActed = false;
			if(keymap.fireKeyAction(keySequence.toArray())){
				keyJustActed = true;
			}
		}
	
		private function __onKeyUp(e:KeyboardEvent) : void {
			if(!enabled){
				return;
			}
			dispatchEvent(e);
			var code:uint = e.keyCode;
			keySequence.remove(code);
			//avoid IME bug that can't trigger keyup event when active IME and key up
			if(!e.ctrlKey){
				keySequence.remove(Keyboard.CONTROL);
			}
			if(!e.shiftKey){
				keySequence.remove(Keyboard.SHIFT);
			}
		}
		
		private function __deactived(e:Event):void{
			keySequence.clear();
		}
	}

}
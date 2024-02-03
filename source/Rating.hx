package;

class Rating {
	public var name:String = '';
	public var image:String = '';
	public var counter:String = '';
	public var hitWindow:Null<Int> = 0;
	public var ratingMod:Float = 1.005;
	public var score:Int = 500;
	public var noteSplash:Bool = true;
	public var hits:Int = 0;
	public var color:Int = 0xFF8800FF;

	public function new(name:String) {
		this.name = name;
		this.image = name;
		this.counter = name + 's';
		this.hitWindow = Reflect.field(ClientPrefs, name + 'Window');
		if(hitWindow == null) {
			hitWindow = 0;
		}
	}

	public function increase(p2:String = "", blah:Int = 1) {
		Reflect.setField(PlayState.instance, counter + p2, Reflect.field(PlayState.instance, counter + p2) + blah);
	}
}
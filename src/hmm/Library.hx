package hmm;

/**
 * a Haxe Library basic elements
 */
typedef Library =
{
	var type:String;
	var name:String;
	var skipDependencies:Bool;
}

typedef HaxeLibrary = Library &
{
	var version:String;
}

typedef DevLibrary = Library &
{
	var path:String;
}

typedef GitLibrary = Library &
{
	var url:String;
	var ref:String;
	var dir:String;
}

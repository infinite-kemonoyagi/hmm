package hmm;

using StringTools;

import haxe.ds.Option;
import thx.Either;

using thx.Functions;

import thx.Functions.*;
import thx.Nel;

using thx.Options;

import thx.Validation;
import thx.Validation.*;
import hmm.utils.Dynamics.*;

/**
  Metadata that describes a Haxe library installation source
**/
enum LibraryConfig {
  Haxelib(name:String, version:Option<String>, skipDependencies:Option<Bool>);
  Git(name:String, url:String, skipDependencies:Option<Bool>, ref:Option<String>, dir:Option<String>);
  Mercurial(name:String, url:String, skipDependencies:Option<Bool>, ref:Option<String>, dir:Option<String>);
  Dev(name:String, path:String, skipDependencies:Option<Bool>);
}

class LibraryConfigs {
  static inline var HAXELIB_TYPE = "haxelib";
  static inline var GIT_TYPE = "git";
  static inline var MERCURIAL_TYPE = "hg";
  static inline var DEV_TYPE = "dev";

  public static function getName(lib:LibraryConfig):String {
    return switch lib {
      case Haxelib(name, _): name;
      case Git(name, _, _, _): name;
      case Mercurial(name, _, _, _): name;
      case Dev(name, _): name;
    };
  }

  public static function isSameName(a:LibraryConfig, b:LibraryConfig):Bool {
    return getName(a) == getName(b);
  }

  public static function compareByName(a:LibraryConfig, b:LibraryConfig):Int {
    return thx.Strings.compare(getName(a), getName(b));
  }

  public static function deserialize(v:Dynamic):VNel<String, LibraryConfig> {
    return hmm.utils.Dynamics.parseProperty(v, "type", parseString, identity).flatMapV(function(type:String):VNel<String, LibraryConfig> {
      return switch type.toLowerCase() {
        case HAXELIB_TYPE: deserializeHaxelib(v);
        case GIT_TYPE: deserializeGit(v);
        case MERCURIAL_TYPE | "mercurial": deserializeMercurial(v);
        case DEV_TYPE: deserializeDev(v);
        case unk: failureNel('unrecognized library type: $unk');
      };
    });
  }

  public static function serialize(v:LibraryConfig):Dynamic {
    return switch v {
      case Haxelib(name, version, skipDependencies): {
          type: HAXELIB_TYPE,
          name: name,
          skipDependencies: skipDependencies.get(),
          version: version.get()
        };
      case Git(name, url, skipDependencies, ref, dir): {
          type: GIT_TYPE,
          name: name,
          url: url,
          skipDependencies: skipDependencies.get(),
          ref: ref.get(),
          dir: dir.get()
        };
      case Mercurial(name, url, skipDependencies, ref, dir): {
          type: MERCURIAL_TYPE,
          name: name,
          url: url,
          skipDependencies: skipDependencies.get(),
          ref: ref.get(),
          dir: dir.get()
        };
      case Dev(name, path, skipDependencies): {
          type: DEV_TYPE,
          name: name,
          path: path,
          skipDependencies: skipDependencies.get()
        };
    };
  }

  static function deserializeHaxelib(v:Dynamic):VNel<String, LibraryConfig> {
    return val3(Haxelib, parseProperty(v, "name", parseString, identity), parseOptionalStringProperty(v, "version"), parseOptionalBoolProperty(v, "skipDependencies"), Nel.semigroup());
  }

  static function deserializeGit(v:Dynamic):VNel<String, LibraryConfig> {
    return val5(Git, parseProperty(v, "name", parseString, identity), parseProperty(v, "url", parseString, identity), parseOptionalBoolProperty(v, "skipDependencies"), parseOptionalStringProperty(v, "ref"),
      parseOptionalStringProperty(v, "dir"), Nel.semigroup());
  }

  static function deserializeMercurial(v:Dynamic):VNel<String, LibraryConfig> {
    return val5(Mercurial, parseProperty(v, "name", parseString, identity), parseProperty(v, "url", parseString, identity),
    parseOptionalBoolProperty(v, "skipDependencies"), parseOptionalProperty(v, "ref", parseString), parseOptionalProperty(v, "dir", parseString), Nel.semigroup());
  }

  static function deserializeDev(v:Dynamic):VNel<String, LibraryConfig> {
    return val3(Dev, parseProperty(v, "name", parseString, identity), parseProperty(v, "path", parseString, identity), parseOptionalBoolProperty(v, "skipDependencies"), Nel.semigroup());
  }

  static function parseOptionalStringProperty(v:{}, name:String):VNel<String, Option<String>> {
    return parseOptionalProperty(v, name, parseString).map(function(str:Option<String>):Option<String> {
      return str.filter(a -> a.trim() != "");
    });
  }

  static function parseOptionalBoolProperty(v:{}, name:String):VNel<String, Option<Bool>> {
    return parseOptionalProperty(v, name, parseBool).map(function(boolean:Option<Bool>):Option<Bool> {
      return boolean;
    });
  }
}

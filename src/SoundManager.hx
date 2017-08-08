package;
import Thx.Set;
import openfl.Assets;
import openfl.events.Event;
import openfl.media.Sound;
import openfl.media.SoundChannel;
import openfl.media.SoundTransform;
import openfl.net.URLRequest;

/**
 * A simple Flash/OpenFL music manager with optional crossfading
 * @author Andreas Rønning
 */

class SoundManager
{
	static var pool = new Map<String,Sound>();
	static var path_soundChannels = new Map<String, Array<SoundChannel>>();
	static var soundChannel_path = new Map<SoundChannel, String>();
	static var streams = new Map<Int, MusicStream>();
	
	static inline function clamp(value:Float, min:Float = 0.0, max:Float = 1.0):Float {
		return Math.max(min, Math.min(value, max));
	}
	
	public static function update(delta:Float) {
		for (s in streams) {
			s.time += delta;
			var t = clamp(s.time / s.fadeDuration, 0.0, 1.0);
			s.setVolume(s.startVolume+(s.targetVolume-s.startVolume) * t);
			if (s.stopping && s.getVolume() < 0.01) {
				s.stop();
				streams.remove(s.id);
			}
		}
	}
	
	public static function playMusic(path:String, fadeTime:Float = 0.0):Int {
		if (!pool.exists(path)) {
			pool[path] = Assets.getSound(path);
		}
		var str = new MusicStream(pool[path], 0, 1, fadeTime);
		streams[str.id] = str;
		return str.id;
	}
	
	public static function stopMusic(id:Int, fadeTime:Float = 0.0) {
		if (id == -1) {
			for (i in streams.keys()) {
				stopMusic(i, fadeTime);
			}
			return;
		}
		if (streams[id] != null) { 
			var s = streams[id];
			s.time = 0;
			s.fadeDuration = fadeTime;
			s.startVolume = s.getVolume();
			s.targetVolume = 0;
			s.stopping = true;
		}
	}
	
	public static function playSound(path:String, vol:Float = 1.0, pan:Float = 0.0, stopSounds:Bool = false):SoundChannel {
		if (!pool.exists(path)) {
			pool[path] = Assets.getSound(path);
		}
		
		if (stopSounds) {
			stopAllSounds(path);
		}
		
		var sc = pool[path].play();
		if (sc != null) {
			//can sometimes be null... dunno why.
			sc.addEventListener(Event.SOUND_COMPLETE, onSoundComplete);
			if (!path_soundChannels.exists(path)) path_soundChannels.set(path, []);
			path_soundChannels.get(path).push(sc);
			soundChannel_path.set(sc, path);
			sc.soundTransform = new SoundTransform(vol, pan);
		}
		return sc;
	}
	
	static private function onSoundComplete(e:Event):Void {
		dispose(cast(e.target, SoundChannel));
	}
	
	public static function stopAllSounds(path:String = null):Void{
		if (path == null) {
			for (sc in soundChannel_path.keys()) {
				sc.stop();
				dispose(sc);
			}
		} else {
			if (!path_soundChannels.exists(path)) return;
			for (sc in path_soundChannels.get(path).copy()) {
				sc.stop();
				dispose(sc);
			}
		}
	}
	
	static private function dispose(sc:SoundChannel) 
	{
		sc.removeEventListener(Event.SOUND_COMPLETE, onSoundComplete);
		var path = soundChannel_path.get(sc);
		path_soundChannels.get(path).remove(sc);
		soundChannel_path.remove(sc);
	}
}

private class MusicStream
{
	static var idPool = 0;
	public var startVolume:Float;
	public var fadeDuration:Float;
	public var targetVolume:Float;
	public var soundChannel:SoundChannel;
	public var time:Float;
	public var id:Int;
	public var stopping:Bool;
	public var playing:Bool;
	public function new(snd:Sound, startVolume:Float = 1.0, targetVolume:Float = 1.0, fadeDuration:Float = 0.0) {
		id = idPool++;
		this.startVolume = startVolume;
		this.fadeDuration = fadeDuration;
		this.targetVolume = targetVolume;
		time = 0.0;
		soundChannel = snd.play(0, -1, new SoundTransform(startVolume));
		playing = true;
		stopping = false;
	}
	
	public inline function setVolume(v:Float) {
		var t = soundChannel.soundTransform;
		t.volume = v;
		soundChannel.soundTransform = t;
	}
	public inline function getVolume():Float {
		return soundChannel.soundTransform.volume;
	}
	public inline function stop() {
		playing = false;
		soundChannel.stop();
	}
}
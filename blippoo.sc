// thanks to: http://sccode.org/1-5bB
Engine_Blippoo : CroneEngine {
  var <synth;

  *new { arg context, doneCallback;
    ^super.new(context, doneCallback);
  }

  alloc {
    ~rungler = { arg clock, sig;
    	var buffer = LocalBuf(8);
    	var pos = Stepper.ar(clock,0,0,7,1);
    	var w = BufWr.ar(sig,buffer,pos);
    	var r1 = BufRd.ar(1,buffer,(pos + 5)%8,0,0)>0;
    	var r2 = BufRd.ar(1,buffer,(pos + 6)%8,0,0)>0;
    	var r3 = BufRd.ar(1,buffer,(pos + 7)%8,0,0)>0;
    	(((r1<<0) + (r2<<1) + (r3<<2))/7).lag(1/10000);
    };
    
    ~twinpeaks = { arg in, f1, f2, r1, r2;
    	var l1 = RLPF.ar(in     ,f1.fold(20,20000).lag(0.005),r1);
    	var l2 = RLPF.ar(in * -1,f2.fold(20,20000).lag(0.005),r2);
    	l1 + l2;
    };
    
    synth = { |
              out,
            	freqOscA = 10.46,      // frequency oscilator a
            	freqOscB = 0.32,       // frequency oscilator b
            	fm_b_a = 10.02,        // fm oscilator b -> oscilator a
            	fm_a_b = 2.81,         // fm oscilator a -> oscilator b
            	fm_r_a = 160.2,        // fm rungler2 -> oscilator a
            	fm_r_b = 16.27,        // fm runglefreqOscA -> oscilator b
            	fm_sah_a = 6.14,       // fm SampleAndHold -> oscilator a
            	fm_sah_b = 6.14,       // fm SampleAndHold -> oscilator a
            	freqPeak1 = 231.4,     //freqency filter 1
            	freqPeak2 = 895,       // frequency filter 2
            	fm_r_peak1 = 1000,     // fm rungler1 -> filter 1
            	fm_r_peak2 = 3000,     // fm rungler2 -> filter 2
            	fm_sah_peak = 272.1,   // fm rungler2 -> filter 2
            	resonance = 0.06,      // filter resonance
            	amp = 1.0
            	|
      var fb = LocalIn.ar(5);
      var rfreqOscA = freqOscA + LFNoise2.ar(freqOscA.max(10)/10,freqOscA.max(10)/1000);
      var rfreqOscB = freqOscB + LFNoise2.ar(freqOscB.max(10)/10,freqOscB.max(10)/1000);
      var tri1 = LFTri.ar((rfreqOscA + (fb[1] * fm_b_a) + (fb[2] * fm_r_a) + (fb[4] * fm_sah_a)).fold(0,20000));
      var tri2 = LFTri.ar((rfreqOscB + (fb[0] * fm_a_b) + (fb[3] * fm_r_b) + (fb[4] * fm_sah_b)).fold(0,20000));
      var puls1 = tri1>Delay1.ar(tri1);
      var puls2 = tri2>Delay1.ar(tri2);
      var sah = Latch.ar(tri1,puls2).lag(1/10000);
      var rungler1 = ~rungler.(puls1,puls2);
      var rungler2 = ~rungler.(puls2,puls1);
      var rung = rungler1 + rungler2;
      var comparator = ((tri1<tri2)-0.5).lag3ud(1/10000,1/5000);
      var pf1 = (freqPeak1 + (sah * fm_sah_peak * -1) + (rung * fm_r_peak1)).abs;
      var pf2 = (freqPeak2 + (sah * fm_sah_peak) + (rung * fm_r_peak2)).abs;
      var sig = ~twinpeaks.(comparator,pf1,pf2,resonance,resonance);
      var fbout = LocalOut.ar([tri1,tri2,rungler1,rungler2,sah]);
      Out.ar(out, Limiter.ar(sig / 10 * amp).dup);
    }.play(args: [\out, context.out_b], target: context.xg);
    
    this.addCommand("freqOscA", "f", { arg msg;
      synth.set(\freqOscA, msg[1]);
    });
    
    this.addCommand("freqOscB", "f", { arg msg;
      synth.set(\freqOscB, msg[1]);
    });
    
    this.addCommand("fm_b_a", "f", { arg msg;
      synth.set(\fm_b_a, msg[1]);
    });
    
    this.addCommand("fm_a_b", "f", { arg msg;
      synth.set(\fm_a_b, msg[1]);
    });
    
    this.addCommand("fm_r_a", "f", { arg msg;
      synth.set(\fm_r_a, msg[1]);
    });
    
    this.addCommand("fm_r_b", "f", { arg msg;
      synth.set(\fm_r_b, msg[1]);
    });
    
    this.addCommand("fm_sah_a", "f", { arg msg;
      synth.set(\fm_sah_a, msg[1]);
    });
    
    this.addCommand("fm_sah_b", "f", { arg msg;
      synth.set(\fm_sah_b, msg[1]);
    });
    
    this.addCommand("freqPeak1", "f", { arg msg;
      synth.set(\freqPeak1, msg[1]);
    });
    
    this.addCommand("freqPeak2", "f", { arg msg;
      synth.set(\freqPeak2, msg[1]);
    });
    
    this.addCommand("fm_r_peak1", "f", { arg msg;
      synth.set(\fm_r_peak1, msg[1]);
    });
    
    this.addCommand("fm_r_peak2", "f", { arg msg;
      synth.set(\fm_r_peak2, msg[1]);
    });
    
    this.addCommand("fm_sah_peak", "f", { arg msg;
      synth.set(\fm_sah_peak, msg[1]);
    });
    
    this.addCommand("resonance", "f", { arg msg;
      synth.set(\resonance, msg[1]);
    });
    
    this.addCommand("amp", "f", { arg msg;
      synth.set(\amp, msg[1]);
    });
  }

  free {
    synth.free;
  }
}
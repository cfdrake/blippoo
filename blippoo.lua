-- ~~ blippoo ~~
-- blippoo box clone
--
-- by: @cfd90
-- original sccode by: @olaf
--
-- ENC1 volume

engine.name = "Blippoo"

function init()
  setup_params()
  setup_defaults()
  disable_reverb()
end

function setup_params()
  -- Setup oscillators
  params:add_separator("Source Oscillators")
  
  params:add_control("freq_osc_a", "Freq. Osc. A", controlspec.new(0, 20000, 'lin', 0.1, 100, 'hz', 0.00005))
  params:set_action("freq_osc_a", function(x) engine.freqOscA(x) end)
  
  params:add_control("freq_osc_b", "Freq. Osc. B", controlspec.new(0, 20000, 'lin', 0.1, 100, 'hz', 0.00005))
  params:set_action("freq_osc_b", function(x) engine.freqOscB(x) end)
  
  -- Setup oscillator modulations
  params:add_separator("Oscillator FM")
  
  params:add_control("fm_a_b", "FM A => B", controlspec.new(0, 5000, 'lin', 0.1, 100, '', 0.0001))
  params:set_action("fm_a_b", function(x) engine.fm_a_b(x) end)
  
  params:add_control("fm_b_a", "FM B => A", controlspec.new(0, 5000, 'lin', 0.1, 100, '', 0.0001))
  params:set_action("fm_b_a", function(x) engine.fm_b_a(x) end)
  
  params:add_control("fm_r_a", "FM Rungler => A", controlspec.new(0, 5000, 'lin', 0.1, 100, '', 0.0001))
  params:set_action("fm_r_a", function(x) engine.fm_r_a(x) end)
  
  params:add_control("fm_r_b", "FM Rungler => B", controlspec.new(0, 5000, 'lin', 0.1, 100, '', 0.0001))
  params:set_action("fm_r_b", function(x) engine.fm_r_b(x) end)
  
  params:add_control("fm_sah_a", "FM S&H => A", controlspec.new(0, 5000, 'lin', 0.1, 100, '', 0.0001))
  params:set_action("fm_sah_a", function(x) engine.fm_sah_a(x) end)
  
  params:add_control("fm_sah_b", "FM S&H => B", controlspec.new(0, 5000, 'lin', 0.1, 100, '', 0.0001))
  params:set_action("fm_sah_b", function(x) engine.fm_sah_b(x) end)
  
  -- Setup filter
  params:add_separator("Twin Peak Resonator")
  
  params:add_control("freqPeak1", "Freq. Peak A", controlspec.new(0, 8000, 'lin', 0.1, 100, '', 0.000125))
  params:set_action("freqPeak1", function(x) engine.freqPeak1(x) end)
  
  params:add_control("freqPeak2", "Freq. Peak B", controlspec.new(0, 8000, 'lin', 0.1, 100, '', 0.000125))
  params:set_action("freqPeak2", function(x) engine.freqPeak2(x) end)
  
  params:add_control("resonance", "Peak Resonance", controlspec.new(0.01, 2, 'lin', 0.1, 0.1, ''))
  params:set_action("resonance", function(x) engine.resonance(x) end)
  
  -- Setup filter modulations
  params:add_separator("Twin Peak FM")
  
  params:add_control("fm_r_peak1", "FM Rungler => Peak A", controlspec.new(0, 5000, 'lin', 0.1, 100, '', 0.0001))
  params:set_action("fm_r_peak1", function(x) engine.fm_r_peak1(x) end)
  
  params:add_control("fm_r_peak2", "FM Rungler => Peak B", controlspec.new(0, 5000, 'lin', 0.1, 100, '', 0.0001))
  params:set_action("fm_r_peak2", function(x) engine.fm_r_peak2(x) end)
  
  params:add_control("fm_sah_peak", "FM S&H => Peaks", controlspec.new(0, 5000, 'lin', 0.1, 100, '', 0.0001))
  params:set_action("fm_sah_peak", function(x) engine.fm_sah_peak(x) end)
  
  -- Setup misc
  params:add_separator("Misc.")
  
  params:add_control("amp", "Volume", controlspec.new(0, 1, 'lin', 0.01, 1, '', 0.01))
  params:set_action("amp", function(x) engine.amp(x) end)
end

function setup_defaults()
  params:set("freq_osc_b", 22.699345303073)
  params:set("freq_osc_a", 3.9693859855577)
  params:set("fm_a_b", 0.0)
  params:set("fm_b_a", 0.0)
  params:set("fm_r_a", 6.4822052062949)
  params:set("fm_r_b", 55.467640210437)
  params:set("fm_sah_a", 4.1668212367655)
  params:set("fm_sah_b", 32.584637770027)
  params:set("freqPeak1", 115.59385768307)
  params:set("freqPeak2", 802.05582789904)
  params:set("resonance", 0.053593355607996)
  params:set("fm_r_peak1", 1022.2025597648)
  params:set("fm_r_peak2", 669.35696176669)
  params:set("fm_sah_peak", 187.8431927844)
  params:set("amp", 1)
end

function disable_reverb()
  audio:rev_off()
end

function redraw()
  screen.clear()
  screen.move(0, 10)
  screen.level(15)
  screen.text("^ set values in params menu")
  screen.update()
end

function enc(n, d)
  if n == 1 then
    params:delta("amp", d)
  end
end
-- ~~ blippoo ~~
-- blippoo box clone
--
-- by: @cfd90
-- original sccode by: @olaf
--
-- K1/K2/K3 page navigation
-- E1/E2/E3 change page params
--
-- connect a MIDI Fighter Twister
-- before boot (slot 1) for automap

engine.name = "Blippoo"

local hs = include("lib/blippoo_halfsecond")

local midi_devices = {}
local midi_mode = ""

local page = 1
local last_page = page
local pages = {
  {name = "source oscillators", e1 = "volume", e2 ="freq osc a", e3 = "freq osc b"},
  {name = "twin peak resonator", e1 = "resonance", e2 = "freq peak a", e3 = "freq peak b"},
  {name = "delay", e1 = "volume", e2 = "rate", e3 = "feedback"}
}

local osc_spec = controlspec.new(0.01, 5000, 'exp', 0.01, 100, 'hz', 10/5000)
local mod_spec = controlspec.new(0.01, 1000, 'exp', 0.01, 100, '', 10/1000)
local filter_spec = controlspec.new(0.01, 8000, 'exp', 0.01, 100, '', 10/8000)
local amp_spec = controlspec.new(0, 1, 'lin', 0.01, 1, '', 0.01)
local res_spec = controlspec.new(0.01, 2, 'lin', 0.01, 0.1, '')

local cc_map = {
  "freq_osc_a", "freq_osc_b", "fm_a_b", "fm_b_a", "fm_r_a", "fm_r_b",
  "fm_sah_a", "fm_sah_b", "freqPeak1", "freqPeak2", "resonance",
  "fm_r_peak1", "fm_r_peak2", "fm_sah_peak", "amp"
}

local spec_map = {
  osc_spec, osc_spec, mod_spec, mod_spec, mod_spec, mod_spec, mod_spec, 
  mod_spec, mod_spec, filter_spec, filter_spec, res_spec,
  mod_spec, mod_spec, mod_spec, amp_spec
}

local function setup_params()
  -- Setup oscillators
  params:add_separator("Source Oscillators")
  
  params:add_control("freq_osc_a", "Freq. Osc. A", osc_spec)
  params:set_action("freq_osc_a", function(x) engine.freqOscA(x) end)
  
  params:add_control("freq_osc_b", "Freq. Osc. B", osc_spec)
  params:set_action("freq_osc_b", function(x) engine.freqOscB(x) end)
  
  -- Setup oscillator modulations
  params:add_separator("Oscillator FM")
  
  params:add_control("fm_a_b", "FM A => B", mod_spec)
  params:set_action("fm_a_b", function(x) engine.fm_a_b(x) end)
  
  params:add_control("fm_b_a", "FM B => A", mod_spec)
  params:set_action("fm_b_a", function(x) engine.fm_b_a(x) end)
  
  params:add_control("fm_r_a", "FM Rungler => A", mod_spec)
  params:set_action("fm_r_a", function(x) engine.fm_r_a(x) end)
  
  params:add_control("fm_r_b", "FM Rungler => B", mod_spec)
  params:set_action("fm_r_b", function(x) engine.fm_r_b(x) end)
  
  params:add_control("fm_sah_a", "FM S&H => A", mod_spec)
  params:set_action("fm_sah_a", function(x) engine.fm_sah_a(x) end)
  
  params:add_control("fm_sah_b", "FM S&H => B", mod_spec)
  params:set_action("fm_sah_b", function(x) engine.fm_sah_b(x) end)
  
  -- Setup filter
  params:add_separator("Twin Peak Resonator")
  
  params:add_control("freqPeak1", "Freq. Peak A", filter_spec)
  params:set_action("freqPeak1", function(x) engine.freqPeak1(x) end)
  
  params:add_control("freqPeak2", "Freq. Peak B", filter_spec)
  params:set_action("freqPeak2", function(x) engine.freqPeak2(x) end)
  
  params:add_control("resonance", "Peak Resonance", res_spec)
  params:set_action("resonance", function(x) engine.resonance(x) end)
  
  -- Setup filter modulations
  params:add_separator("Twin Peak FM")
  
  params:add_control("fm_r_peak1", "FM Rungler => Peak A", mod_spec)
  params:set_action("fm_r_peak1", function(x) engine.fm_r_peak1(x) end)
  
  params:add_control("fm_r_peak2", "FM Rungler => Peak B", mod_spec)
  params:set_action("fm_r_peak2", function(x) engine.fm_r_peak2(x) end)
  
  params:add_control("fm_sah_peak", "FM S&H => Peaks", mod_spec)
  params:set_action("fm_sah_peak", function(x) engine.fm_sah_peak(x) end)
  
  -- Setup misc
  params:add_separator("Misc.")
  
  params:add_control("amp", "Volume", amp_spec)
  params:set_action("amp", function(x) engine.amp(x) end)
  
  params:add_separator("Delay")
  
  hs.init()
end

local function setup_defaults()
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

local function mft_draw_initial_state(i)
  local dev = midi_devices[i]

  for cc=1,#cc_map do
    local val = params:get(cc_map[cc])
    local spec = spec_map[cc]
    local midi_val = spec:unmap(val) * 127
    
    print("Initializing " .. cc_map[cc] .. "(" .. (cc - 1) .. ") to " .. midi_val)
    dev:cc(cc - 1, math.ceil(midi_val))
  end
end

local function mft_event(data)
  local msg = midi.to_msg(data)
  
  if msg.type ~= "cc" then
    return
  end
  
  local cc = msg.cc + 1
  local val = msg.val
  
  if cc >= 1 and cc <= #cc_map then
    local param = cc_map[cc]
    local spec = spec_map[cc]
    local pct = val / 127.0
    local v = spec:map(pct)
    
    params:set(param, v)
  end
end

local function setup_midi()
  midi_mode = ""
  
  for i=1,16 do
    midi_devices[i] = midi.connect(i)
    local dev = midi_devices[i]
    
    if dev ~= nil and string.lower(dev.name) == "midi fighter twister" and dev.device ~= nil then
      print("discovered mft on port " .. i)
      
      dev.event = mft_event
      midi_mode = "mft"
      mft_draw_initial_state(i)
      redraw()
    end
  end
end

function init()
  setup_params()
  setup_defaults()
  setup_midi()
end

function redraw()
  screen.clear()
  
  p = pages[page]
  
  screen.level(15)
  screen.move(0, 10)
  screen.text(p["name"])
  
  screen.level(5)
  screen.move(10, 30)
  screen.text(p["e1"])
  screen.move(10, 40)
  screen.text(p["e2"])
  screen.move(10, 50)
  screen.text(p["e3"])
  
  screen.level(1)
  screen.move(0, 64)
  if midi_mode ~= nil and midi_mode ~= "" then
    screen.text("[" .. midi_mode .. "]")
  end
  
  screen.update()
end

function enc(n, d)
  if page == 1 then
    if n == 1 then
      params:delta("amp", d)
    elseif n == 2 then
      params:delta("freq_osc_a", d)
    elseif n == 3 then
      params:delta("freq_osc_b", d)
    end
  elseif page == 2 then
    if n == 1 then
      params:delta("resonance", d)
    elseif n == 2 then
      params:delta("freqPeak1", d)
    elseif n == 3 then
      params:delta("freqPeak2", d)
    end
  elseif page == 3 then
    if n == 1 then
      params:delta("delay", d)
    elseif n == 2 then
      params:delta("delay_rate", d)
    elseif n == 3 then
      params:delta("delay_feedback", d)
    end
  end
end

function key(n, z)
  if n == 1 then
    if z == 1 then
      last_page = page
      page = 3
    else
      page = last_page
    end
  elseif n == 2 then
    page = 1
  elseif n == 3 then
    page = 2
  end
  
  redraw()
end

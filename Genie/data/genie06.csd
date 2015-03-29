Example by Rory Walsh.

<CsoundSynthesizer>
<CsOptions>
;-odevaudio1 -b64 -g -idevaudio1
</CsOptions>
<CsInstruments>
sr = 44100
ksmps = 64
0dbfs = 1
nchnls = 2


instr 1

kfreq chnget "pitch"
kamp chnget "amp"
kdur chnget "dur"
kchanged changed kfreq                          
if(kchanged==1) then  
      event "i", 10, 0, kdur, kamp, kfreq
endif     
endin


instr 10
;p4,p5,p6,p7,p8: amp, freq, dutycycle, mix, pitchdif
a1 vco p4*p7, p5+(p5*(0.1*p8)), 2, p6
a2 vco p4*(1.0 - p7), p5, 3, p6
outs a1+a2, a1+a2
endin
 
</CsInstruments>
<CsScore>
f 1 0 1024 10 1
i 1 0 [60 * 60 * 24]
</CsScore>
</CsoundSynthesizer>
<bsbPanel>
 <label>Widgets</label>
 <objectName/>
 <x>0</x>
 <y>0</y>
 <width>0</width>
 <height>0</height>
 <visible>true</visible>
 <uuid/>
 <bgcolor mode="nobackground">
  <r>255</r>
  <g>255</g>
  <b>255</b>
 </bgcolor>
</bsbPanel>
<bsbPresets>
</bsbPresets>

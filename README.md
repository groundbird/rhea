Memo
----

### ADC CLKOUT のタイミング調整

ADC CLKOUT は基板の配線長に合わせて位相を調整する必要がある. 現在 (2015-07-08), この調整は ADC のレジスタ[^adc_register]で行っているが, 桁上りが多く発生する場合, 特に 8191 (01111111111111) -> -8192 (10000000000000) のような場合, にタイミングが間に合わず, 誤変換することがある. このような急激な値の変化は用途上発生しないと考えているが, 厳密なタイミング調整は行っていないことは記しておく.

[^adc_register]: Register Address 42h で設定可能. デフォルト値は 00h. 現在, CLKOUT rising edge に 250 ps, falling edge に 550 ps の遅延をかけている. (addr, data) = (0x42, 0xF8)

#### Reference

- <http://wiki.kek.jp/display/litebird/kek_gb_weekly_2015_0630?preview=/40212155/40212195/20150630.pdf>, P. 3

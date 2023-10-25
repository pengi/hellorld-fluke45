all: build

TARGETS=\
	hellorld \
	display_proxy \
	hellorld_serial

obj/%.bin obj/%.lst obj/%.sym: src/%.asm FORCE
	mkdir -p $(@D)
	dasm $< -Isrc -oobj/$*-tmp.bin -lobj/$*.lst -sobj/$*.sym
# By some reason, hellorld.bin contains two extra bytes in the beginning
	dd if=obj/$*-tmp.bin of=obj/$*.bin skip=2 bs=1

build: $(foreach tgt,$(TARGETS),obj/$(tgt).bin obj/$(tgt).lst obj/$(tgt).sym)

clean: FORCE
	rm -rf obj

flash: obj/hellorld.bin FORCE
	minipro -p AT28C64B -w $<

flash-serial: obj/hellorld_serial.bin FORCE
	minipro -p AT28C64B -w $<

flash-proxy: obj/display_proxy.bin FORCE
	minipro -p AT28C64B -w $<

FORCE:

.PHONY: FORCE
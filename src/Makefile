# option名	項目名	設定値		memo
# boot		order	a		floppy0
# 					b		floppy1
# 					c		hdd
#					d		cd-rom
# drive		file	ファイル名
#			format	raw		フォーマットを検査しない
# rtc		base 	utc		
#					localtime
#					時刻
# S							デバッガからコマンドが送信されるまで待機
# s 						-gdb tcp::1234と同じ。localhost:1234でgdb serverの接続を待つ
DEBUG_FLAGS = -s -S
RUN_FLAGS 	= -boot order=c -drive file=boot.img,format=raw -rtc base=localtime

boot.img: boot.s 
	nasm -o $@  -l boot.lst $^

run: boot.img
	qemu-system-i386 $(RUN_FLAGS)

debug: boot.img 
	qemu-system-i386 $(RUN_FLAGS) $(DEBUG_FLAGS)

clean: 
	rm -f boot.img boot.lst

.PHONY: clean


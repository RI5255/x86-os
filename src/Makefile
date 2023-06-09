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
boot.img: boot.s 
	nasm -o $@ $^

run: boot.img
	qemu-system-i386 -boot order=c -drive file=boot.img,format=raw -rtc base=localtime
clean: 
	rm -f boot.img

.PHONY: clean


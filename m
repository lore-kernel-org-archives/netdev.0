From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK/GNU] net driver series 13
Date: Mon, 28 Oct 2002 21:51:48 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3DBDF7C4.4050408@pobox.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------090203010605090204080202"
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>, netdev@oss.sgi.com,
   LKML
 <linux-kernel@vger.kernel.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: Marcelo Tosatti <marcelo@conectiva.com.br>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------090203010605090204080202
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit



--------------090203010605090204080202
Content-Type: text/plain;
 name="net-drivers-2.4.txt"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="net-drivers-2.4.txt"

Marcelo, please do a

	bk pull http://gkernel.bkbits.net/net-drivers-2.4

This will update the following files:

 drivers/net/pcmcia/fmvj18x_cs.c |    5 ++---
 drivers/net/tulip/tulip_core.c  |    1 +
 2 files changed, 3 insertions(+), 3 deletions(-)

through these ChangeSets:

<alan@lxorguk.ukuu.org.uk> (02/10/28 1.770)
   del_timer_sync fixes for fmvj18x_cs net driver

<komujun@nifty.com> (02/10/28 1.769)
   Add PCI id to tulip net driver


--------------090203010605090204080202
Content-Type: application/x-bzip2;
 name="netdrvr-13.tar.bz2"
Content-Transfer-Encoding: base64
Content-Disposition: inline;
 filename="netdrvr-13.tar.bz2"

QlpoOTFBWSZTWYfquIkAA3D/hOiwAgBZf//7f6/fZP//3/oABBAIUAOZ5jao
dtAUGRKaE2po2ozU0wJiZMJ6m0TamjEyaAyNMmmTTDKpo0PSNAAAAAAGgAAA
AABJEBE9QU9TanhRpoaNAANM1GmgADQDagcZMmjQGjTEZGhiGBNGmIMRoMIA
DBJFCaaYJqnk9GiMak2poxNA0BhGg09QZpGmJ7lPazZnNMl/hCnRIEatVIQK
MKLs9oSFIWNAwkmTrQ7Z3Pjb0hl3JJmCbBs6G6buzNDoyDrtAcbOdIx4sENx
twnlaogILStRAsolrZ1OmSWPDWES4T7HQHHvb+zSHBYoyorEohjAJmYNF4aQ
MIR5dMcxqW1sjrCDM5pAVgJtypmtEkTaKJxMH4yjr744w8IhSooYGl47A5j7
+pnXVdv9QrAbggCh4TAHXeRp8bF5UEXL95XEiYuCMqaoG25BpAIGHuJ6CYCX
sggVy+0TDJfhM8FVrLKrSdrLUCYYMKNKZUBjembTphmZu92+dTzd3XiKja1j
DDImA4rp5gOEI6ip0HFAJSwQnW6B2QXIIhs5JE/mTVAqScs54QgbZNN79u1L
hKkOzncvlY2k0RnolIML42iaVM59KLzxnYgYIYgn3ByGQOHB2IBEtkIBDDvj
q6CrV1CL3gZngRg9GzhFXTnKI8zQpK6+Kx8FTJ8rjEXikNMGqVtKiinkMtQt
8pBirA9TLbO0pQJILYLV+lNMMqOoXheGteXW64jQZw9QnXgUzAWx8X6EqeNu
kfaEHEmREYEl6vNvkOYUAohGN9UDQM1GwSVBMwJEnAEOK6qOhFYN0clIYxLq
MpMlfIkgwah/BJAGqU3p5IjTpdr0IlO8S/E/yJSIcAbgHD5/RBjlWNSwhyhP
eOqufLkeS6uQ7TnFqkVtRGShzGMCg/kR0hGEWdIzBd9TGxPpgMVDTePzkhEc
wESyjHscsHTODeRxwaNMtRhjYcDNCYgWRgeMwBmKHGKA1FWeSIuPJzistsxR
U5y8RuD5pmaom7hZcStsSnGQTuIrxoL67Fg2BNeJxPS74VR0G2QK7x2axjVI
gycnSbISJ8KBg7a78i/ZmC0CbvfrmlodKRjGFFNHV7QzxRB5d22O8gpFMaDK
Vqp7UygCAKzPi7jSbdwtIBE2GUD0kVYUM3cGDSAxEIlVY5uIjMGBTqhhwYeF
UlF8MADR0zk9uvgyWNtIN+UyQfFu9bVJiESoKVYcXwQv0ga5t1TZCQV9aAGS
qEl/xdyRThQkIfquIkA=

--------------090203010605090204080202--

From: Denis Joseph Barrow <D.Barow@option.com>
Subject: compile error on danauboe.o in linux-2.6.29-rc1
Date: Tue, 13 Jan 2009 13:36:51 +0100
Message-ID: <496C8AE3.3050202@option.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Linux netdev Mailing list <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailer1.option.com ([81.246.70.162]:2051 "EHLO
	mailer1.option.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753546AbZAMMgz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2009 07:36:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  CC [M]  drivers/net/irda/donauboe.o
drivers/net/irda/donauboe.c: In function =91toshoboe_interrupt=92:
drivers/net/irda/donauboe.c:1197: error: =91struct toshoboe_cb=92 has n=
o member named =91stats=92
drivers/net/irda/donauboe.c:1201: error: =91struct toshoboe_cb=92 has n=
o member named =91stats=92
drivers/net/irda/donauboe.c:1283: error: =91struct toshoboe_cb=92 has n=
o member named =91stats=92
make[3]: *** [drivers/net/irda/donauboe.o] Error 1
make[2]: *** [drivers/net/irda] Error 2
make[1]: *** [drivers/net] Error 2
make: *** [drivers] Error 2
djbarrow@djbarrow-laptop:/sda3/devel/linux-2.6.29-rc1.build/linux-2
--=20
best regards,
D.J. Barrow

Linux Kernel Developer
Option NV, Gaston Geenslaan 14, 3001 Leuven, Belgium
=20
T: +32 16 311 621
=46: +32 16 207 164
d.barow@option.com
www.option.com

Disclaimer:
http://www.option.com/company/disclaimer.shtml

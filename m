From: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>
Subject: Re: mm snapshot broken-out-2007-04-07-03-27.tar.gz uploaded
Date: Sat, 07 Apr 2007 21:43:17 +0200
Message-ID: <4617F455.2050401@googlemail.com>
References: <200704071029.l37ATdKR032505@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	"Rafael J. Wysocki" <rjw@sisk.pl>, Pavel Machek <pavel@ucw.cz>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mu-out-0910.google.com ([209.85.134.185]:36391 "EHLO
	mu-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966297AbXDGTnh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 7 Apr 2007 15:43:37 -0400
Received: by mu-out-0910.google.com with SMTP id w9so1615769mue
        for <netdev@vger.kernel.org>; Sat, 07 Apr 2007 12:43:35 -0700 (PDT)
In-Reply-To: <200704071029.l37ATdKR032505@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org napisa=B3(a):
> The mm snapshot broken-out-2007-04-07-03-27.tar.gz has been uploaded =
to
>=20
>    ftp://ftp.kernel.org/pub/linux/kernel/people/akpm/mm/broken-out-20=
07-04-07-03-27.tar.gz
>=20
> It contains the following patches against 2.6.21-rc6:

suspend-to-disk doesn't work when pktgen module is loaded.

Stopping kernel threads timed out after 20 seconds (2 tasks refusing to=
 freeze):
 kpktgend_0
 kpktgend_1
Restarting tasks ... done.
swsusp: Basic memory bitmaps freed

http://www.stardust.webpages.pl/files/tbf/bitis-gabonica/broken-out-200=
7-04-07-03-27/mm-serialconsole2.log

Anyway, this kernel is pretty stable :)

aio_dio_bugs - ok
aiostress - ok
bash_shared_mapping - ok
bonnie - ok
cpu_hotplug - ok
cyclictest - ok
dbench - ok
fsfuzzer - ok
fs_mark - ok
fsx - ok
interbench - ok
iozone -ok
isic - ok
linus_stress - ok
ltp - ptrace bug
pi_tests - ok
rmaptest - ok
rtlinuxtests - ok
rttester - ok
scrashme - ok
spew - ok
stress - ok

Regards,
Michal

--=20
Michal K. K. Piotrowski
LTG - Linux Testers Group (PL)
(http://www.stardust.webpages.pl/ltg/)
LTG - Linux Testers Group (EN)
(http://www.stardust.webpages.pl/linux_testers_group_en/)

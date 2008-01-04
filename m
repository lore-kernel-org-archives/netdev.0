From: "Manfred Schwarb" <manfred99@gmx.ch>
Subject: driver for et131x?
Date: Fri, 04 Jan 2008 11:02:53 +0100
Message-ID: <20080104100253.63070@gmx.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: "Dean Adams" <dadams1969@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.gmx.net ([213.165.64.20]:36717 "HELO mail.gmx.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1753717AbYADKCz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 4 Jan 2008 05:02:55 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[ next try, first attempt was blocked because of an '@' in 'X-Sender:' line? ]


Hi,

meanwhile the Agere et1310 chip has grown to a quite popular network
chip, in laptops as well as for PCI-E cards. The release date of this chip was
already in June 2004, and still no support in mainline linux.

There is apparently an opensource driver from Agere which is maintained by
volunteers at http://sourceforge.net/projects/et131x/

It seems some distros (e.g. Ubuntu) even patch their kernels with this driver.

Please consider adding support for this chip in mainline linux.

Thanks a lot!
Manfred


see also:
http://lkml.org/lkml/2006/7/3/123
http://dadams1969.googlepages.com/et131xkernelmodule

-- 
GMX FreeMail: 1 GB Postfach, 5 E-Mail-Adressen, 10 Free SMS.
Alle Infos und kostenlose Anmeldung: http://www.gmx.net/de/go/freemail

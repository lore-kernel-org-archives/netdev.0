From: devzero@web.de
Subject: Re: arcnet - weird printk arc%d
Date: Sun, 13 Apr 2008 02:33:30 +0200
Message-ID: <236743975@web.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fmmailgate04.web.de ([217.72.192.242]:48393 "EHLO
	fmmailgate04.web.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753114AbYDMAdb convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2008 20:33:31 -0400
Received: from web.de
	by fmmailgate04.web.de (Postfix) with SMTP id B718B53893B9
	for <netdev@vger.kernel.org>; Sun, 13 Apr 2008 02:33:30 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

one more:

Apr 13 01:16:41 neo klogd: eth%d: D-Link DE-600 pocket adapter: not at =
I/O 0x378.
Apr 13 01:16:41 neo klogd: eth%d: i82596 initialization timed out


> -----Urspr=FCngliche Nachricht-----
> Von: <devzero@web.de>
> Gesendet: 13.04.08 02:31:16
> An: netdev@vger.kernel.org
> Betreff: arcnet - weird printk arc%d

>=20
> Apr 13 01:25:50 neo klogd:  arc%d: Given: node 00h, shmem 0h, irq 0
> Apr 13 01:25:50 neo klogd:  arc%d: No autoprobe for RIM I; you must s=
pecify the shmem and irq!
> Apr 13 01:25:50 neo klogd:  arc%d: No autoprobe for IO mapped cards; =
you must specify the base address!
>=20
> arc%d looks weird - is this intenitonal ?


_______________________________________________________________________=
__
In 5 Schritten zur eigenen Homepage. Jetzt Domain sichern und gestalten=
!=20
Nur 3,99 EUR/Monat! http://www.maildomain.web.de/?mc=3D021114


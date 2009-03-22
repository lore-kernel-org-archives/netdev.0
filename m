From: Karsten Wiese <fzu@wemgehoertderstaat.de>
Subject: Re: [PATCH] r8169: Fix irq masking in rtl8169_interrupt()
Date: Mon, 23 Mar 2009 00:53:28 +0100
Message-ID: <200903230053.29125.fzu@wemgehoertderstaat.de>
References: <200903172034.55241.fzu@wemgehoertderstaat.de> <200903200240.50183.fzu@wemgehoertderstaat.de> <20090322211629.GA23095@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Rafael Wysocki <rjw@sisk.pl>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout1.freenet.de ([195.4.92.91]:56322 "EHLO mout1.freenet.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757264AbZCVXxh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2009 19:53:37 -0400
In-Reply-To: <20090322211629.GA23095@electric-eye.fr.zoreil.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Sonntag 22 M=E4rz 2009 schrieb Francois Romieu:
> Karsten Wiese <fzu@wemgehoertderstaat.de> :
> [...]
> > The pc I debugged this on is a UP with no other device active on th=
e used
> > int16.
>=20
> /me wonders...
>=20
> Does your network adapter support pxe or some boot time operation ?

Yes, deavtivated in BIOS.

> Btw the XID of the device would be welcome.

XID is 04000000

Thanks,
Karsten

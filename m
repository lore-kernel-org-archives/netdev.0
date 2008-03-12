From: David Miller <davem@davemloft.net>
Subject: Re: Treason uncloaked spams syslog with latest git
Date: Tue, 11 Mar 2008 17:56:25 -0700 (PDT)
Message-ID: <20080311.175625.193682131.davem@davemloft.net>
References: <alpine.LFD.1.00.0803102046420.3781@apollo.tec.linutronix.de>
	<Pine.LNX.4.64.0803111138360.5423@kivilampi-30.cs.helsinki.fi>
	<alpine.LFD.1.00.0803111440040.3781@apollo.tec.linutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, akpm@linux-foundation.org
To: tglx@linutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45825
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751327AbYCLA4S convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Mar 2008 20:56:18 -0400
In-Reply-To: <alpine.LFD.1.00.0803111440040.3781@apollo.tec.linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Thomas Gleixner <tglx@linutronix.de>
Date: Tue, 11 Mar 2008 14:59:53 +0100 (CET)

> On Tue, 11 Mar 2008, Ilpo J=E4rvinen wrote:
> > > http://www.tglx.de/~tglx/treason.cap
> > >=20
> > > That's on -rc5
> >=20
> > Thanks, I think I found the reason. Does the patch below fix it...
>=20
> Yes, it does.
>=20
> > message suggests, we had just sent something past it without
> > a permission to do so).
> >=20
> > Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
>=20
> Tested-by: Thomas Gleixner <tglx@linutronix.de>

Patch applied, thanks everyone.

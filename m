From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: Re: [PATCH CFT 02/30] net: fec: iMX6 FEC does not support
	half-duplex gigabit
Date: Tue, 8 Jul 2014 12:47:18 +0100
Message-ID: <20140708114718.GI21766@n2100.arm.linux.org.uk>
References: <20140627151542.GL32514@n2100.arm.linux.org.uk> <E1X0Xvb-0001Mu-JB@rmk-PC.arm.linux.org.uk> <20140708064611.GF7827@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Fugang Duan <B38611@freescale.com>
To: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:58562 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1750774AbaGHLrV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 07:47:21 -0400
Content-Disposition: inline
In-Reply-To: <20140708064611.GF7827@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 08, 2014 at 08:46:11AM +0200, Uwe Kleine-K=F6nig wrote:
> Hi Russell,
>=20
> On Fri, Jun 27, 2014 at 04:19:03PM +0100, Russell King wrote:
> > The iMX6 gigabit FEC does not support half-duplex gigabit operation=
=2E
> > Phys attacked to the FEC may support this, and we currently do noth=
ing
> Even if it might be interpreted as an attack to connect such a phy to
> the FEC, I'd still call it "attach" here :-)

You are right, but unfortunately your comment comes too late; this is
the actual submission for David to integrate the patches into net-next
rather than for review, and David has already integrated the change int=
o
his tree.  Hence, the comment is unable to be fixed now.

Thanks anyway.

--=20
=46TTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... sl=
owly
improving, and getting towards what was expected from it.

From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH CFT 02/30] net: fec: iMX6 FEC does not support
 half-duplex gigabit
Date: Tue, 8 Jul 2014 08:46:11 +0200
Message-ID: <20140708064611.GF7827@pengutronix.de>
References: <20140627151542.GL32514@n2100.arm.linux.org.uk>
 <E1X0Xvb-0001Mu-JB@rmk-PC.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
	Fugang Duan <B38611@freescale.com>
To: Russell King <rmk+kernel@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:54806 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753103AbaGHGql (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jul 2014 02:46:41 -0400
Content-Disposition: inline
In-Reply-To: <E1X0Xvb-0001Mu-JB@rmk-PC.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Russell,

On Fri, Jun 27, 2014 at 04:19:03PM +0100, Russell King wrote:
> The iMX6 gigabit FEC does not support half-duplex gigabit operation.
> Phys attacked to the FEC may support this, and we currently do nothin=
g
Even if it might be interpreted as an attack to connect such a phy to
the FEC, I'd still call it "attach" here :-)

Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |

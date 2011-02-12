From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 02/14] net/fec: release mem_region requested in probe
 in error path and remove
Date: Fri, 11 Feb 2011 21:25:32 -0800 (PST)
Message-ID: <20110211.212532.229740768.davem@davemloft.net>
References: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
	<1297420342-17739-2-git-send-email-u.kleine-koenig@pengutronix.de>
	<20110211110339.GH27982@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shawn.guo@freescale.com,
	kernel@pengutronix.de
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41511
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751129Ab1BLFY4 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Feb 2011 00:24:56 -0500
In-Reply-To: <20110211110339.GH27982@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Fri, 11 Feb 2011 12:03:39 +0100

> Hello,
>=20
> On Fri, Feb 11, 2011 at 11:32:10AM +0100, Uwe Kleine-K=F6nig wrote:
>> Noticed-by: Lothar Wa=DFmann <LW@KARO-electronics.de>
> I changed that to Reported-by: in this and the other patches.
> (this was Reported-by: Wolfram Sang via irc).  The updated patches ca=
n
> be found at
>=20
> 	git://git.pengutronix.de/git/ukl/linux-2.6.git fec

I can't pull from that tree because it is _NOT_ based upon net-next-2.6
and therefore brings in all kinds of commits not related to your work.

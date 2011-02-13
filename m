From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH 02/14] net/fec: release mem_region requested in probe
 in error path and remove
Date: Sun, 13 Feb 2011 22:07:09 +0100
Message-ID: <20110213210709.GA13279@pengutronix.de>
References: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
 <1297420342-17739-2-git-send-email-u.kleine-koenig@pengutronix.de>
 <20110211110339.GH27982@pengutronix.de>
 <20110211.212532.229740768.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, shawn.guo@freescale.com,
	kernel@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:42740 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754744Ab1BMVHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Feb 2011 16:07:14 -0500
Content-Disposition: inline
In-Reply-To: <20110211.212532.229740768.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Fri, Feb 11, 2011 at 09:25:32PM -0800, David Miller wrote:
> I can't pull from that tree because it is _NOT_ based upon net-next-2=
=2E6
> and therefore brings in all kinds of commits not related to your work=
=2E
Sorry, I'm not used to the customs on netdev.  I can rebase, but still =
I
wonder about the reason you cannot pull for.  The only reason I can
imagine is that you fear unrelated breakage when taking these patches
that are already in Linus' tree.  But if it's that, wouldn't it be grea=
t
the realize this breakage already now and not only during the next merg=
e
window?

Best regards
Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |

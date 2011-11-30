From: Uwe =?iso-8859-1?Q?Kleine-K=F6nig?=
	<u.kleine-koenig@pengutronix.de>
Subject: Re: [PATCH v2] net: fec: Select the FEC driver by default for i.MX
 SoCs
Date: Wed, 30 Nov 2011 14:26:22 +0100
Message-ID: <20111130132622.GE26618@pengutronix.de>
References: <1322652717-2685-1-git-send-email-fabio.estevam@freescale.com>
 <20111130132536.GD26618@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-arm-kernel@lists.infradead.org, kernel@pengutronix.de,
	shawn.guo@freescale.com, davem@davemloft.net,
	netdev@vger.kernel.org, marek.vasut@gmail.com
To: Fabio Estevam <fabio.estevam@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from metis.ext.pengutronix.de ([92.198.50.35]:60553 "EHLO
	metis.ext.pengutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755012Ab1K3N0a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 08:26:30 -0500
Content-Disposition: inline
In-Reply-To: <20111130132536.GD26618@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 30, 2011 at 02:25:36PM +0100, Uwe Kleine-K=F6nig wrote:
> On Wed, Nov 30, 2011 at 09:31:57AM -0200, Fabio Estevam wrote:
> > Let the FEC driver be built by default.
> >=20
> > Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
> Just one small nitpick below. Other than that:
>=20
> Suggested-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> Acked-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

ah, and maybe point out the breaking commit in the log.

Uwe

--=20
Pengutronix e.K.                           | Uwe Kleine-K=F6nig        =
    |
Industrial Linux Solutions                 | http://www.pengutronix.de/=
  |

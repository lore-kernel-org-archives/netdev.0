From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: fec: Support phys probed from devicetree and
 fixed-link
Date: Mon, 11 Aug 2014 14:41:25 -0700 (PDT)
Message-ID: <20140811.144125.43958671448712475.davem@davemloft.net>
References: <1407771333-24683-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com,
	thomas.petazzoni@free-electrons.com, fabio.estevam@freescale.com,
	kernel@pengutronix.de, devicetree@vger.kernel.org,
	s.hauer@pengutronix.de
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59209 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751714AbaHKVl0 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2014 17:41:26 -0400
In-Reply-To: <1407771333-24683-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Mon, 11 Aug 2014 17:35:33 +0200

> This adds support for specifying the phy to be used with the fec in t=
he
> devicetree using the standard phy-handle property and also supports
> fixed-link.
>=20
> Signed-off-by: Sascha Hauer <s.hauer@pengutronix.de>
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

Applied, thanks.

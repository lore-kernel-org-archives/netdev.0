From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] net: ucc_geth: Don't use the MAC as PHY without a
 fixed link
Date: Thu, 07 Aug 2014 16:07:29 -0700 (PDT)
Message-ID: <20140807.160729.547343802808631351.davem@davemloft.net>
References: <1407448106-1819-1-git-send-email-u.kleine-koenig@pengutronix.de>
	<1407448106-1819-3-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: leoli@freescale.com, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, kernel@pengutronix.de, f.fainelli@gmail.com
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53724 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756027AbaHGXHa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 19:07:30 -0400
In-Reply-To: <1407448106-1819-3-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Thu,  7 Aug 2014 23:48:26 +0200

> This matches what the other drivers using fixed-link support do and
> restores the behaviour before commit 87009814cdbb ("ucc_geth: use the
> new fixed PHY helpers") for the affected device trees (i.e. no
> phy-handle and no fixed-link).
>=20
> Fixes: 87009814cdbb ("ucc_geth: use the new fixed PHY helpers")
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

Applied.

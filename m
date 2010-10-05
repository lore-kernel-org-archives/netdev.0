From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] [RFC] don't let BCM63XX_PHY depend on non-existant
 symbol
Date: Tue, 05 Oct 2010 00:36:12 -0700 (PDT)
Message-ID: <20101005.003612.42814203.davem@davemloft.net>
References: <1286185413-22924-1-git-send-email-u.kleine-koenig@pengutronix.de>
	<1286185413-22924-2-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, mbizon@freebox.fr, florian@openwrt.org,
	ralf@linux-mips.org
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60986
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755928Ab0JEHfv convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Oct 2010 03:35:51 -0400
In-Reply-To: <1286185413-22924-2-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Mon,  4 Oct 2010 11:43:33 +0200

> The kernel doesn't have a symbol called BCM63XX.  There is a symbol
> BCM63XX_ENET (introduced in 9b1fc55a0500, 6 weeks after 09bb9aa0ed th=
at
> introduced BCM63XX_PHY), but the driver compiles without that, too.
>=20
> Cc: Maxime Bizon <mbizon@freebox.fr>
> Cc: Florian Fainelli <florian@openwrt.org>
> Cc: David S. Miller <davem@davemloft.net>
> Cc: Ralf Baechle <ralf@linux-mips.org>
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

Looks good to me, applied.

Thanks.

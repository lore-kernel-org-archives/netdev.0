From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netx-eth: initialize per device spinlock
Date: Wed, 03 Dec 2008 22:19:06 -0800 (PST)
Message-ID: <20081203.221906.07748849.davem@davemloft.net>
References: <1228337691-8140-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44381
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751576AbYLDGTG convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Dec 2008 01:19:06 -0500
In-Reply-To: <1228337691-8140-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Wed,  3 Dec 2008 21:54:51 +0100

> The spinlock used in the netx-eth driver was never properly initializ=
ed.
> This was noticed using CONFIG_DEBUG_SPINLOCK=3Dy
>=20
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> Acked-by: Sascha Hauer <s.hauer@pengutronix.de>

Applied, thank you.

From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 15/14] net/fec: remove unused driver data
Date: Tue, 22 Feb 2011 10:16:39 -0800 (PST)
Message-ID: <20110222.101639.59689167.davem@davemloft.net>
References: <1297420342-17739-1-git-send-email-u.kleine-koenig@pengutronix.de>
	<1297981945-28501-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, mkl@pengutronix.de, kernel@pengutronix.de
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46173
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754963Ab1BVSQD convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Feb 2011 13:16:03 -0500
In-Reply-To: <1297981945-28501-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Thu, 17 Feb 2011 23:32:25 +0100

> Apart from not being used the first argument isn't even a struct
> platform_device *.
>=20
> Reported-by: Marc Kleine-Budde <mkl@pengutronix.de>
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
> ---
> Hello,
>=20
> this patch is available at
>=20
> 	git://git.pengutronix.de/git/ukl/linux-2.6.git fec
>=20
> based on the patches already merged into net-next.

Pulled, thanks.

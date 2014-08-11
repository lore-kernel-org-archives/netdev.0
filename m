From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ucc_geth: fix build failure
Date: Sun, 10 Aug 2014 21:40:25 -0700 (PDT)
Message-ID: <20140810.214025.1717177470256485891.davem@davemloft.net>
References: <20140808.135237.120203200807493642.davem@davemloft.net>
	<1407695525-32227-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: leoli@freescale.com, linuxppc-dev@lists.ozlabs.org,
	netdev@vger.kernel.org, kernel@pengutronix.de, f.fainelli@gmail.com
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52826 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751511AbaHKEk1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2014 00:40:27 -0400
In-Reply-To: <1407695525-32227-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Sun, 10 Aug 2014 20:32:05 +0200

> My series to fix the reference counting of dt nodes introduced a buil=
d
> failure. Fix it.
>=20
> Fixes: fa310789a488 ("net: ucc_geth: drop acquired references in prob=
e error path and remove")
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

Applied, thanks.

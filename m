From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: gianfar: no need to check parameter being != NULL
 for of_node_put
Date: Thu, 07 Aug 2014 16:05:39 -0700 (PDT)
Message-ID: <20140807.160539.392980842870853316.davem@davemloft.net>
References: <1407439212-16661-1-git-send-email-u.kleine-koenig@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, julia.lawall@lip6.fr,
	claudiu.manoil@freescale.com, kernel@pengutronix.de,
	f.fainelli@gmail.com, fabio.estevam@freescale.com
To: u.kleine-koenig@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53639 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755202AbaHGXFk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Aug 2014 19:05:40 -0400
In-Reply-To: <1407439212-16661-1-git-send-email-u.kleine-koenig@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>
Date: Thu,  7 Aug 2014 21:20:12 +0200

> of_node_put is a noop when being called with NULL.
>=20
> Signed-off-by: Uwe Kleine-K=F6nig <u.kleine-koenig@pengutronix.de>

Applied.

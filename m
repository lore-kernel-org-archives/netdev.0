From: David Miller <davem@davemloft.net>
Subject: Re: pull-request: can-next 2015-03-23
Date: Mon, 23 Mar 2015 22:04:07 -0400 (EDT)
Message-ID: <20150323.220407.2182995151527470865.davem@davemloft.net>
References: <55100EA8.5010505@pengutronix.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kernel@pengutronix.de,
	linux-can@vger.kernel.org
To: mkl@pengutronix.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59927 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752321AbbCXCEI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Mar 2015 22:04:08 -0400
In-Reply-To: <55100EA8.5010505@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Marc Kleine-Budde <mkl@pengutronix.de>
Date: Mon, 23 Mar 2015 14:01:28 +0100

> this is a pull request of 6 patches for net-next/master.
>=20
> A patch by Florian Westphal, converts the skb->destructor to use
> sock_efree() instead of own destructor. Ahmed S. Darwish's patch
> converts the kvaser_usb driver to use unregister_candev(). A patch by
> me removes a return from a void function in the m_can driver. Yegor
> Yefremov contributes a patch for combined rx/tx LED trigger support. =
A
> sparse warning in the esd_usb2 driver was fixes by Thomas K=F6rper. B=
en
> Dooks converts the at91_can driver to use endian agnostic IO accessor=
s.

Pulled, thanks Marc.

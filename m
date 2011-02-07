From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4 4/5] net: introduce NETIF_F_RXCSUM
Date: Mon, 07 Feb 2011 13:12:55 -0800 (PST)
Message-ID: <20110207.131255.39187458.davem@davemloft.net>
References: <cover.1296741561.git.mirq-linux@rere.qmqm.pl>
	<629a5e9cc87a171997e611b8227d58cfe4fbe6ff.1296741562.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=euc-kr
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, bhutchings@solarflare.com
To: mirq-linux@rere.qmqm.pl
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48151
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753949Ab1BGVMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Feb 2011 16:12:20 -0500
In-Reply-To: <629a5e9cc87a171997e611b8227d58cfe4fbe6ff.1296741562.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
Date: Thu,  3 Feb 2011 15:21:22 +0100 (CET)

> Introduce NETIF_F_RXCSUM to replace device-private flags for RX check=
sum
> offload. Integrate it with ndo_fix_features.
>=20
> ethtool_op_get_rx_csum() is removed altogether as nothing in-tree use=
s it.
>=20
> Signed-off-by: Micha=A9=A9 Miros=A9=A9aw <mirq-linux@rere.qmqm.pl>
> Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>               =
                                    =20

Applied.

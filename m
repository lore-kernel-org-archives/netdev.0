From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v3 4/5] net: introduce NETIF_F_RXCSUM
Date: Sun, 30 Jan 2011 08:45:37 +1000
Message-ID: <1296341137.3477.65.camel@localhost>
References: <cover.1296325509.git.mirq-linux@rere.qmqm.pl>
	 <6ca4686615452830809f496a494c7b8ae6d9f082.1296325509.git.mirq-linux@rere.qmqm.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:17396 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755086Ab1A2Wpk convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jan 2011 17:45:40 -0500
In-Reply-To: <6ca4686615452830809f496a494c7b8ae6d9f082.1296325509.git.mirq-linux@rere.qmqm.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2011-01-29 at 19:39 +0100, Micha=C5=82 Miros=C5=82aw wrote:
> Introduce NETIF_F_RXCSUM to replace device-private flags for RX check=
sum
> offload. Integrate it with ndo_fix_features.
>=20
> ethtool_op_get_rx_csum() is removed altogether as nothing in-tree use=
s it.
>=20
> Signed-off-by: Micha=C5=82 Miros=C5=82aw <mirq-linux@rere.qmqm.pl>
Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

